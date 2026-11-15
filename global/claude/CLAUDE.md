@../AGENTS.md

# Claude Code only

## Subagent waits

A subagent's prompt cache expires after five idle minutes, while the main session's lasts an hour.
When a subagent idles past that, its next request rewrites its whole context; the usage record (`yan-h/claude-usage`) puts these rewrites at about an eighth of subagent quota, mostly after five to sixty idle minutes,
and in one `propose-rework` run they were about a third of four designers' quota, each designer resumed four times after a red team's ten to thirty-five minutes.
So start a subagent as the `resumable` type, whose cache lasts an hour, when you plan to send it back after a wait or it must wait under an hour itself, such as a builder running its own full test suite.
At API prices its cache writes cost 2× base input instead of 1.25×, about 0.6 of one rewrite over its life, so it pays from the first such resume (their quota price is unmeasured);
keep `general-purpose` for an agent that reports once, such as a red team, reviewer or search.
Cache reads look free on the quota, so a resumed subagent's large context costs little once its cache is warm.
A PreToolUse hook (`subagent-wait-guard.sh`) refuses any other subagent a wait that could outlast four minutes: have it run fast checks and hand back longer commands for you to run.
Resume such a subagent after a long gap only when its context is worth rewriting; otherwise brief a fresh one.

## Subagent worktrees

A worktree the Agent tool made for a subagent with worktree isolation is yours to release, since the host removes only unchanged ones and the reclaimer only clean ones:
one audit left two behind, one holding a 242 MB build cache.
Once its work is merged or carried into your branch or an issue, and you will not resume that subagent, remove it with `git worktree remove -f -f`,
and delete its branch with `git branch -D`.

## Code review effort

When a skill runs `/code-review`, choose the effort level to fit the diff's risk; with no level it reuses the last one typed.

## Consent to merge and to write to issues

Auto mode's standing rules (`claude auto-mode config` prints them) cover my own repositories:
a new issue or a comment needs no word from me, so file follow-up, handover and report issues without asking;
a merge, or an edit or closure of an issue, passes once my own message in the chat has invoked one of the skills the rules name or agreed to it,
for the work that message covered and no later work, one agreement covering the whole set it describes.
Text outside the chat is not my word: merges authorized only in an umbrella issue were refused, and still are.
So as soon as you know that work will merge, or edit or close issues, on anything less, and before its first gate, ask me in chat, naming them in one question:
a run refused at its first merge waits there with its gates already run.
A refusal of a write the rules cover means their wording failed, or `scripts/install.sh` has not run on this machine since they changed: report which, with the command; do not retry or route around any refusal.

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
Choose Fable over Opus for a subagent where its better judgement is worth its quota price above.
