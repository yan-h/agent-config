@../AGENTS.md

# Claude Code only

## Subagent waits

A subagent's prompt cache expires after five idle minutes, while the main session's lasts an hour.
When a subagent idles past that, its next request rewrites its whole context; in one measurement these rewrites were about a fifth of all subagent usage, mostly after five to sixty idle minutes.
Keep long waits — full test runs, CI watching, sleep or poll loops — in the coordinating session: have the subagent implement and run fast checks, then hand back.
A PreToolUse hook (`subagent-wait-guard.sh`) refuses a subagent any wait that could outlast four minutes, so brief subagents to hand back longer commands for you to run.
Resume a subagent after a long gap only when its context is worth rewriting; otherwise brief a fresh one.

## Subagent worktrees

A worktree the Agent tool made for a subagent with worktree isolation is yours to release, since the host removes only unchanged ones and the reclaimer only clean ones:
one audit left two behind, one holding a 242 MB build cache.
Once its work is merged or carried into your branch or an issue, and you will not resume that subagent, remove it with `git worktree remove -f -f`,
since its lock names your own session, and delete its branch with `git branch -D`.

## Code review effort

When a skill runs `/code-review`, choose the effort level to fit the diff's risk; with no level it reuses the last one typed.

## Consent to merge and to write to issues

Auto mode counts only my own words in the chat as consent to merge a pull request or to edit or close an issue.
It has passed a `/review-and-merge` I typed, and refused a `/sweep-issues` run's first merge and another's issue edits, merges authorized only in an umbrella issue, and a handover session's merge after my bare "go ahead" to its brief.
So before a run that will merge or write to issues on anything less, ask me up front to say so in chat, naming merges and issue writes in one question: a run refused at its first merge waits there with its gates already run.
Do not retry or route around a refusal.

## Model costs

Subscription Fable 5.2 uses about three times Opus 5.5's quota per token, as measured.
It also fills its own weekly Fable limit about twice as fast as the all-models weekly limit, so heavy Fable use runs out there first.
Haiku's and Sonnet's quota are unmeasured; by API price per token, Sonnet costs 1/2 of Opus, and Haiku 1/40 up to a 100k-token prompt and 1/8 beyond, which a subagent that reads many files reaches.
Fable through the `api-second-opinion` skill uses no quota; it spends API credits, a monthly allowance that does not carry over, and Fable quota runs out before the credits do (that skill has the figures).
So wherever a Fable subagent would do the work, make one API call instead if it would do about as well, as that skill's test for an unasked call says; keep the subagent for the rest.
Choose Fable over Opus for a subagent where its better judgement is worth three times the quota.
