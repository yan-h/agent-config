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

## Fable over the API

Subscription Fable uses four times Opus's usage, while API Fable costs 2.5 times API Opus from separate prepaid credits, so the API is the cheaper way to get Fable's judgement.
When the subagent guidance calls for the strongest model on judgement over context you can gather and send, such as a design question, a second opinion or a design pass over a diff, use the `api-second-opinion` skill instead of a Fable subagent, including where another skill asks for such a subagent.
This is the ask the subagent guidance requires before launching another CLI.
Keep Fable subagents for work that needs tools: exploring code you cannot name in advance, running commands, or editing.
Such a call is that delegation, not an unasked call under the skill's one-per-task limit, and it stays within the $20 guard.
Where `ask-api` is not set up or its credits have run out, use the subagent.
