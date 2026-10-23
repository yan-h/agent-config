#!/bin/bash
# Link this checkout's Claude instructions into ~/.claude and its skills into
# ~/.claude/skills and ~/.agents/skills, install session-lifecycle's hourly
# sweep, set up the status line and ask-api, and install Remote Control at login
# where ~/.claude/remote-control-projects exists. Safe to rerun: it replaces only
# links, never a real file. Every rerun also restarts the sweep, which runs once at load.
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

# The status line, which a cloud session has no terminal to show. An existing different
# statusLine is the owner's choice and is left alone.
if ! $cloud; then
  link "$repo/global/claude/statusline.sh" "$HOME/.claude/statusline.sh"
  if ! python3 - "$HOME/.claude/settings.json" <<'EOF'
import json, os, sys
path = sys.argv[1]
want = {"type": "command", "command": "~/.claude/statusline.sh", "refreshInterval": 2}
settings = {}
if os.path.exists(path):
    with open(path) as f:
        settings = json.load(f)
have = settings.get("statusLine")
if have is None:
    settings["statusLine"] = want
    with open(path + ".tmp", "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")
    os.replace(path + ".tmp", path)
elif have != want:
    print(f"install: {path} has another statusLine; left as it is", file=sys.stderr)
EOF
  then
    echo "install: the status line is not set up: updating settings.json failed (above)" >&2
    status=1
  fi
  command -v jq >/dev/null || { echo "install: the status line needs jq, which is not on PATH" >&2; status=1; }
fi

# Remote Control at login, only where the owner has listed projects for it: the list is
# per machine and stays out of this repository. The agent is reloaded only when its plist
# changed; the reload is harmless anyway, since the script skips every tmux window that exists.
rc_list="$HOME/.claude/remote-control-projects"
if ! $cloud && [ -e "$rc_list" ]; then
  agent="$HOME/Library/LaunchAgents/com.yan.claude-remote-control.plist"
  link "$repo/global/claude/remote-control-at-login.sh" "$HOME/.claude/remote-control-at-login.sh"
  if ! cmp -s "$repo/global/claude/com.yan.claude-remote-control.plist" "$agent" ||
     ! launchctl print "gui/$(id -u)/com.yan.claude-remote-control" >/dev/null 2>&1; then
    mkdir -p "${agent%/*}"
    launchctl bootout "gui/$(id -u)/com.yan.claude-remote-control" 2>/dev/null
    if ! { cp "$repo/global/claude/com.yan.claude-remote-control.plist" "$agent" &&
           launchctl bootstrap "gui/$(id -u)" "$agent"; }; then
      echo "install: Remote Control at login is not set up: copying or loading its LaunchAgent failed" >&2
      status=1
    fi
  fi
  command -v tmux >/dev/null || { echo "install: Remote Control at login needs tmux, which is not on PATH" >&2; status=1; }
elif ! $cloud; then
  echo "install: Remote Control at login skipped: list projects in $rc_list and rerun to enable it"
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
