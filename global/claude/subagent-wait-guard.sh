#!/bin/bash
# PreToolUse hook: refuses a subagent's tool calls that can wait long enough for
# its five-minute prompt cache to expire, so long waits happen in the main
# session, whose cache lasts an hour. Only subagent calls carry agent_id.
# A foreground command ends at its timeout (two minutes by default), so capping
# the timeout covers sleeps and poll loops; background commands and the
# scheduling tools are what let a subagent idle past it.
input=$(cat)
reason=$(jq -r '
  if .agent_id == null then empty
  elif (.tool_name | IN("Monitor", "ScheduleWakeup", "CronCreate")) then .tool_name + " waits on later events"
  elif .tool_input.run_in_background == true then "a background command is waited on later"
  elif (.tool_input.timeout // 0) > 240000 then "a timeout over four minutes"
  else empty end
' <<<"$input" 2>/dev/null) || exit 0  # unparsable input: never block on the guard's own failure
[ -n "$reason" ] || exit 0
jq -n --arg r "Subagents must not wait past their 5-minute prompt cache: $reason. Finish with fast checks, then return to the coordinator, naming the long-running command or wait for it to run itself." '{
  hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $r}
}'
