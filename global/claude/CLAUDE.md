@../AGENTS.md

# Claude Code only

## Subagent waits

A subagent's prompt cache expires after five idle minutes, while the main session's lasts an hour.
When a subagent idles past that, its next request rewrites its whole context; in one measurement these rewrites were about a fifth of all subagent usage, mostly after five to sixty idle minutes.
Keep long waits — full test runs, CI watching, sleep or poll loops — in the coordinating session: have the subagent implement and run fast checks, then hand back.
Resume a subagent after a long gap only when its context is worth rewriting; otherwise brief a fresh one.

## Billed code review

`/code-review` is billed, but run it without asking when a change warrants a correctness pass beyond your own reading: a large or risky diff, or real-time, concurrency or persistence code.
Choose the effort level to fit the risk, and skip it for small, mechanical or documentation-only changes.
The `ultra` level stays the user's to launch.

## Model costs

Subscription quota per token, relative to Opus: Haiku 1/40, Sonnet 1/2, Fable 4.
Fable's is observed; Haiku's and Sonnet's assume the API's price ratios.
Fable through the `api-second-opinion` skill uses no quota, and costs 2.5 times API Opus's price from separate prepaid credits.
An API call returns one answer over only the context you send, without tools; a subagent can explore, run commands and edit.
Choosing the API is the ask the subagent guidance requires before launching another CLI.
