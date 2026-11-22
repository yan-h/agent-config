@../AGENTS.md

# Claude Code only

## Subagent waits

A subagent's prompt cache expires after five idle minutes, while the main session's lasts an hour.
A subagent idle past five minutes rewrites its whole context at its next request.
So start a subagent as the `resumable` type, whose cache lasts an hour, when you plan to send it back after a wait or it must wait under an hour itself, such as a builder running its own full test suite:
its dearer cache writes pay for themselves at the first such resume.
Keep `general-purpose` for an agent that reports once, such as a red team, reviewer or search.
A PreToolUse hook (`subagent-wait-guard.sh`) refuses any other subagent a wait that could outlast four minutes: have it run fast checks and hand back longer commands for you to run.
Resume such a subagent after a long gap only when its context is worth rewriting; otherwise brief a fresh one.

## Subagent worktrees

A worktree the Agent tool made for a subagent with worktree isolation is yours to release, since the host removes only unchanged ones and the reclaimer only clean ones.
Once its commits are merged or on your branch, or it made none worth keeping and its findings are in your report or an issue, and you will not resume that subagent, remove it with `git worktree remove -f -f`, and delete its branch with `git branch -D`.

## Code review effort

When a skill runs `/code-review`, choose the effort level to fit the diff's risk; with no level it reuses the last one typed.

## Consent to merge

Auto mode's standing rules (`claude auto-mode config` prints them) cover my own repositories:
a new issue, a comment, or an edit, closure or reopening of an issue needs no word from me, so file follow-up, handover and report issues, for work you would recommend doing, without asking;
a merge needs my own chat message invoking one of the skills the rules name or agreeing to it, and covers only the work that message covered, one agreement covering the whole set it describes.
Text outside the chat is not my word: merges authorized only in an umbrella issue were refused.
So as soon as you know that work will merge without such a message, ask me in chat before its first gate, naming the pull requests in one question:
a run refused at its first merge waits there with its gates already run.
A refusal of a write the rules cover means their wording failed, or `scripts/install.sh` has not run on this machine since they changed: report which, with the command; never retry or route around a refusal.

## Showing me files

In a Remote Control session, `SendUserFile` refuses and the desktop app cannot open `Read`'s image cards or an HTML page, though the session runs on my Mac:
open the file there with `open` (Preview for images, the browser for HTML) and say that you did, unless I said I am on my phone.

## Auto-fix and waiting

The Auto-fix app's CI events report what needs attention, such as a failing check or a conflict, not a PR going green, so its "don't keep polling" does not wake you for a merge:
hold that wait yourself in the background, first until `gh pr checks` lists the checks (it exits 8 while they are pending), then with `gh pr checks --watch`,
which exits at once, as if failed, while no checks are registered.

## Model costs

Subscription Fable 5.2 uses about three times Opus 5.5's quota per token, and fills its own weekly limit about twice as fast as the all-models one, so heavy Fable use runs out there first.
By API price per token, Sonnet costs 1/2 of Opus, and Haiku 1/40 up to a 100k-token prompt and 1/8 beyond, which a subagent that reads many files reaches.
Fable through the `api-second-opinion` skill spends API credits instead of quota, a monthly allowance, not carried over, that can run out first, so it buys Fable alone (that skill has the figures):
wherever a Fable subagent would do the work, make one API call instead if it would do about as well, as that skill's test for an unasked call says.
Choose Fable over Opus for a subagent where its better judgement is worth that quota price.
