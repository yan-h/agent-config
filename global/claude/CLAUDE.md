@../AGENTS.md

# Claude Code only

## Subagent waits

A subagent's prompt cache expires after five idle minutes, while the main session's lasts an hour.
When a subagent idles past that, its next request rewrites its whole context; in one measurement these rewrites were about a fifth of all subagent usage, mostly after five to sixty idle minutes.
Keep long waits — full test runs, CI watching, sleep or poll loops — in the coordinating session: have the subagent implement and run fast checks, then hand back.
`subagent-wait-guard.sh`, a PreToolUse hook, refuses a subagent's background commands, timeouts over four minutes, and Monitor, ScheduleWakeup and CronCreate; brief subagents to hand back any longer command for you to run rather than trip it.
Resume a subagent after a long gap only when its context is worth rewriting; otherwise brief a fresh one.

## Billed code review

`/code-review` is billed, but run it without asking when a change warrants a correctness pass beyond your own reading: a large or risky diff, or real-time, concurrency or persistence code.
Choose the effort level to fit the risk, and skip it for small, mechanical or documentation-only changes.
The `ultra` level stays the user's to launch.

## Model costs

Subscription Fable uses about four times Opus's quota, as observed.
Haiku's and Sonnet's quota are unmeasured; by API price per token, Sonnet costs 1/2 of Opus, and Haiku 1/40 up to a 100k-token prompt and 1/8 beyond, which a subagent that reads many files reaches.
Fable through the `api-second-opinion` skill uses no quota; it spends API credits, about $100 of which come with the subscription each month.
Prefer the subscription for every model but Fable, and the API for Fable wherever its one answer without tools serves the task.
