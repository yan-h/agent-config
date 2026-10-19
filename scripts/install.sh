#!/bin/bash
# Link this checkout's Claude instructions into ~/.claude and its skills into
# ~/.claude/skills and ~/.agents/skills, install session-lifecycle's hourly
# sweep, and set up ask-api. Safe to rerun: it replaces only links, never a
# real file.
# --repo PATH (repeatable): a project for the sweep to cover. A rerun keeps the
# projects already registered, so only a new machine or project needs it.
# --cloud: also installs ask-api into /usr/local/bin and adds a SessionStart hook
# that pulls this checkout, for the setup script of a Claude Code cloud environment.
set -u

repo=$(cd "$(dirname "$0")/.." && pwd -P)
bin="$HOME/.local/bin"
cloud=false
repos=()
while [ $# -gt 0 ]; do
  case $1 in
    --cloud) cloud=true; bin=/usr/local/bin ;;
    --repo) repos+=(--repo "${2:?install: --repo needs a path}"); shift ;;
    *) echo "install: unknown argument $1" >&2; exit 2 ;;
  esac
  shift
done
status=0

link() {  # link TARGET LINK
  if [ -e "$2" ] && [ ! -L "$2" ]; then
    echo "install: skipped $2: a real file is there; move it aside and rerun" >&2
    status=1
    return
  fi
  ln -sfn "$1" "$2"
}

mkdir -p "$HOME/.claude/skills" "$HOME/.agents/skills" "$bin"
link "$repo/global/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
# Both catalogs: Codex reads ~/.agents/skills, and so do the projects' own
# wrappers that run a shared script (session-lifecycle.sh, reclaim-worktrees.sh).
for catalog in "$HOME/.claude/skills" "$HOME/.agents/skills"; do
  for skill in "$repo"/skills/*/; do
    skill=${skill%/}
    link "$skill" "$catalog/${skill##*/}"
  done
  # A skill removed from the repository leaves a dangling link behind.
  for entry in "$catalog"/*; do
    if [ -L "$entry" ] && [ ! -e "$entry" ] && [[ $(readlink "$entry") == "$repo"/skills/* ]]; then
      rm "$entry"
    fi
  done
done

# session-lifecycle needs Python 3.11 (tomllib), and macOS ships 3.9 as
# python3. Without this check a new machine got the skill links, no sweep, and
# a traceback only when a session first ran a build through the helper.
if ! $cloud; then
  if ! python3 -c 'import sys; sys.exit(sys.version_info < (3, 11))' 2>/dev/null; then
    echo "install: session-lifecycle is not set up: python3 is $(python3 -V 2>&1 || echo missing), and it needs 3.11+;" \
      "install a newer one (brew install python) and rerun" >&2
    status=1
  elif ! python3 "$repo/skills/session-lifecycle/scripts/install.py" ${repos[@]+"${repos[@]}"}; then
    echo "install: session-lifecycle is not set up: its installer failed (above)" >&2
    status=1
  fi
fi

# ask-api is optional: a failure here must not cost the instructions and skills above.
venv="$HOME/.local/share/ask-api/venv"
if { [ -x "$venv/bin/python" ] || python3 -m venv "$venv"; } &&
  "$venv/bin/pip" install -q --disable-pip-version-check --upgrade anthropic; then
  link "$repo/skills/api-second-opinion/scripts/ask-api" "$bin/ask-api"
else
  echo "install: ask-api is not set up: creating its venv or installing anthropic failed" >&2
  status=1
fi

if $cloud; then
  settings="$HOME/.claude/settings.json"
  if [ -e "$settings" ]; then
    echo "install: $settings exists; not adding the pull hook" >&2
  else
    cat >"$settings" <<EOF
{
  "hooks": {
    "SessionStart": [
      { "hooks": [{ "type": "command", "command": "git -C '$repo' pull -q --ff-only || true" }] }
    ]
  }
}
EOF
  fi
  # A cloud environment fails to start when its setup script exits non-zero.
  exit 0
fi
exit $status
