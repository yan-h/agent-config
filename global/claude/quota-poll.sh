#!/bin/zsh
# Append the subscription quota meters, as `claude -p /usage` reports them, to
# ~/.claude/quota-usage.jsonl. Run every 5 minutes by com.yan.claude-quota.plist.
# Each row is a fresh account-wide reading, so readers need no max-so-far envelope across
# sessions, unlike the status line's per-session values. /usage is a local command: it sends
# no model request and costs no quota.
# Row: {"t":<epoch>,"five_hour":{"used":6,"resets":"Oct 23 at 1:39pm (America/Los_Angeles)"},
#       "seven_day":{...},"seven_day_fable":{...}}; a meter with an unknown label keeps the label.
set -u

# launchd starts agents with a bare environment: no Homebrew or ~/.local/bin on PATH, no locale.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
export LANG="${LANG:-en_US.UTF-8}"

out="${QUOTA_USAGE_FILE:-$HOME/.claude/quota-usage.jsonl}"
log="$HOME/.claude/quota-poll.log"
t=$(date +%s)

# Without --no-session-persistence every poll would leave a transcript in ~/.claude/projects.
# --bare cannot be used: it drops the subscription login, and /usage then reports no meters.
if ! reply=$(cd "$HOME" && claude -p /usage --output-format json --no-session-persistence 2>&1); then
  print -r -- "$(date '+%F %T') claude -p /usage failed: ${reply[1,500]}" >>"$log"
  exit 1
fi

row=$(jq -c --argjson t "$t" '
  {"Current session": "five_hour",
   "Current week (all models)": "seven_day",
   "Current week (Fable)": "seven_day_fable"} as $names
  | [.result | splits("\n")
     | capture("^(?<k>[^:]+): (?<used>[0-9.]+)% used · resets (?<resets>.+)$")
     | {($names[.k] // .k): {used: (.used | tonumber), resets}}]
  | if length == 0 then empty else {t: $t} + add end' <<<"$reply" 2>&1)

# No meter lines: a login problem or a changed /usage format. Log it rather than write a
# row of nothing, so a gap in the data has an explanation.
if [[ -z $row || $row != \{* ]]; then
  print -r -- "$(date '+%F %T') no meters in /usage reply: ${${row:-$reply}[1,500]}" >>"$log"
  exit 1
fi
print -r -- "$row" >>"$out"
