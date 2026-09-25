#!/bin/zsh
# Start `claude remote-control` in each project listed in ~/.claude/remote-control-projects,
# one window per project in the tmux session `claude-rc`. Run at login by
# com.yan.claude-remote-control.plist; safe to rerun, since it skips projects whose window exists.
# List format: one directory per line, optionally followed by `claude remote-control` flags
# (e.g. `~/projects/app --spawn worktree`); `~` and shell quoting allowed, `#` starts a comment.
set -u

# launchd starts agents with a bare environment: no Homebrew or ~/.local/bin on PATH, no locale.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
export LANG="${LANG:-en_US.UTF-8}"

exec >>"$HOME/.claude/remote-control-at-login.log" 2>&1
print -r -- "--- $(date '+%F %T')"

list="${CLAUDE_RC_PROJECTS:-$HOME/.claude/remote-control-projects}"
session=claude-rc

if [[ ! -r $list ]]; then
  print "no project list at $list"
  exit 1
fi

# At login the network can lag behind the agent; give it a minute before starting servers.
for _ in {1..30}; do
  curl -sI --max-time 3 https://api.anthropic.com >/dev/null && break
  sleep 2
done

while IFS= read -r line || [[ -n $line ]]; do
  line="${line%%\#*}"
  line="${line##[[:space:]]#}"
  line="${line%%[[:space:]]#}"
  [[ -z $line ]] && continue
  words=("${(Q@)${(z)line}}")
  dir="${words[1]/#\~/$HOME}"
  name="${dir:t}"

  if [[ ! -d $dir ]]; then
    print "skip $dir: not a directory"
    continue
  fi
  if tmux list-windows -t "$session" -F '#W' 2>/dev/null | grep -qxF -- "$name"; then
    print "skip $name: window already running"
    continue
  fi

  # Leave a shell behind when the server exits, so its last output stays readable in the window.
  cmd="claude remote-control ${(j: :)${(@q)words[2,-1]}}; exec \"\$SHELL\" -l"
  if tmux has-session -t "$session" 2>/dev/null; then
    tmux new-window -d -t "$session:" -n "$name" -c "$dir" "$cmd"
  else
    tmux new-session -d -s "$session" -n "$name" -c "$dir" "$cmd"
  fi
  print "started $name in $dir"
done <"$list"
