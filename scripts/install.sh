#!/bin/bash
# Link this checkout's global instructions into Claude (~/.claude/CLAUDE.md),
# Codex (~/.codex/AGENTS.md), and Gemini CLI and Antigravity (~/.gemini/GEMINI.md),
# and its skills into ~/.claude/skills, ~/.agents/skills and
# ~/.gemini/config/skills, install session-lifecycle's hourly sweep, set up the
# status line, the subagent wait guard, auto mode's standing rules, a SessionStart
# hook that pulls this checkout and ask-api, and
# install Remote Control at login where ~/.claude/remote-control-projects exists. Safe to rerun: it replaces only
# links, never a real file. Every rerun also restarts the sweep, which runs once at load.
# --repo PATH (repeatable): a project for the sweep to cover. A rerun keeps the
# projects already registered, so only a new machine or project needs it.
# --cloud: installs ask-api into /usr/local/bin instead, and leaves out the sweep,
# the status line and Remote Control, for the setup script of a Claude Code cloud environment.
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

mkdir -p "$HOME/.claude/skills" "$HOME/.agents/skills" "$HOME/.gemini/config/skills" \
  "$HOME/.codex" "$bin"
link "$repo/global/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
link "$repo/global/AGENTS.md" "$HOME/.codex/AGENTS.md"
# Antigravity loads ~/.gemini/GEMINI.md as a global rule, as Gemini CLI does; a
# second copy under ~/.gemini/config/rules would load the file twice.
link "$repo/global/AGENTS.md" "$HOME/.gemini/GEMINI.md"
# Codex and the projects' own wrappers that run a shared script
# (session-lifecycle.sh, reclaim-worktrees.sh) read ~/.agents/skills;
# Antigravity reads ~/.gemini/config/skills.
for catalog in "$HOME/.claude/skills" "$HOME/.agents/skills" "$HOME/.gemini/config/skills"; do
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

# settings.json gets the status line, which a cloud session has no terminal to
# show (an existing different statusLine is the owner's choice and is left alone),
# a year of transcript retention, which a cloud container does not outlive,
# the PreToolUse hook that refuses subagents' waits past their five-minute prompt
# cache, whose matcher a rerun keeps current, auto mode's standing rules from
# global/claude/auto-mode.json, and the SessionStart hook that pulls this checkout,
# so a merged rule reaches the next session; the hook is matched by its git command
# and folder name so a moved checkout updates it.
settings="$HOME/.claude/settings.json"
$cloud || link "$repo/global/claude/statusline.sh" "$HOME/.claude/statusline.sh"
link "$repo/global/claude/subagent-wait-guard.sh" "$HOME/.claude/subagent-wait-guard.sh"
mkdir -p "$HOME/.claude/agents"
link "$repo/global/claude/agents/resumable.md" "$HOME/.claude/agents/resumable.md"
if ! python3 - "$settings" "$cloud" "$repo" <<'EOF'
import json, os, shlex, shutil, sys
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
    # Claude Code deletes transcripts after 30 days by default, which leaves nothing
    # to compare a new model against. An existing value is the owner's choice.
    settings.setdefault("cleanupPeriodDays", 365)
# Auto mode reads its rules from user settings, never from a project's, so they
# are installed here. Each entry is written under one tag: a rerun replaces this
# checkout's entries and keeps any the owner added on this machine. A list he set
# without "$defaults" has replaced the built-in rules on purpose, and stays without them.
tag = "[agent-config] "
with open(os.path.join(sys.argv[3], "global/claude/auto-mode.json")) as f:
    rules = json.load(f)
lists = ("environment", "allow", "soft_deny", "hard_deny")
if set(rules) - set(lists):
    sys.exit(f"install: auto-mode.json: its keys are among {lists}, not {sorted(set(rules) - set(lists))}")
auto = settings.get("autoMode", {})
for key in lists:
    if key in auto or key in rules:
        auto[key] = ([e for e in auto.get(key, ["$defaults"]) if not e.startswith(tag)]
                     + [tag + e for e in rules.get(key, [])])
if auto:
    settings["autoMode"] = auto
guard = "~/.claude/subagent-wait-guard.sh"
matcher = "Bash|Monitor|ScheduleWakeup|CronCreate"
groups = settings.setdefault("hooks", {}).setdefault("PreToolUse", [])
mine = [g for g in groups if any(h.get("command") == guard for h in g.get("hooks", []))]
for g in mine:
    g["matcher"] = matcher
if not mine:
    groups.append({"matcher": matcher, "hooks": [{"type": "command", "command": guard}]})
repo = sys.argv[3]
pull = f"git -C {shlex.quote(repo)} pull -q --ff-only || true"
def pulls_this(command):
    # A checkout moved to a new path keeps its folder name; a hook that
    # pulls another repository the same way is someone else's.
    try:
        words = shlex.split(command)
    except ValueError:
        return False
    return (len(words) == 8 and words[:2] == ["git", "-C"]
            and words[3:] == ["pull", "-q", "--ff-only", "||", "true"]
            and os.path.basename(words[2].rstrip("/")) == os.path.basename(repo))
starts = settings["hooks"].setdefault("SessionStart", [])
mine = [h for g in starts for h in g.get("hooks", []) if pulls_this(h.get("command", ""))]
for h in mine:
    h["command"] = pull
if not mine:
    starts.append({"hooks": [{"type": "command", "command": pull}]})
if json.dumps(settings, sort_keys=True) != before:
    with open(path + ".tmp", "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")
    if os.path.exists(path):   # keep its mode: settings can hold tokens in env
        shutil.copymode(path, path + ".tmp")
    os.replace(path + ".tmp", path)
EOF
then
  echo "install: the status line, transcript retention, auto mode rules, subagent wait guard and pull hook are not set up: updating settings.json failed (above)" >&2
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
