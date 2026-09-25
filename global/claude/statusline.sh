#!/usr/bin/env bash
# Claude Code status line: cwd:branch · model · effort · ⚙agents · context · 5h quota (reset) · 7d quota (reset).
# Reads session JSON on stdin; derives context, effort and running background agents from
# the session transcript. The payload has no field for any of those three.
input=$(cat)

# --- fields from the status-line JSON on stdin (one jq call) ---
# One value per line (jq comma-separated + -r), read line-by-line. This preserves empty
# fields positionally with no delimiter — a tab/space IFS would collapse empty columns
# and misalign the optional rate fields when one is present and the other absent.
{
  IFS= read -r model
  IFS= read -r mid
  IFS= read -r transcript
  IFS= read -r dir
  IFS= read -r ex
  IFS= read -r rate5h
  IFS= read -r reset5h
  IFS= read -r rate7d
  IFS= read -r reset7d
  IFS= read -r sid
} < <(
  jq -r '.model.display_name // "?",
         (.model.id // "" | ascii_downcase),
         .transcript_path // "",
         .workspace.current_dir // ".",
         (.exceeds_200k_tokens // false | tostring),
         (.rate_limits.five_hour.used_percentage // "" | tostring),
         (.rate_limits.five_hour.resets_at        // "" | tostring),
         (.rate_limits.seven_day.used_percentage  // "" | tostring),
         (.rate_limits.seven_day.resets_at        // "" | tostring),
         .session_id // ""' <<<"$input"
)

# --- quota probe: append the account-wide quota meter whenever it MOVES ----------------
# The 5h/7d percentages are the only readable measure of what a subscription request
# costs; a transcript records tokens and never quota. Appended on CHANGE only — the
# status line re-renders every 2s in every open session, so logging every render would
# write megabytes an hour and carry no more information. QUOTA_PROBE=0 switches it off.
# "Change" is per SESSION: each session shows the meter as of its own last API response,
# so comparing against the file's last line (as this once did) logged every interleaving
# of parallel sessions' stale values — 3.2M rows by Sep 2026. `sid` ties a row to its
# session's transcript; readers still take a max-so-far envelope across sessions.
if [ "${QUOTA_PROBE:-1}" = 1 ] && [ -n "$rate5h$rate7d" ]; then
  _ql="${QUOTA_PROBE_FILE:-$HOME/.claude/quota-probe.jsonl}"
  _cur="\"five_hour\":${rate5h:-null},\"seven_day\":${rate7d:-null}"
  _key="$_cur,$reset5h,$reset7d"
  _last="${TMPDIR:-/tmp}/quota-probe-${sid:-nosid}"
  _prev=""; [ -f "$_last" ] && IFS= read -r _prev <"$_last"
  if [ "$_prev" != "$_key" ]; then
    printf '{"t":%s,"sid":"%s","model":"%s",%s,"reset5h":%s,"reset7d":%s}\n' \
      "$(date +%s)" "$sid" "${mid:-?}" "$_cur" "${reset5h:-null}" "${reset7d:-null}" \
      >>"$_ql" 2>/dev/null
    printf '%s\n' "$_key" >"$_last" 2>/dev/null
  fi
fi

# --- context window: from Anthropic's Models API (max_input_tokens), cached on disk ---
# The status line renders constantly, so this NEVER blocks on the network: a missing or
# stale catalog is refreshed in the BACKGROUND and the static table below covers this
# render. Needs the `ant` CLI (brew install anthropics/tap/ant, then `ant auth login`);
# without it the table is used forever and nothing breaks.
now=$(date +%s)
ctx_dir="$HOME/.claude/cache/ctxwin"
ctx_db="$ctx_dir/models.jsonl"
ctx_stamp="$ctx_dir/.attempt"

ctx_age() {   # $1 = file → seconds since its mtime, or a huge number if it's absent
  local m
  m=$(stat -f %m "$1" 2>/dev/null) || m=$(stat -c %Y "$1" 2>/dev/null) || { echo 999999999; return; }
  echo $(( now - m ))
}

# Offline fallback — consulted only when the catalog has no entry for this model.
ctx_fallback() {
  case "$1" in
    *1m*)                                                       echo 1000000 ;;
    *fable*|*mythos*|*opus-5*|*opus-4-7*|*opus-4-8*|*sonnet-5*) echo 1000000 ;;
    *)                                                          echo 200000  ;;
  esac
}

# Match $mid against the catalog, tolerating date suffixes in EITHER direction: the
# catalog lists older models dated (claude-sonnet-4-5-20250929) while Claude Code
# reports the bare alias, and newer models the other way round. Exact match wins, then
# the longest prefix match.
# `.i as $i` is load-bearing: inside startswith's argument `.` is the piped string,
# not the object, so a bare `.id` there throws and silently drops us to the fallback.
limit=$(jq -rn --arg m "$mid" '
  [inputs | select(.max_input_tokens != null)
          | {i: .id, t: .max_input_tokens}
          | select(.i as $i | $m == $i
                              or ($m | startswith($i + "-"))
                              or ($i | startswith($m + "-")))]
  | sort_by([(if .i == $m then 1 else 0 end), (.i | length)])
  | (last // empty) | .t' "$ctx_db" 2>/dev/null)
case "$limit" in ''|*[!0-9]*) limit=$(ctx_fallback "$mid") ;; esac

# Refresh a stale catalog (30d) in the background, backing off 6h between attempts so a
# missing or unauthenticated `ant` doesn't respawn a process on every single render.
if [ "$(ctx_age "$ctx_db")" -ge 2592000 ] && [ "$(ctx_age "$ctx_stamp")" -ge 21600 ]; then
  mkdir -p "$ctx_dir" 2>/dev/null
  : > "$ctx_stamp"        # claim the slot BEFORE forking so parallel renders don't pile up
  if command -v ant >/dev/null 2>&1; then
    ( t="$ctx_db.$$"
      ant models list --transform '{id,max_input_tokens}' --format jsonl > "$t" \
        && [ -s "$t" ] && mv -f "$t" "$ctx_db" || rm -f "$t"
    ) </dev/null >/dev/null 2>&1 &   # all three fds detached: never holds the prompt open
  fi
fi

[ "$ex" = "true" ] && limit=1000000

# --- context tokens, live effort, and running subagents, from the transcript ---
# Context and effort come from the last main-chain turn.
#
# Subagents are ASYNC, and that governs the whole design here. The Agent tool does not run
# one; it launches one and returns an id within a couple of seconds ("Async agent launched
# successfully"), then the agent lives in the background and reports back much later as a
# <task-notification>. So a tool_use still missing its tool_result marks only the LAUNCH,
# never the run — a ~2s window, shorter than the refresh, which is why pairing those two is
# the tempting reading and the wrong one.
#
# The real span is launch id → its notification: collect every `agentId:` handed back, drop
# every id a <task-id> has since reported on, and whatever is left is genuinely still
# running. Both markers are scanned on EVERY line type rather than on user lines alone — a
# completion is delivered on whichever line the harness happens to queue it to
# (`queue-operation` is a real one), and narrowing the scan to `user` silently loses those,
# which shows up as an agent that starts and never stops.
#
# The scan is gated on the session having a subagents/ directory at all. Serialising each
# line to match text against it is the one expensive thing this script does — it doubled the
# render on a heavy transcript — and a session that has never launched an agent has no id to
# find. The directory is created with the first agent, so the common case pays nothing and
# only sessions that actually use agents carry the cost.
used=0; effort="?"; live_ids=""
_scan=0; [ -d "${transcript%.jsonl}/subagents" ] && _scan=1
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  read -r used effort live_ids < <(
    tail -n 400 "$transcript" 2>/dev/null | jq -rn --argjson scan "$_scan" '
      reduce inputs as $l ({u:null,e:null,launch:{},done:{}};
        (if ($l.type == "assistant" and $l.isSidechain != true) then
           (if $l.message.usage != null
              then .u = ($l.message.usage.input_tokens
                         + $l.message.usage.cache_creation_input_tokens
                         + $l.message.usage.cache_read_input_tokens)
              else . end)
           | (if $l.effort != null then .e = $l.effort else . end)
         else . end)
        | (if ($scan == 0 or $l.type == "assistant") then . else
             ($l | tostring) as $s
             | if ($s | test("agentId: |<task-id>")) then
                 .launch += ([$s | scan("agentId: ([0-9a-f]{8,})") | {(.[0]): true}] | add // {})
                 | .done += ([$s | scan("<task-id>([0-9a-z]{8,})</task-id>") | {(.[0]): true}] | add // {})
               else . end
           end))
      | . as $x
      | ([$x.launch | keys[] | select($x.done[.] | not)] | join(" ")) as $run
      | "\($x.u // 0) \($x.e // "?") \($run)"' 2>/dev/null
  )
fi
: "${used:=0}"; : "${effort:=?}"

# The bar reports HOW MANY agents are working, not which — the count is the honest unit.
# A name reads as identity ("you are talking to this"), and no such state exists: the
# payload's own `agent.name` is the main-thread type, measured constant at "claude" across
# every session, so nothing here tracks a selection. What does vary is background work.
#
# <session>/subagents/agent-<id>.meta.json is the CHECK: an id with no meta beside THIS
# session is not this session's agent. The scan above matches a text pattern, and text is
# quotable — a transcript that merely discusses an id (debugging this very segment does it)
# would otherwise raise a phantom that never clears, since no completion for it can arrive.
# Only the file's EXISTENCE is needed, never its contents, so this costs no fork at all.
#
# An agent is also dropped once its own transcript has been quiet for 300s. A completion
# NOTIFICATION is the clean signal, but it is not guaranteed: an agent that is stopped, or
# dies, files none, and its launch line then holds the segment on screen until it scrolls
# out of the window — indistinguishable, to a reader, from work still in progress.
# 300s rather than the ~90s the write-gap distribution alone would suggest, because the gap
# that matters is a build: a release build in a cold worktree runs to 3.6 minutes here and
# an agent writes NOTHING while it waits, so a tighter bound would blink the segment off in
# the middle of exactly the long job worth watching. The cost is that a dead agent can lie
# for five minutes, which beats lying until 400 lines scroll past.
running=0
for _id in $live_ids; do
  _a="${transcript%.jsonl}/subagents/agent-${_id}"
  [ -f "$_a.meta.json" ] || continue
  _m=$(stat -f %m "$_a.jsonl" 2>/dev/null) || _m=$(stat -c %Y "$_a.jsonl" 2>/dev/null) || _m=0
  [ $(( now - _m )) -lt 300 ] || continue
  running=$(( running + 1 ))
done
[ "$used" -gt 200000 ] 2>/dev/null && limit=1000000   # already past 200k → must be 1M window

pct=$(( used * 100 / limit ))
usedk=$(awk -v u="$used" 'BEGIN{ if (u>=1000) printf "%.1fk", u/1000; else printf "%d", u }')

loc=$(basename "$dir")
branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)
[ -n "$branch" ] && loc="$loc:$branch"

# separators / color helper.
esc=$'\033'                 # a real ESC byte, for building color codes inside variables
sep="${esc}[2m·${esc}[0m"   # dim middle-dot separator

# Human "time left" until a Unix-epoch reset: "3d4h", "2h13m", or "8m".
fmt_left() {  # $1 = resets_at (epoch seconds)
  local rem=$(( $1 - now )) d h m
  [ "$rem" -lt 0 ] && rem=0
  d=$(( rem / 86400 )); h=$(( (rem % 86400) / 3600 )); m=$(( (rem % 3600) / 60 ))
  if   [ "$d" -gt 0 ]; then printf '%dd%dh' "$d" "$h"
  elif [ "$h" -gt 0 ]; then printf '%dh%dm' "$h" "$m"
  else                      printf '%dm' "$m"; fi
}

# --- rate-limit quota segment "N% (time-left)": green <70%, yellow 70-89%, red ≥90%.
# Empty when the percentage is absent (rate_limits is subscriber-only, each window independent).
# Segments are ordered 5h then 7d; the reset countdown (hours vs days) distinguishes them.
# Built from real ESC bytes ($esc) because it's printed via printf %s, which — unlike printf's
# format string — does not interpret \033 escape sequences.
quota_seg() {  # $1=used%   $2=resets_at (epoch seconds, may be empty)
  local val="$1" reset="$2" int color left=""
  [ -n "$val" ] && [ "$val" != "null" ] || return 0
  int=$(printf '%.0f' "$val")
  color=32
  [ "$int" -ge 90 ] && color=31
  [ "$int" -ge 70 ] && [ "$int" -lt 90 ] && color=33
  case "$reset" in ''|*[!0-9]*) ;; *) left=" ($(fmt_left "$reset"))" ;; esac
  printf ' %s %s[%sm%s%%%s%s[0m' "$sep" "$esc" "$color" "$int" "$left" "$esc"
}
rate5h_str=$(quota_seg "$rate5h" "$reset5h")
rate7d_str=$(quota_seg "$rate7d" "$reset7d")

# --- background-agent segment "⚙N" (magenta), absent while nothing is running ---
# A COUNT, not a name: a name reads as identity, and the bar has no identity to report —
# see the resolution block above for why. This says only "N agents are working elsewhere".
#
# Nothing about a subagent reaches the status line through an EVENT. Re-runs fire on a new
# assistant message or a change in one of tokenUsage/permissionMode/vimMode/mainLoopModel/
# fastMode/effortValue/thinkingEnabled/prStatus, and launching a subagent touches none of
# them — worse, the main loop emits no assistant message while it waits, so the one event
# that would repaint is exactly the one that cannot arrive. `refreshInterval` in
# settings.json is what makes this segment appear and clear on its own; without it the
# segment is dead code.
agent_str=""
[ "$running" -gt 0 ] && agent_str=$(printf ' %s %s[1;35m⚙%s%s[0m' "$sep" "$esc" "$running" "$esc")

# location (normal) · model (cyan) · effort (yellow) · agents (magenta) · context (green, red ≥80%) · 5h · 7d quota
ctx='32'; [ "$pct" -ge 80 ] && ctx='31'
printf '%s %s \033[1;36m%s\033[0m %s \033[33m%s\033[0m%s %s \033[%sm%s (%d%%)\033[0m%s%s' \
  "$loc" "$sep" "$model" "$sep" "$effort" "$agent_str" "$sep" "$ctx" "$usedk" "$pct" "$rate5h_str" "$rate7d_str"
