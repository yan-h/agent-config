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

## Consent to merge and to write to issues

Auto mode counts only my own words in the chat as consent to merge a pull request or to file, edit or close an issue.
It has passed a `/review-and-merge` I typed, and refused a `/sweep-issues` run's first merge and another's issue edits, merges authorized only in an umbrella issue, and a handover session's merge after my bare "go ahead" to its brief.
So as soon as you know that work will merge or write to issues on anything less, an ordinary session that will file follow-up or handover issues included, and before its first gate,
ask me to say so in chat, naming the merges and issue writes in one question, and take one answer as covering what it names:
a run refused at its first merge waits there with its gates already run, and asking per item cost about thirty-five one-line approvals in one week, one six minutes after I had said "do all four issue writes".
Do not retry or route around a refusal.

## Showing me files

In a Remote Control session, `SendUserFile` refuses and the desktop app cannot open `Read`'s image cards or an HTML page, though the session runs on my Mac:
open the file there with `open` (Preview for images, the browser for HTML) and say that you did, unless I said I am on my phone. `SendUserFile` failed in thirteen sessions across four projects.

## Auto-fix and waiting

The Auto-fix app's CI events report what needs attention, such as a failing check or a conflict, not a PR going green, so its "don't keep polling" does not wake you for a merge:
hold that wait yourself in the background, first until `gh pr checks` lists the checks (it exits 8 while they are pending), then with `gh pr checks --watch`,
which exits at once, as if failed, while no checks are registered.

## Model costs

Subscription Fable 5.2 uses about three times Opus 5.5's quota per token, as measured.
It also fills its own weekly Fable limit about twice as fast as the all-models weekly limit, so heavy Fable use runs out there first.
Haiku's and Sonnet's quota are unmeasured; by API price per token, Sonnet costs 1/2 of Opus, and Haiku 1/40 up to a 100k-token prompt and 1/8 beyond, which a subagent that reads many files reaches.
Fable through the `api-second-opinion` skill uses no quota; it spends API credits, a monthly allowance that does not carry over, and Fable quota runs out before the credits do (that skill has the figures).
So wherever a Fable subagent would do the work, make one API call instead if it would do about as well, as that skill's test for an unasked call says; keep the subagent for the rest.
Choose Fable over Opus for a subagent where its better judgement is worth three times the quota.
