#!/bin/bash
# Link this checkout's Claude instructions into ~/.claude and its skills into
# ~/.claude/skills and ~/.agents/skills, install session-lifecycle's hourly
# sweep and the quota poller, and set up ask-api. Safe to rerun: it replaces only
# links, never a real file. Every rerun also restarts the sweep and the poller,
# which each run once at load.
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

# The hourly sweep, which a cloud environment neither needs nor can schedule.
if ! $cloud && ! python3 "$repo/skills/session-lifecycle/scripts/install.py" ${repos[@]+"${repos[@]}"}; then
  echo "install: session-lifecycle's hourly sweep is not set up: its installer failed (above)" >&2
  status=1
fi

# The quota poller, which a cloud environment neither needs nor can schedule. bootout first
# so a rerun loads the current plist, as the sweep's installer does.
if ! $cloud; then
  agent="$HOME/Library/LaunchAgents/com.yan.claude-quota.plist"
  link "$repo/global/claude/quota-poll.sh" "$HOME/.claude/quota-poll.sh"
  mkdir -p "${agent%/*}"
  launchctl bootout "gui/$(id -u)/com.yan.claude-quota" 2>/dev/null
  if ! { cp "$repo/global/claude/com.yan.claude-quota.plist" "$agent" &&
         launchctl bootstrap "gui/$(id -u)" "$agent"; }; then
    echo "install: the quota poller is not set up: copying or loading its LaunchAgent failed" >&2
    status=1
  fi
  command -v jq >/dev/null ||
    { echo "install: the quota poller needs jq, which is not on PATH; every poll will fail" >&2; status=1; }
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
