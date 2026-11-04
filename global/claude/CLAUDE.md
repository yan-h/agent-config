@../AGENTS.md

# Claude Code only

## Subagent waits

A subagent's prompt cache expires after five idle minutes, while the main session's lasts an hour.
When a subagent idles past that, its next request rewrites its whole context; in one measurement these rewrites were about a fifth of all subagent usage, mostly after five to sixty idle minutes.
Keep long waits — full test runs, CI watching, sleep or poll loops — in the coordinating session: have the subagent implement and run fast checks, then hand back.
A PreToolUse hook (`subagent-wait-guard.sh`) refuses a subagent any wait that could outlast four minutes, so brief subagents to hand back longer commands for you to run.
Resume a subagent after a long gap only when its context is worth rewriting; otherwise brief a fresh one.

## Code review effort

When a skill runs `/code-review`, choose the effort level to fit the diff's risk; with no level it reuses the last one typed.

## Model costs

Subscription Fable uses about four times Opus's quota, as observed.
Haiku's and Sonnet's quota are unmeasured; by API price per token, Sonnet costs 1/2 of Opus, and Haiku 1/40 up to a 100k-token prompt and 1/8 beyond, which a subagent that reads many files reaches.
Fable through the `api-second-opinion` skill uses no quota; it spends API credits, about $100 of which come with the subscription each month.
The credits run out before the month does, while I fill spare quota with whatever tasks fit it.
So use the API for Fable only on a question whose context can be named and sent, and the subscription for everything else, reviews of code included.
Choose Fable over Opus for a subagent where its better judgement is worth four times the quota.
