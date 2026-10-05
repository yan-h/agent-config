#!/usr/bin/env bash
# Does reclaim-worktrees.sh keep its ownership boundary, tell a live session's
# lock from an abandoned one, and refuse to lose uncommitted work?
#
# These are the decisions in that script that can DELETE a directory: whether
# the worktree belongs to Claude, whether a Claude lock is live, whether its
# work is resolved, and whether its tree is clean. Their inputs live outside
# any repository — a path, a pid, its argv, the spare pool's socket files,
# process cwds, GitHub's PR list, the user's git config — so nothing else can
# catch them going wrong. The lock reading has gone wrong in both directions:
# too conservative (a returned spare kept its lock, and its cache, forever),
# then too eager (a discriminator that matched every live session, so a paused
# session's whole worktree was removable out from under it).
#
# The script has no main guard and does real work at load, so these drive it
# end to end: throwaway repos, shims for `ps`, `lsof`, `gh` and `git` ahead of
# the real ones on PATH, and DRY_RUN wherever a printed decision is enough.
# Cases that must prove a deletion did or did not happen run it for real, in a
# throwaway repo only. RECLAIM_FORCE=1 skips the df gate — the reading on the
# test machine's disk is not part of what is under test.
#
#   bash skills/session-lifecycle/scripts/test_reclaim_worktrees.sh
#
# Written for bash 3.2 (macOS system bash), like the script it tests.
set -uo pipefail

# This test creates and enters throwaway repositories, so inherited GIT_DIR,
# GIT_INDEX_FILE and related variables — git exports them to hooks, and a test
# suite run from a pre-push hook inherits them — would point every git call
# below at the caller's repo instead. That is not a near miss: `git init` with
# GIT_DIR set and no work tree sets `core.bare=true` on the real repo, `git
# commit` lands on the real branch, and `git worktree add` registers a worktree
# in a temp directory this script then deletes.
for v in $(env | sed -n 's/^\(GIT_[A-Z_]*\)=.*/\1/p'); do
  unset "$v"
done

SCRIPT=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)/reclaim-worktrees.sh
[ -x "$SCRIPT" ] || { echo "✗ not executable: $SCRIPT" >&2; exit 1; }

TMP=$(mktemp -d "${TMPDIR:-/tmp}/reclaim-worktrees.XXXXXX") || exit 1
trap 'rm -rf "$TMP"' EXIT

failures=0
case_n=0

fail() {
  echo "✗ $1" >&2
  failures=$((failures + 1))
}

