#!/bin/bash
# Link this checkout's Claude instructions and skills into ~/.claude and set up
# ask-api. Safe to rerun: it replaces only links, never a real file.
# --cloud: also installs ask-api into /usr/local/bin and adds a SessionStart hook
# that pulls this checkout, for the setup script of a Claude Code cloud environment.
set -u

repo=$(cd "$(dirname "$0")/.." && pwd -P)
bin="$HOME/.local/bin"
cloud=false
if [ "${1:-}" = "--cloud" ]; then
  cloud=true
  bin=/usr/local/bin
fi
status=0

link() {  # link TARGET LINK
  if [ -e "$2" ] && [ ! -L "$2" ]; then
    echo "install: skipped $2: a real file is there; move it aside and rerun" >&2
    status=1
    return
  fi
  ln -sfn "$1" "$2"
}

mkdir -p "$HOME/.claude/skills" "$bin"
link "$repo/global/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
for skill in "$repo"/skills/*/; do
  skill=${skill%/}
  link "$skill" "$HOME/.claude/skills/${skill##*/}"
done
# A skill removed from the repository leaves a dangling link behind.
for entry in "$HOME"/.claude/skills/*; do
  if [ -L "$entry" ] && [ ! -e "$entry" ] && [[ $(readlink "$entry") == "$repo"/skills/* ]]; then
    rm "$entry"
  fi
done

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
