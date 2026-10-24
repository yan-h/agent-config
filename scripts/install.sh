#!/bin/bash
# Link this checkout's Claude instructions into ~/.claude and its skills into
# ~/.claude/skills and ~/.agents/skills, install session-lifecycle's hourly
# sweep, set up the status line, the subagent wait guard and ask-api, and
# install Remote Control at login
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

# A cloud environment's settings.json gets the hook that pulls this checkout, but
# only when this script creates the file.
settings="$HOME/.claude/settings.json"
if $cloud; then
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
fi

# settings.json also gets the status line, which a cloud session has no terminal to
# show (an existing different statusLine is the owner's choice and is left alone),
# and the PreToolUse hook that refuses subagents' waits past their five-minute prompt
# cache, whose matcher a rerun keeps current.
$cloud || link "$repo/global/claude/statusline.sh" "$HOME/.claude/statusline.sh"
link "$repo/global/claude/subagent-wait-guard.sh" "$HOME/.claude/subagent-wait-guard.sh"
if ! python3 - "$settings" "$cloud" <<'EOF'
import json, os, shutil, sys
# realpath: replacing a symlinked settings.json would turn the link into a copy.
path = os.path.realpath(sys.argv[1])
settings = {}
if os.path.exists(path):
    with open(path) as f:
        text = f.read()
    settings = json.loads(text) if text.strip() else {}
before = json.dumps(settings, sort_keys=True)
if sys.argv[2] != "true":
    want = {"type": "command", "command": "~/.claude/statusline.sh", "refreshInterval": 2}
    have = settings.get("statusLine")
    if have is None:
        settings["statusLine"] = want
    elif have != want:
        print(f"install: {path} has another statusLine; left as it is", file=sys.stderr)
guard = "~/.claude/subagent-wait-guard.sh"
matcher = "Bash|Monitor|ScheduleWakeup|CronCreate"
groups = settings.setdefault("hooks", {}).setdefault("PreToolUse", [])
mine = [g for g in groups if any(h.get("command") == guard for h in g.get("hooks", []))]
for g in mine:
    g["matcher"] = matcher
if not mine:
    groups.append({"matcher": matcher, "hooks": [{"type": "command", "command": guard}]})
if json.dumps(settings, sort_keys=True) != before:
    with open(path + ".tmp", "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")
    if os.path.exists(path):   # keep its mode: settings can hold tokens in env
        shutil.copymode(path, path + ".tmp")
    os.replace(path + ".tmp", path)
EOF
then
  echo "install: the status line and subagent wait guard are not set up: updating settings.json failed (above)" >&2
  status=1
fi
# Without jq the status line is blank and the wait guard allows every call.
command -v jq >/dev/null || { echo "install: the status line and subagent wait guard need jq, which is not on PATH" >&2; status=1; }

# Remote Control at login, only where the owner has listed projects for it: the list is
# per machine and stays out of this repository. The agent is reloaded only when its plist
# changed or it is not loaded: bootstrap straight after bootout can fail with error 5 while
# launchd is still tearing the job down, and an ordinary rerun need not risk that.
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

# A cloud environment fails to start when its setup script exits non-zero.
$cloud && exit 0
exit $status