# Initialise a throwaway repo in $1 and cd into it; call inside a subshell.
#
# The guard is belt and braces over the unset above, and the one that matters:
# prove git resolves INSIDE this throwaway repo before committing to it or
# adding worktrees to it. Both paths are physical (`pwd -P` and
# `--absolute-git-dir`), which is what makes the prefix test hold under
# macOS's /var -> /private/var symlink.
init_repo() {
  mkdir -p "$1" && cd "$1" || return 1
  git init -q . 2>/dev/null || return 1
  real=$(pwd -P)
  here=$(git rev-parse --absolute-git-dir 2>/dev/null)
  case "$here" in
    "$real"/*) ;;
    *) echo "refusing: git resolves to ${here:-nothing}, not $real" >&2; return 1 ;;
  esac
  git checkout -q -b main 2>/dev/null || true
  git config user.email t@t
  git config user.name t
}

# Make everything under $1 older than any idle gate, so a case is decided by
# the gate it is about and not by "touched in the last N minutes".
backdate() {
  find "$1" -depth -exec touch -t 200001010000 {} \; 2>/dev/null
}

# One case: build a repo whose single worktree is locked by a harness-format
# reason naming pid 4242, put a `ps` shim on PATH that gives that pid the
# cmdline $cmd, and assert the script's own note for that worktree matches
# $want.
#
# $sock is the claim-socket path the shim reports in the cmdline; it is
# created on disk only when $sock_exists is 1, which is the whole signal —
# see the script's own comment at the lock branch.
check_spare() {
  desc=$1; cmd=$2; sock_exists=$3; want=$4

  work="$TMP/case$((++case_n))"
  mkdir -p "$work/bin"
  sock="$work/spare.claim.sock"
  [ "$sock_exists" = 1 ] && : > "$sock"

  # The shim answers the two forms the script uses: a liveness probe, and a
  # cmdline read.
  cat > "$work/bin/ps" <<SHIM
#!/usr/bin/env bash
case "\$*" in
  *"-o command="*) printf '%s\n' "${cmd//SOCK/$sock}" ;;
  *) exit 0 ;;
esac
SHIM
  chmod +x "$work/bin/ps"

  (
    init_repo "$work/main" || exit 1
    git commit -q --allow-empty -m base
    # The branch sits ON main's commit, so the ancestor test reads it as
    # merged and the run reaches the removal gate rather than stopping short.
    git worktree add -q -b w1 .claude/worktrees/w1 HEAD 2>/dev/null
    git worktree lock --reason "claude session w1 (pid 4242 start Mon Aug 10 02:00:00 2026)" \
      .claude/worktrees/w1 2>/dev/null
  ) || { fail "$desc: could not build the fixture"; return; }

  out=$(cd "$work/main" && PATH="$work/bin:$PATH" CLAUDE_PROJECT_DIR="$work/main" \
    RECLAIM_DRY_RUN=1 RECLAIM_FORCE=1 RECLAIM_NO_NETWORK=1 \
    "$SCRIPT" </dev/null 2>&1 >/dev/null)

  if grep -q "$want" <<<"$out"; then
    echo "✓ $desc"
  else
    fail "$desc"
    echo "    expected a line matching: $want" >&2
    printf '%s\n' "$out" | sed 's/^/    got: /' >&2
  fi
}

# A Codex Worktree root is configurable. If it is placed below
# `.claude/worktrees`, the app still creates its own `<id>/<repo>` level below
# that root; a prefix-only ownership check mistakes the nested worktree for a
# Claude one and removes it. Run the reclaimer for real and prove both the
# worktree and its prunable cache survive, while the direct child — the
# positive control — goes.
check_codex_ownership() {
  work="$TMP/ownership"
  main="$work/main"
  codex_wt="$main/.claude/worktrees/codex-id/repo"
  claude_wt="$main/.claude/worktrees/claude-w"

  (
    init_repo "$main" || exit 1
    printf '/.claude/worktrees/\n/target/\n' > .gitignore
    git add .gitignore
    git commit -q -m base || exit 1
    mkdir -p "$(dirname "$codex_wt")" || exit 1
    git worktree add -q -b codex/app "$codex_wt" HEAD 2>/dev/null || exit 1
    git worktree add -q -b claude/w "$claude_wt" HEAD 2>/dev/null || exit 1
    mkdir -p "$codex_wt/target/debug" "$claude_wt/target/debug" || exit 1
    : > "$codex_wt/target/debug/sentinel"
    : > "$claude_wt/target/debug/sentinel"
    backdate "$claude_wt"
  ) || { fail "a Codex-managed worktree: could not build the fixture"; return; }

  if [ ! -e "$codex_wt/.git" ] || [ ! -e "$claude_wt/.git" ]; then
    fail "a Codex-managed worktree: fixture worktrees are not registered"
    return
  fi

  out="$work/run.log"
  (cd "$main" && CLAUDE_PROJECT_DIR="$main" RECLAIM_FORCE=1 \
    RECLAIM_NO_NETWORK=1 RECLAIM_MIN_IDLE_MINUTES=0 \
    RECLAIM_PRUNE_IDLE_MINUTES=0 "$SCRIPT" </dev/null) >"$out" 2>&1
  status=$?

  if [ "$status" -eq 0 ] && [ -f "$codex_wt/target/debug/sentinel" ] &&
    [ ! -d "$claude_wt" ]; then
    echo "✓ a Codex-managed worktree stays app-owned"
  else
    fail "the reclaimer did not distinguish Codex and Claude ownership"
    sed 's/^/    /' "$out" >&2
  fi
}

# A lock this script did not write names nobody it can check, so it is left
# alone whatever its text happens to contain. The reason below carries a dead
# pid in prose, which is the shape that reads as attributable without being so:
# only a lock in the harness's own format says which session is holding it.
# A hand-written lock stands until a human clears it; a hand-locked worktree
# that the reclaimer deletes at the next SessionStart is that promise broken
# with work inside it.
check_handmade_lock() {
  desc="a hand-written lock is left for a human"
  work="$TMP/handmade"
  mkdir -p "$work/bin"

  # The pid is dead: the liveness probe fails, so nothing but the reason's own
  # shape stands between this worktree and the removal gate.
  printf '#!/usr/bin/env bash\nexit 1\n' > "$work/bin/ps"
  chmod +x "$work/bin/ps"

  (
    init_repo "$work/main" || exit 1
    git commit -q --allow-empty -m base
    git worktree add -q -b w1 .claude/worktrees/w1 HEAD 2>/dev/null
    git worktree lock --reason "held by hand for pid 4242, mid-investigation" \
      .claude/worktrees/w1 2>/dev/null
  ) || { fail "$desc: could not build the fixture"; return; }

  # The idle guard sits AFTER the lock check and would carry this case on a
  # reason that has nothing to do with the lock. Backdating puts the lock on
  # its own.
  backdate "$work/main/.claude/worktrees/w1"

  out=$(cd "$work/main" && PATH="$work/bin:$PATH" CLAUDE_PROJECT_DIR="$work/main" \
    RECLAIM_DRY_RUN=1 RECLAIM_FORCE=1 RECLAIM_NO_NETWORK=1 \
    "$SCRIPT" </dev/null 2>&1)

  if grep -q "skip w1: locked by a reason this script did not write" <<<"$out" &&
    ! grep -q "would remove" <<<"$out"; then
    echo "✓ $desc"
  else
    fail "$desc"
    printf '%s\n' "$out" | sed 's/^/    got: /' >&2
  fi
}

# Remote Control's `--spawn worktree` locks with `claude agent bridge-<id> (pid
# <n> start <date>)`, and the pid is the daemon's: alive for as long as the
# phone bridge is up, whether or not anything still runs in the worktree. So
# the ps shim below answers ALIVE in every case, and the lock's liveness has to
# come from process cwds instead — the lsof shim is what varies:
#
#   inside  a process sits at the worktree's root              -> held
#   none    only a sibling sharing its name as a prefix does   -> stale
#           (the boundary a bare prefix match gets wrong)
#   blind   lsof lists other processes but not the daemon      -> held
#           (a sandbox that sees only part of the process table)
#   gone    the daemon is dead, nothing is inside, and lsof     -> stale
#           lists the script itself, the fallback control
#
# The stale cases assert "would remove", not just "stale lock": the idle and
# resolved gates come after, and only reaching the removal line proves a live
# daemon pid did not stop it first. The last case is the same `claude agent`
# shape from the Agent tool, whose pid is its parent session's and IS the
# signal: no cwd inside, and still held.
check_agent_lock() {
  mode=$1; desc=$2; reason=$3; want=$4
  work="$TMP/agent$((++case_n))"
  main="$work/main"
  mkdir -p "$work/bin"

  # Alive and this user's, which is what makes the daemon the control —
  # except in `gone`, where every pid is dead.
  if [ "$mode" = gone ]; then
    printf '#!/usr/bin/env bash\nexit 1\n' > "$work/bin/ps"
  else
    printf '#!/usr/bin/env bash\ncase "$*" in *uid=*) id -u ;; esac\nexit 0\n' > "$work/bin/ps"
  fi
  chmod +x "$work/bin/ps"

  (
    init_repo "$main" || exit 1
    git commit -q --allow-empty -m base || exit 1
    git worktree add -q -b w1 .claude/worktrees/w1 HEAD 2>/dev/null || exit 1
    git worktree lock --reason "$reason" .claude/worktrees/w1 2>/dev/null || exit 1
  ) || { fail "$desc: could not build the fixture"; return; }

  # `-Fpn` output: a `p<pid>` line, then that process's `n<cwd>`. Pid 4242 is
  # the lock's daemon, which the script needs to see before believing the rest.
  # In `gone` the control is the script, which is lsof's parent or, through a
  # `$( )` subshell, its grandparent — so the shim lists both, found with the
  # real ps since the shimmed one is dead to every pid in this mode.
  wt=$(cd "$main/.claude/worktrees/w1" && pwd -P)
  real_ps=$(command -v ps)
  case "$mode" in
    inside) listing="p4242\nn/\np7\nn$wt" ;;
    none)   listing="p4242\nn/\np7\nn${wt}x" ;;
    blind)  listing="p7\nn/elsewhere" ;;
    gone)   listing="p\$PPID\nn/\np\$($real_ps -o ppid= -p \$PPID | tr -d ' ')\nn/\np7\nn${wt}x" ;;
  esac
  printf '#!/usr/bin/env bash\nprintf "%s\\n"\n' "$listing" > "$work/bin/lsof"
  chmod +x "$work/bin/lsof"

  backdate "$main/.claude/worktrees"

  out=$(cd "$main" && PATH="$work/bin:$PATH" CLAUDE_PROJECT_DIR="$main" \
    RECLAIM_DRY_RUN=1 RECLAIM_FORCE=1 RECLAIM_NO_NETWORK=1 \
    RECLAIM_MIN_IDLE_MINUTES=0 "$SCRIPT" </dev/null 2>&1)

  # A case that expects the lock to hold must also show nothing removable:
  # the skip line alone would pass a branch that printed it and returned 0.
  if grep -q "$want" <<<"$out" &&
    { [ "${want#would remove}" != "$want" ] || ! grep -q "would remove" <<<"$out"; }; then
    echo "✓ $desc"
  else
    fail "$desc"
    echo "    expected a line matching: $want" >&2
    printf '%s\n' "$out" | sed 's/^/    got: /' >&2
  fi
}

# Containment is the widest removal signal, so it is the one that has to be
# proved in BOTH directions from a single fixture: the two shapes equality
# missed, and branches that must still be kept. A test that only showed the
# positives would pass just as happily against a rubber stamp — and
# `--ignore-missing` makes a rubber stamp the natural failure here, since it
# drops an unreadable rev rather than complaining.
#
# The repo below puts main at A and hangs four worktrees off it:
#   closed-w  at B, and a CLOSED PR whose head is B      -> resolved
#   behind-w  at B, and a MERGED PR whose head is C (B's child, not in main)
#                                                        -> resolved, and the
#                                                           case sha equality
#                                                           reads as unmerged
#   live-w    at D, named by no PR at all                -> KEPT
#   ghost-w   on an unborn branch, so its HEAD is the    -> KEPT
#             null sha: the input `--ignore-missing`
#             would silently drop, counting zero commits
#   reopen-w  at E on reopen-b: a CLOSED PR's head is E, -> KEPT
#             and an OPEN PR on reopen-b has moved on
#   stack-w   at F: a CLOSED PR's head is F, and an      -> KEPT
#             OPEN PR on another branch has head F too
# None of them is an ancestor of main, so every one reaches the gh-backed
# signals rather than stopping at the offline test.
check_containment() {
  work="$TMP/containment"
  main="$work/main"
  mkdir -p "$work/bin"

  shas="$work/shas"
  (
    init_repo "$main" || exit 1
    printf '/.claude/worktrees/\n' > .gitignore
    git add .gitignore
    git commit -q -m base || exit 1

    # B, then C on top of it. C is the sha that "merged"; the worktree stays
    # at B — a branch pushed to after its worktree last built.
    git checkout -q -b feature 2>/dev/null || exit 1
    git commit -q --allow-empty -m B || exit 1
    b=$(git rev-parse HEAD)
    git commit -q --allow-empty -m C || exit 1
    c=$(git rev-parse HEAD)

    git checkout -q main 2>/dev/null || exit 1
    git branch -q -f closed-b "$b" || exit 1
    git branch -q -f behind-b "$b" || exit 1

    git checkout -q -b unresolved 2>/dev/null || exit 1
    git commit -q --allow-empty -m D || exit 1
    git checkout -q main 2>/dev/null || exit 1

    # E and F, each closed in one PR and still claimed by an open one.
    git checkout -q -b reopen-b 2>/dev/null || exit 1
    git commit -q --allow-empty -m E || exit 1
    e=$(git rev-parse HEAD)
    git checkout -q main 2>/dev/null || exit 1
    git checkout -q -b stack-b 2>/dev/null || exit 1
    git commit -q --allow-empty -m F || exit 1
    f=$(git rev-parse HEAD)
    git checkout -q main 2>/dev/null || exit 1
    git worktree add -q .claude/worktrees/reopen-w reopen-b 2>/dev/null || exit 1
    git worktree add -q --detach .claude/worktrees/stack-w "$f" 2>/dev/null || exit 1

    git worktree add -q .claude/worktrees/closed-w closed-b 2>/dev/null || exit 1
    git worktree add -q .claude/worktrees/behind-w behind-b 2>/dev/null || exit 1
    git worktree add -q .claude/worktrees/live-w unresolved 2>/dev/null || exit 1
    # Unborn and EMPTY: the orphan checkout keeps the index, so clear it and
    # the files, leaving a tree the clean gate would pass.
    git worktree add -q --detach .claude/worktrees/ghost-w HEAD 2>/dev/null || exit 1
    git -C .claude/worktrees/ghost-w checkout -q --orphan ghost 2>/dev/null || exit 1
    git -C .claude/worktrees/ghost-w rm -rqf . >/dev/null 2>&1 || exit 1
    # The OPEN row on reopen-b names a head this clone never fetched: the veto
    # has to come from the branch name alone.
    printf 'CLOSED %s closed-b\nMERGED %s feature\nCLOSED %s reopen-b\nOPEN %s reopen-b\nCLOSED %s stack-b\nOPEN %s stack-top\n' \
      "$b" "$c" "$e" "$(printf '%040d' 7)" "$f" "$f" > "$shas"
  ) || { fail "containment: could not build the fixture"; return; }

  if ! git -C "$main" worktree list --porcelain | grep -q '^HEAD 0\{40\}$' ||
    [ -n "$(git -C "$main/.claude/worktrees/ghost-w" status --porcelain)" ]; then
    fail "containment: ghost-w is not an unborn, clean worktree"
    return
  fi

  # The script asks gh for `--json state,headRefOid,headRefName --jq ...`; the
  # shim stands in for the whole call and emits what that jq would have produced.
  cat > "$work/bin/gh" <<SHIM
#!/usr/bin/env bash
cat "$shas"
SHIM
  chmod +x "$work/bin/gh"

  backdate "$main/.claude/worktrees"

  out=$(cd "$main" && PATH="$work/bin:$PATH" CLAUDE_PROJECT_DIR="$main" \
    RECLAIM_DRY_RUN=1 RECLAIM_FORCE=1 RECLAIM_MIN_IDLE_MINUTES=0 \
    "$SCRIPT" </dev/null 2>&1)

  # Herestrings, not `printf | grep -q`: under pipefail a matching `grep -q`
  # exits while printf is still writing, printf takes SIGPIPE, and the pipeline
  # reports 141 even though the match succeeded, inverting the assertion. It
  # was not hypothetical: this loop once failed with `printf: write error:
  # Broken pipe` while its own failure dump printed the line it had just been
  # told was missing.
  for case in "closed-w:a PR closed unmerged" "behind-w:a branch behind the sha that merged"; do
    wt=${case%%:*}
    if grep -q "would remove .*$wt" <<<"$out"; then
      echo "✓ ${case#*:} is resolved by containment"
    else
      fail "containment missed ${case#*:} ($wt)"
      printf '%s\n' "$out" | sed 's/^/    /' >&2
    fi
  done

  # The ones that must survive. Asserting on "no-remove" rather than on the
  # absence of "would remove" keeps a fixture that never reached the decision
  # from passing as a success.
  for case in "live-w:a branch in no PR" "ghost-w:a HEAD this clone cannot resolve"; do
    wt=${case%%:*}
    if grep -q "no-remove $wt: unresolved" <<<"$out" &&
      ! grep -q "would remove .*$wt" <<<"$out"; then
      echo "✓ ${case#*:} is still kept"
    else
      fail "containment removed ${case#*:} ($wt)"
      printf '%s\n' "$out" | sed 's/^/    /' >&2
    fi
  done

  # A gh that wrote every row and then failed is discarded whole: a failure
  # partway through its pages could have lost an OPEN row, and with it a veto.
  cat > "$work/bin/gh" <<SHIM
#!/usr/bin/env bash
cat "$shas"
exit 1
SHIM
  failed=$(cd "$main" && PATH="$work/bin:$PATH" CLAUDE_PROJECT_DIR="$main" \
    RECLAIM_DRY_RUN=1 RECLAIM_FORCE=1 RECLAIM_MIN_IDLE_MINUTES=0 \
    "$SCRIPT" </dev/null 2>&1)
  if grep -q "gh pr list failed (exit 1)" <<<"$failed" &&
    ! grep -q "would remove" <<<"$failed"; then
    echo "✓ a failed gh call resolves nothing"
  else
    fail "a failed gh call was still trusted"
    printf '%s\n' "$failed" | sed 's/^/    /' >&2
  fi

  # Resolved by a closed PR, and vetoed by an open one: by branch, then by sha.
  for case in "reopen-w:a branch an open PR still names" "stack-w:a head an open PR still names"; do
    wt=${case%%:*}
    if grep -q "no-remove $wt: an open PR" <<<"$out" &&
      ! grep -q "would remove .*$wt" <<<"$out"; then
      echo "✓ ${case#*:} is still kept"
    else
      fail "containment removed ${case#*:} ($wt)"
      printf '%s\n' "$out" | sed 's/^/    /' >&2
    fi
  done
}

# A directory git no longer lists is reachable by neither tier above — they
# both walk `git worktree list` — so it is not skipped for a reason, it is
# never examined. The fixture is a plain directory: no `.git`, nothing
# registered.
#
# BOTH halves are asserted, and the second one carries the history: a
# reviewed-away version of this tier deleted what it found, and "git does not
# list it" turned out to be the wrong aim for an `rm -rf` in three separate
# ways (see ORPHANS in the script). So "it is named" is paired with "it is
# still there", and the pairing is what stops a future change from quietly
# turning a report back into a deletion.
check_orphan_report() {
  desc="an unregistered directory is named, not removed"
  work="$TMP/orphan"
  main="$work/main"
  orphan="$main/.claude/worktrees/left-behind"

  (
    init_repo "$main" || exit 1
    printf '/.claude/worktrees/\n' > .gitignore
    git add .gitignore
    git commit -q -m base || exit 1
    mkdir -p "$orphan/target/release" || exit 1
    : > "$orphan/target/release/sentinel"
  ) || { fail "$desc: could not build the fixture"; return; }

  if git -C "$main" worktree list --porcelain | grep -q "left-behind"; then
    fail "$desc: fixture is registered, so it is not an orphan"
    return
  fi

  backdate "$orphan"

  out=$(cd "$main" && CLAUDE_PROJECT_DIR="$main" RECLAIM_FORCE=1 \
    RECLAIM_NO_NETWORK=1 RECLAIM_MIN_IDLE_MINUTES=0 \
    "$SCRIPT" </dev/null 2>&1)

  # A detached `rm -rf` would land after the script exits, so give one a chance
  # to run before concluding the directory survived.
  n=0
  while [ -d "$orphan" ] && [ "$n" -lt 20 ]; do sleep 0.1; n=$((n + 1)); done

  if [ ! -d "$orphan" ] || [ ! -f "$orphan/target/release/sentinel" ]; then
    fail "$desc: the orphan was REMOVED; this tier must only report"
    printf '%s\n' "$out" | sed 's/^/    /' >&2
    return
  fi

  if grep -q "left-behind" <<<"$out"; then
    echo "✓ $desc"
  else
    fail "$desc: survived but was never named, so it stays invisible"
    printf '%s\n' "$out" | sed 's/^/    /' >&2
  fi
}

# A dry run may inspect an expired worktree record, but it must not prune that
# record from git's administrative directory — a dry run changes nothing. The
# checkout is deliberately missing and the record old enough for an ordinary
# `git worktree prune` to take it.
#
# `.claude/worktrees` must EXIST, or the script exits at "no worktree dir"
# long before it reaches the prune and this case passes against anything; the
# closing tally line is asserted to prove the run got to the end.
check_dry_run_preserves_worktree_metadata() {
  desc="a dry run preserves worktree metadata"
  work="$TMP/dry-run"
  main="$work/main"

  (
    init_repo "$main" || exit 1
    printf '/.claude/worktrees/\n' > .gitignore
    git add .gitignore
    git commit -q -m base || exit 1
    git worktree add -q -b stale .claude/worktrees/missing HEAD 2>/dev/null || exit 1
    admin=$(git rev-parse --path-format=absolute --git-path worktrees/missing) || exit 1
    rm -rf .claude/worktrees/missing
    backdate "$admin"
    printf '%s\n' "$admin" > "$work/admin-path"
  ) || { fail "$desc: could not build the fixture"; return; }

  admin=$(sed -n '1p' "$work/admin-path")
  before=$(git -C "$main" worktree list --porcelain)
  out=$(cd "$main" && CLAUDE_PROJECT_DIR="$main" RECLAIM_DRY_RUN=1 \
    RECLAIM_FORCE=1 RECLAIM_NO_NETWORK=1 "$SCRIPT" </dev/null 2>&1)
  status=$?
  after=$(git -C "$main" worktree list --porcelain)

  if [ "$status" -eq 0 ] && [ -d "$admin" ] && [ "$before" = "$after" ] &&
    grep -q "free now, low water" <<<"$out"; then
    echo "✓ $desc"
  else
    fail "$desc: the dry run pruned a stale worktree record, or never reached the prune"
    printf '%s\n' "$out" | sed 's/^/    /' >&2
  fi
}

# A throwaway superproject with a real submodule at `sub`, and one registered
# worktree under `.claude/worktrees` per name given (default `w1`), each with
# its submodule CHECKED OUT and sitting on main's commit so the ancestor signal
# resolves it. Sets $main and $wt (the first worktree) for the caller.
#
# The checkout is the whole fixture. `git worktree remove` refuses on a
# POPULATED submodule; an uninitialised gitlink removes plainly, so a fixture
# that skipped `submodule update` would pass against a script with no
# `--force` retry at all. The assertion at the bottom keeps it honest.
build_submodule_fixture() {
  work=$1; shift
  [ "$#" -gt 0 ] || set -- w1
  main="$work/main"
  wt="$main/.claude/worktrees/$1"
  mkdir -p "$work/bin" || return 1

  (
    init_repo "$work/upstream" || exit 1
    mkdir -p skills && echo skill > skills/SKILL.md
    git add skills || exit 1
    git commit -q -m base || exit 1
  ) || return 1

  (
    init_repo "$main" || exit 1
    printf '/.claude/worktrees/\n/target/\n' > .gitignore
    git add .gitignore
    git commit -q -m base || exit 1
    # file:// submodules are refused by default since git 2.38, and a local
    # path is the only kind a hermetic test can have.
    git -c protocol.file.allow=always submodule add -q "$work/upstream" sub \
      2>/dev/null || exit 1
    git commit -q -m submodule || exit 1
    for w in "$@"; do
      git worktree add -q -b "$w" ".claude/worktrees/$w" HEAD 2>/dev/null || exit 1
      git -C ".claude/worktrees/$w" -c protocol.file.allow=always \
        submodule update --init --quiet 2>/dev/null || exit 1
      mkdir -p ".claude/worktrees/$w/target/debug" || exit 1
      : > ".claude/worktrees/$w/target/debug/sentinel"
    done
  ) || return 1

  # ` <sha> sub (heads/main)` is populated; `-<sha>` is a gitlink nobody
  # checked out, and git removes that worktree without complaint.
  for w in "$@"; do
    case "$(git -C "$main/.claude/worktrees/$w" submodule status 2>/dev/null)" in
      " "*) ;;
      *) echo "fixture: sub is not populated in $w" >&2; return 1 ;;
    esac
  done
}

# The removal that silently did not happen. git refuses a worktree containing
# a submodule; a version of the script discarded that stderr and returned 1, so
# a dry run promising removals was followed by a real run that took none of
# them and said nothing. Keep the `--force` retry covered.
check_submodule_removal() {
  desc="a clean worktree with a populated submodule is removed"
  work="$TMP/submodule"
  build_submodule_fixture "$work" || { fail "$desc: could not build the fixture"; return; }

  backdate "$wt"

  out=$(cd "$main" && CLAUDE_PROJECT_DIR="$main" RECLAIM_FORCE=1 \
    RECLAIM_NO_NETWORK=1 RECLAIM_MIN_IDLE_MINUTES=0 \
    "$SCRIPT" </dev/null 2>&1)

  registered=$(git -C "$main" worktree list --porcelain)
  if [ -d "$wt" ] || grep -q "worktrees/w1" <<<"$registered"; then
    fail "$desc: it survived"
    printf '%s\n' "$out" | sed 's/^/    /' >&2
    return
  fi

  # --force is aimed at one worktree, but a submodule is shared-looking state:
  # prove the main checkout still has its own copy.
  if [ ! -f "$main/sub/skills/SKILL.md" ]; then
    fail "$desc: the main checkout's submodule went with it"
    return
  fi
  echo "✓ $desc"
}

# `--force` gives up git's own refusal on a dirty tree, so the script's clean
# check is the whole of the protection for a worktree with a submodule. Three
# resolved, idle worktrees, each dirty in exactly one way:
#   untracked      an untracked file at the top level
#   sub-modified   a tracked file edited INSIDE the submodule
#   sub-untracked  an untracked file INSIDE the submodule
# The submodule cases are not obvious — the dirt is in another repository —
# and the superproject reports each as one modified gitlink, ` M sub`. Every
# gate downstream reads that line.
#
# Run twice: with default config, and with config that hides each of those
# from a plain `git status --porcelain` (`status.showUntrackedFiles=no`,
# `diff.ignoreSubmodules=all`). User config must not make a dirty tree read
# clean, so the script spells its flags out.
#
# Both halves are asserted, as in the orphan tier: the dry run names the clean
# gate as the reason, and the real run leaves the files there. The COUNT is
# pinned too: one dirty thing is one porcelain line, the one width at which an
# off-by-one in the count once read as the contradiction "kept for 0 file(s)".
check_dirty_worktrees_survive() {
  config=$1
  desc="uncommitted work keeps a resolved worktree ($config config)"
  work="$TMP/dirty-$config"
  build_submodule_fixture "$work" untracked sub-modified sub-untracked ||
    { fail "$desc: could not build the fixture"; return; }

  wts="$main/.claude/worktrees"
  : > "$wts/untracked/scratch"
  echo edit >> "$wts/sub-modified/sub/skills/SKILL.md"
  : > "$wts/sub-untracked/sub/scratch"
  if [ "$config" = hostile ]; then
    git -C "$main" config status.showUntrackedFiles no
    git -C "$main" config diff.ignoreSubmodules all
    # Prove the config bites, or this case is the default one twice.
    for w in untracked sub-modified sub-untracked; do
      if [ -n "$(git -C "$wts/$w" status --porcelain)" ]; then
        fail "$desc: the hostile config does not hide $w's dirt"
        return
      fi
    done
  fi
  # AFTER the dirt, deliberately: at maxdepth 2 a fresh file is also what the
  # idle guard sees, and a fixture kept by that guard would be kept for a
  # reason that has nothing to do with being dirty.
  backdate "$wts"

  dry=$(cd "$main" && CLAUDE_PROJECT_DIR="$main" RECLAIM_DRY_RUN=1 \
    RECLAIM_FORCE=1 RECLAIM_NO_NETWORK=1 RECLAIM_MIN_IDLE_MINUTES=0 \
    "$SCRIPT" </dev/null 2>&1)
  (cd "$main" && CLAUDE_PROJECT_DIR="$main" RECLAIM_FORCE=1 \
    RECLAIM_NO_NETWORK=1 RECLAIM_MIN_IDLE_MINUTES=0 \
    "$SCRIPT" </dev/null) >/dev/null 2>&1

  ok=1
  for w in untracked sub-modified sub-untracked; do
    grep -q "no-remove $w: 1 uncommitted/untracked" <<<"$dry" || ok=0
  done
  [ -f "$wts/untracked/scratch" ] || ok=0
  grep -q edit "$wts/sub-modified/sub/skills/SKILL.md" 2>/dev/null || ok=0
  [ -f "$wts/sub-untracked/sub/scratch" ] || ok=0

  if [ "$ok" = 1 ]; then
    echo "✓ $desc"
  else
    fail "$desc: a dirty worktree was not held by the clean gate, or lost its work"
    printf '%s\n' "$dry" | sed 's/^/    dry: /' >&2
  fi
}

# THE RETRY'S OWN GATE: `--force` discards an unclean tree, so between the
# plain remove failing and the retry firing, the script re-asks whether the
# tree is still clean. That window is the reason the recheck exists — `du` of
# a multi-gigabyte worktree sits in it.
#
# No fixture reaches this gate on its own: the FIRST clean check returns long
# before, so a tree that starts dirty never gets here. The shim is what makes
# it reachable — it refuses the plain remove the way git's submodule refusal
# does, and changes the world on its way out:
#
#   dirty    the worktree acquires an untracked file as the remove is refused.
#   hidden   the same, under `status.showUntrackedFiles=no`: the recheck must
#            spell its flags out just as the first check does.
#   unknown  `git status` itself fails on the recheck. Its output is empty
#            either way, so an empty-output-is-clean test cannot tell "clean"
#            from "could not tell" — and would force on the second one.
#
# The assertion is that `--force` was never ATTEMPTED, not merely that the
# worktree survived: the shim refuses `--force` too, so survival alone would
# pass just as happily on a script that forced a dirty tree and was told no.
check_force_retry_gate() {
  mode=$1
  desc=$2
  work="$TMP/retry-$mode"
  build_submodule_fixture "$work" || { fail "$desc: could not build the fixture"; return; }
  [ "$mode" = hidden ] && git -C "$main" config status.showUntrackedFiles no

  real_git=$(command -v git)
  forced="$work/forced"
  marker="$work/refused-once"

  # The --force arm is FIRST: `git -C <root> worktree remove --force <path>`
  # matches the plain pattern too, and a case takes the first match.
  cat > "$work/bin/git" <<SHIM
#!/usr/bin/env bash
case "\$*" in
  *"worktree remove --force"*)
    : > "$forced"
    echo 'fatal: the retry should not have run' >&2
    exit 128 ;;
  *"worktree remove"*)
    : > "$marker"
    case "$mode" in dirty|hidden) : > "$wt/scratch.md" ;; esac
    echo 'fatal: working trees containing submodules cannot be moved or removed' >&2
    exit 128 ;;
  *"status --porcelain"*)
    # Only the RECHECK, so the first clean check still answers honestly and
    # the run gets as far as attempting a removal.
    if [ "$mode" = unknown ] && [ -e "$marker" ]; then
      exit 1
    fi ;;
esac
exec "$real_git" "\$@"
SHIM
  chmod +x "$work/bin/git"

  backdate "$wt"

  msg=$(cd "$main" && PATH="$work/bin:$PATH" CLAUDE_PROJECT_DIR="$main" \
    RECLAIM_FORCE=1 RECLAIM_NO_NETWORK=1 RECLAIM_MIN_IDLE_MINUTES=0 \
    RECLAIM_PRUNE_IDLE_MINUTES=0 "$SCRIPT" </dev/null 2>/dev/null)

  if [ ! -e "$marker" ]; then
    fail "$desc: the run never attempted a removal, so the gate never ran"
  elif [ -e "$forced" ]; then
    fail "$desc: --force ran anyway"
  elif [ ! -d "$wt" ] || ! grep -q 'REFUSED' <<<"$msg"; then
    fail "$desc: the worktree went, or the refusal was never reported"
  else
    echo "✓ $desc"
    return
  fi
  printf '%s\n' "${msg:-(no output at all)}" | sed 's/^/    /' >&2
}

# Whatever the next refusal turns out to be, it has to be audible. A dry-run
# note is no help — the dry run never attempts a removal — so the real run's
# systemMessage is the only channel, and it has to fire even on a run that
# freed nothing. The shim refuses every `worktree remove` and passes everything
# else to the real git.
check_refused_removal_is_audible() {
  desc="a removal git refuses is reported, not swallowed"
  work="$TMP/refused"
  build_submodule_fixture "$work" || { fail "$desc: could not build the fixture"; return; }

  real_git=$(command -v git)
  cat > "$work/bin/git" <<SHIM
#!/usr/bin/env bash
case "\$*" in
  *"worktree remove"*) echo 'fatal: refused by the test shim' >&2; exit 128 ;;
esac
exec "$real_git" "\$@"
SHIM
  chmod +x "$work/bin/git"

  backdate "$wt"

  msg=$(cd "$main" && PATH="$work/bin:$PATH" CLAUDE_PROJECT_DIR="$main" \
    RECLAIM_FORCE=1 RECLAIM_NO_NETWORK=1 RECLAIM_MIN_IDLE_MINUTES=0 \
    RECLAIM_PRUNE_IDLE_MINUTES=0 "$SCRIPT" </dev/null 2>/dev/null)

  if ! grep -q '"systemMessage"' <<<"$msg" ||
    ! grep -q 'REFUSED' <<<"$msg" ||
    ! grep -q 'w1' <<<"$msg"; then
    fail "$desc: the run said nothing a session would see"
    printf '%s\n' "${msg:-(no output at all)}" | sed 's/^/    /' >&2
    return
  fi

  # And the refusal must not cost the disk win: a worktree tier 2 could not
  # remove still falls through to tier 1.
  if [ -f "$wt/target/debug/sentinel" ]; then
    fail "$desc: a refused worktree stopped getting its cache pruned"
    return
  fi
  echo "✓ $desc"
}

# A registered worktree whose `.git` link is gone — partly deleted, or a
# session killed mid-teardown — is no longer a repository, so `git -C` and
# `lifecycle.py --repo` aimed at it walk up and answer for the MAIN checkout:
# its status as this tree's clean check, its build cache as this tree's. Run
# for real: the main checkout's cache and the broken tree must both survive,
# and the prune that follows turns the tree into an orphan the last tier names.
check_missing_git_link() {
  desc="a registered worktree without its .git link is left alone"
  work="$TMP/no-git-link"
  main="$work/main"
  wt="$main/.claude/worktrees/w1"

  (
    init_repo "$main" || exit 1
    printf '/.claude/worktrees/\n/target/\n' > .gitignore
    git add .gitignore
    git commit -q -m base || exit 1
    git worktree add -q -b w1 .claude/worktrees/w1 HEAD 2>/dev/null || exit 1
    mkdir -p target/debug "$wt/target/debug" || exit 1
    : > target/debug/sentinel
    : > "$wt/target/debug/sentinel"
    rm -f "$wt/.git"
  ) || { fail "$desc: could not build the fixture"; return; }

  backdate "$main/target"
  backdate "$wt"

  msg=$(cd "$main" && CLAUDE_PROJECT_DIR="$main" RECLAIM_FORCE=1 \
    RECLAIM_NO_NETWORK=1 RECLAIM_MIN_IDLE_MINUTES=0 \
    RECLAIM_PRUNE_IDLE_MINUTES=0 "$SCRIPT" </dev/null 2>/dev/null)

  if [ -f "$main/target/debug/sentinel" ] && [ -f "$wt/target/debug/sentinel" ] &&
    ! grep -q 'REFUSED' <<<"$msg" && grep -q 'unregistered.*w1' <<<"$msg"; then
    echo "✓ $desc"
  else
    fail "$desc"
    [ -f "$main/target/debug/sentinel" ] || echo "    the MAIN checkout's cache was pruned" >&2
    [ -f "$wt/target/debug/sentinel" ] || echo "    the broken worktree's cache was pruned" >&2
    printf '%s\n' "${msg:-(no output at all)}" | sed 's/^/    /' >&2
  fi
}

# Repositories run this script through a thin `.claude/reclaim-worktrees.sh`
# that does `exec bash <shared> "$@"`. ROOT, the main checkout and the
# session's cwd must resolve the same through it in all three ways it is run:
#   hook   SessionStart: JSON on stdin naming the session's cwd (here, inside
#          the worktree), CLAUDE_PROJECT_DIR set, invoked from elsewhere
#   sweep  session-lifecycle's owner adapter: empty stdin, no
#          CLAUDE_PROJECT_DIR, cwd the main checkout
#   hand   a hand-run from inside a worktree, which is then the session's own
check_wrapper() {
  work="$TMP/wrapper"
  main="$work/main"
  wt="$main/.claude/worktrees/w1"
  (
    init_repo "$main" || exit 1
    printf '/.claude/\n' > .gitignore
    git add .gitignore
    git commit -q -m base || exit 1
    git worktree add -q -b w1 .claude/worktrees/w1 HEAD 2>/dev/null || exit 1
    printf '#!/usr/bin/env bash\nexec bash "%s" "$@"\n' "$SCRIPT" > .claude/reclaim-worktrees.sh
    chmod +x .claude/reclaim-worktrees.sh
  ) || { fail "wrapper: could not build the fixture"; return; }
  backdate "$wt"
  wrapper="$main/.claude/reclaim-worktrees.sh"
  held="skip w1: this session is running in it"

  if command -v jq >/dev/null 2>&1; then
    out=$(cd / && printf '{"cwd":"%s"}' "$wt" | CLAUDE_PROJECT_DIR="$main" \
      RECLAIM_DRY_RUN=1 RECLAIM_FORCE=1 RECLAIM_NO_NETWORK=1 \
      RECLAIM_MIN_IDLE_MINUTES=0 "$wrapper" 2>&1)
    if grep -q "$held" <<<"$out" && ! grep -q "would remove" <<<"$out"; then
      echo "✓ through a wrapper, the hook's stdin names the session's worktree"
    else
      fail "through a wrapper, the hook's session cwd was lost"
      printf '%s\n' "$out" | sed 's/^/    /' >&2
    fi
  else
    echo "- skipped the hook-through-wrapper case: jq is not on PATH"
  fi

  out=$(cd "$main" && printf '' | env -u CLAUDE_PROJECT_DIR RECLAIM_DRY_RUN=1 \
    RECLAIM_FORCE=1 RECLAIM_NO_NETWORK=1 RECLAIM_MIN_IDLE_MINUTES=0 \
    bash "$wrapper" 2>&1)
  if grep -q "would remove .*w1" <<<"$out"; then
    echo "✓ through a wrapper, the sweep's call resolves the main checkout"
  else
    fail "through a wrapper, the sweep's call did not reach the worktree"
    printf '%s\n' "$out" | sed 's/^/    /' >&2
  fi

  out=$(cd "$wt" && env -u CLAUDE_PROJECT_DIR RECLAIM_DRY_RUN=1 \
    RECLAIM_FORCE=1 RECLAIM_NO_NETWORK=1 RECLAIM_MIN_IDLE_MINUTES=0 \
    "$wrapper" </dev/null 2>&1)
  if grep -q "$held" <<<"$out" && ! grep -q "would remove" <<<"$out"; then
    echo "✓ through a wrapper, a hand-run from a worktree spares that worktree"
  else
    fail "through a wrapper, a hand-run from a worktree did not spare it"
    printf '%s\n' "$out" | sed 's/^/    /' >&2
  fi
}

# A CLAIMED spare is a live session. Its argv is fixed at exec and still names
# the claim socket it was offered on, so argv alone cannot say it was taken —
# the socket being GONE from disk is what says so. This is the case that makes
# the difference between skipping a worktree and deleting one a session is
# paused in, and it is the reason a flag test is not enough.
check_spare "a claimed spare's lock is live" \
  "claude bg-spare --bg-spare SOCK" 0 \
  "locked by live pid"

# An UNCLAIMED spare is still advertising itself on that socket, so the socket
# is on disk and the lock protects nothing.
check_spare "an unclaimed spare's lock is stale" \
  "claude bg-spare --bg-spare SOCK" 1 \
  "stale lock"

# A process that is not a spare at all — a hand-run session, another tool —
# is taken at its word. Unrecognised means live, which is the safe direction.
check_spare "an unrecognised holder's lock is live" \
  "some-other-program --with args" 0 \
  "locked by live pid"

check_codex_ownership
check_handmade_lock
check_agent_lock inside "a Remote Control lock with a process inside is live" \
  "claude agent bridge-cse_01Test (pid 4242 start Thu Oct  1 09:00:00 2026)" \
  "skip w1: Remote Control lock, and a process is running in it"
check_agent_lock none "a Remote Control lock with nothing inside is stale" \
  "claude agent bridge-cse_01Test (pid 4242 start Thu Oct  1 09:00:00 2026)" \
  "would remove .*w1"
check_agent_lock none "a harness lock without a start time is still read" \
  "claude agent bridge-cse_01Test (pid 4242)" \
  "would remove .*w1"
check_agent_lock blind "a Remote Control lock is live when lsof cannot see its daemon" \
  "claude agent bridge-cse_01Test (pid 4242 start Thu Oct  1 09:00:00 2026)" \
  "skip w1: Remote Control lock, and lsof cannot show process cwds"
check_agent_lock gone "a Remote Control lock whose daemon is gone falls back to the script" \
  "claude agent bridge-cse_01Test (pid 4242 start Thu Oct  1 09:00:00 2026)" \
  "would remove .*w1"
check_agent_lock none "an Agent tool lock is read by its parent session's pid" \
  "claude agent agent-a0123456789abcdef (pid 4242 start Thu Oct  1 09:00:00 2026)" \
  "skip w1: locked by live pid 4242"
check_containment
check_orphan_report
check_dry_run_preserves_worktree_metadata
check_submodule_removal
check_dirty_worktrees_survive default
check_dirty_worktrees_survive hostile
check_force_retry_gate dirty \
  "a tree that goes dirty before the retry is not forced"
check_force_retry_gate hidden \
  "the retry's recheck is not fooled by status config"
check_force_retry_gate unknown \
  "a recheck that cannot answer is not read as clean"
check_refused_removal_is_audible
check_missing_git_link
check_wrapper

echo
if [ "$failures" -gt 0 ]; then
  echo "✗ $failures reclaimer case(s) failed" >&2
  exit 1
fi
echo "✓ reclaim-worktrees.sh keeps its ownership, lock and clean-tree boundaries"
