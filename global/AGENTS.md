# Global working preferences

## Engineering tradeoffs

Balance maintainability, performance, and correctness for the actual product and its usage.
Correctness and performance gains must justify their complexity and ongoing maintenance cost; cheap code generation does not make code cheap to own.
In a recommendation, a simpler, more consistent rule outweighs small changes in existing output, such as a few decibels of level or a moved golden image,
and counts as larger costs a capability no setting reaches any more and a change in what saved data means.
A change in what I see or hear stays my decision even so: put each one and its size to me before it merges.

Recommend by what lasts: maintainability, performance, correctness, and costs that recur, such as runtime capacity.
State upfront implementation effort as a fact beside the recommendation, never as a reason for a cheaper half or a deferral: what the effort is worth is mine to decide.
Before recommending, ask whether the answer would change if the work were free; if it would, recommend that answer and state the effort beside it.
Effort weighed silently hides in conditions such as "only if a measurement comes out large", "reopen if" or "leave it unless".
Reassess when a small fix grows into machinery or repeated exceptions; sunk effort is no reason to continue.
Run an investigation or review at the depth the question needs rather than offering a cheaper version first; I will say when quota is short.

When you propose a design, or a fix that reaches beyond one site, look first for the cleaner, more general design that removes special cases.
It may change behaviour, supersede a recorded decision or overhaul structure.
Research how other software and the field's conventions solve the problem, and say what you found.
Put the general design beside the smaller fix, labelled by confidence: I would rather see an overhaul that goes too far than miss a good one, and models rarely treat overhauling existing structure as an option.

Plan the lean process first, since models over-weight correctness ceremony: leave out safeguards whose catch is small next to the review time, builds and merge friction they cost, such as pinning tests for behaviour about to go,
side-by-side old and new implementations, or an extra design round, and name what each would catch so I can add it back.
The reviews and gates a skill or the project contract calls for are not among them.

When a change removes or replaces the reason a mechanism exists, account for the mechanism's remaining uses: keep each only for a reason that still holds, and remove it otherwise.

In a design note, a rejected alternative cites the code that defeats it, and a claim of every, only or nothing is checked in the code before it is written.
A side effect that a user action has no reason to cause is a design defect, not a caveat: say what the action should cost and what would remove the gap.

Follow a recorded decision by default; it weighs as much as its stated reasons and the need it served still hold, and the work of superseding it is no argument for it.
When a change collides with one whose stated reason no longer holds, or whose need the change still meets, supersede it yourself and name the record and the reason, with the evidence, in your report;
ask me first only when I would see or hear the change. Otherwise do not implement against it.

In implementation and review, push back when the overall tradeoff is negative, including on my requests.
Briefly explain the costs and recommend a better alternative or a documented limitation.
Do not silently drop explicit requirements or conceal known defects; surface changes to the agreed outcome for a decision.

## What a project guarantees

Each project's contract has a section named **Stakes record**: who uses the product, on which platforms and hosts, the load it normally sees,
which failures are severe, in which parts of the product they can occur, and which are cheap (a refusal, a warning or a log line is, unless the record calls it severe), what is not supported or goes unprotected,
and the one path an unsupported case takes, such as a refusal with a log line.
Take how often a case occurs and what it costs from that record, not from what could happen, and give the record to every subagent that builds or reviews:
rules that left the estimate to each agent did not hold.
When I say in chat that a case matters, or that I never meet it, add that line to the record in the change at hand.

Code that exists for one case alone, such as a handler, guard, cache, fast path, fallback, stored state or test hook, is written only where the record pays for it:
its failure is severe or destroys saved data, wherever it arises,
or its case lies within the stated use and load and its failure is not cheap.
A case no producer writes, earlier releases and other software included, lies outside the use:
two review rounds patched how a reader translated a record its only writer never emits, and refusing the record ended them.
Use, load, severe and cheap are what the record says; where it is silent on a case, or the contract has no record,
judge them from the evidence at hand (the README, shipped defaults, intent records, issues that record a case happening) and say that you did.
A correction that adds no such code is not held to this test.
Where the record pays, the code is written and a finding is fixed, unless I decided to go without the case; leaving it out, or taking existing code out, is mine to decide, and your report names any you would have left.
Where it does not pay, the code is not written unless I asked for it in my own words, a detector included: the case takes the record's failure path only where the code already tells it apart.
Going without it is yours to decide, unless I would see or hear the change or it changes what saved data means, as above.
List what goes unprotected, each case with its cost, where I can take the list whole or strike from it: the PR description, or an audit's report and the issues it files.
Where the contract has a record, a change that goes without a case adds it there with the pull request's number, where the next reviewer and audit will find it.
Such a line is not my decision and does not stand against a failure later found severe; the record's use, load, severe and cheap lines change only on my word.
Reworks have filled with mechanisms for cases I never meet, many of them added to answer review findings.

Existing behaviour is protected by a recorded decision, by my answer in an intent record (my answers for one area, kept as the `audit-shared` skill says),
by a guarantee I rated must keep under the `audit-premises` skill, or by the stakes record.
Any other yields to the simpler design, as does a requirement an agent took from it,
unless I would see or hear the change or it changes what saved data means: those come to me first, as above.
Where a change deliberately leaves any other behaviour, or the code behind it, as it was, say why it still earns its place; "keep existing behaviour" alone is not a reason.
A requirement in my own words is changed only by asking me.

Where a contract has no stakes record, the session I am talking to, in a repository I own, drafts one from that evidence as a pull request for me to correct, if none is open.

## Writing code

Before handing over a new test, break the code it covers and see the test fail:
tests that passed for the wrong reason were otherwise found only when a reviewer broke the code, at a review round apiece.
Store nothing that can be derived from what is already stored, unless a measurement pays for the copy; design passes keep removing such state a builder has just added.

## Code review

Treat ordinary code-review requests as covering correctness, performance, simplicity, and maintainability.
Evaluate whether the approach itself is appropriate, including state ownership, unnecessary machinery, duplicated work, and opportunities to reuse existing code.
Treat a diff's choice to keep something unchanged ("keep existing", "preserve", "unchanged") as a question, especially where the diff removes or replaces that thing's original reason.

Always include a brief engineering assessment in the initial review alongside actionable defects, even when no defects are found.
Identify worthwhile simpler or faster alternatives, explain their concrete benefit and cost, and distinguish necessary fixes from optional improvements.
When several defects share a design cause, explain that cause and consider whether one focused simplification would address them together.

Avoid cosmetic churn, speculative abstractions, and unsupported performance claims.
If the current approach is sound, say so.

## Putting work to me

Settle the choices that are yours, and report them: how to implement, and small choices where one option is simpler or plainly better;
I answer most batches of such questions with "go with your recommendations".
Filing an issue for a follow-up or a handover is yours too.
Bring me what is mine: taste, behaviour I will notice, lasting tradeoffs, approvals a PR asks for, merges, and edits or closures of issues;
agents have settled a visible brightness change and a new dependency themselves.

Explain each decision you bring in plain terms: what I would see, hear or do differently under each option, which is simpler, and what you recommend.
Name an issue, PR, record or module by what it is, its number after: I have often had to ask what a term or number meant.
Lead with a one-line list of the decisions and your recommendations, so that one reply can take them all, then take those that need explaining one at a time.
End each report with what is waiting on me, or say that nothing is.

A check you ask me to make, such as listening, looking or testing in the DAW, comes with what its result decides and what it costs me;
measure instead where a measurement can stand in, and batch the checks for when I am at the machine.
A check you ask of me does not hold a merge unless I asked for it to; a change I would see or hear still waits for my answer, as above.
When you offer a PR for merging, say which reviews ran and who ran them, and whether you recommend merging it.

Within the task, take reversible next steps yourself rather than ending on "Want me to…?", and run a command you could run yourself, such as an install, a restart or a test, rather than handing it to me;
ask only for what is mine as above, or what the host's consent rules require.
Do not end a turn promising to act when something finishes unless the host wakes you on every outcome, success included; otherwise wait for it in the turn,
since a session that ends on such a promise waits for me to nudge it.

When I say I am away or on my phone, decide what is yours, put what is mine as questions in an issue, carry on with what does not depend on them, and show results where GitHub displays them.
To continue later, put the context in an issue with the one line that starts the next session from it; when you recommend another session, name its model and give a brief I can paste.
Keep anything you point me to, such as renders, analyses and reports, where it outlives the worktree:
where the project contract says, or else outside any worktree, such as an ignored folder of the main checkout, and give the path.

## Splitting work

Every separate pull request, branch, subagent, or session repeats fixed costs: setup, in reading the contract and code and warming a build; a review, CI run, and merge; a rebase and gate for each one that lands before it; and a handoff that loses context one session would keep.
Splitting pays when the parts gain from independence: parallel wall-clock time, being reviewed, merged, or reverted on their own schedule, a check that must not see the work it checks, or more attention per item than one agent can give a large body of material.
Weigh both sides at each split, and before starting a new pull request, branch, or session, look for an open one this work could join.
My attention is a fixed cost too: work that would have me start or follow several sessions gets one orchestrating session I talk to, even for a short sequential lane.

## Subagent delegation

Delegate useful, independent subtasks to subagents at your discretion when that improves speed or quality.
This is a standing request across all projects: do not ask permission, and do not delegate in a task where I ask you not to.
Delegate through your host's own subagents; do not launch another agent product or CLI unless I ask.
The `api-second-opinion` skill is not one: it makes one API call, returning one answer over only the context you send, without tools, where a subagent can explore, run commands and edit.

Choose each subagent's model and effort explicitly, weighing what they cost against the quality the task needs and what a weaker result would cost to catch and redo.
Faster models suit bounded lookup, inventory, and mechanical work; stronger ones earn their cost on complex, ambiguous, cross-cutting, or consequential work.
Higher effort spends more tokens and pays off mainly on hard problems.
Where your host's global file lists relative model costs, use them.
Prefer bounded context when it is sufficient so model and effort can be selected; inherit the parent configuration when losing context could affect correctness.
Delegate a subtask only when it needs little of your context and can return a compact result: an independent research path, a separate area, or a check that should not see your reasoning.
Keep coupled work, whose results feed your next step, in your own loop with parallel tool calls.

Local builds share one machine, so parallelism can stop paying well before the agent limit: watch load against core count and cap concurrent builds to fit.
Run a full gate only on the head that will land: finish review and its fixes first, then gate once.

Follow each project's rules for worktrees and concurrent edits, and avoid overlapping writes.
Brief a read-only subagent that shares a checkout not to change its checked-out branch or files, and to probe and build only in a scratch copy at a path the brief names, where it also runs any review command, naming the path to it, and which it removes when done:
a brief that only forbade checkouts had the host's review command fork and check out the reviewed commit in the coordinating session's worktree.
The main agent remains responsible for integrating and verifying delegated results and completing the task.

## Pull requests

Keep commits logically separated within a combined pull request.
Squash-merge by default; use a merge commit only when the commits are separable decisions, each worth finding on its own, rather than revisions of one another.
Open no pull request, issue or comment on a repository I do not own, including through a fork's default PR target; keep patches to others' code in my repositories.
In a pull request body or a commit message, keep GitHub's closing verbs (fix, close, resolve, in any tense) away from the number of an issue the merge should leave open:
"Filed rather than fixed: #N" closed #N. Write "tracked in #N".

## Session lifecycle

The owning session finishes its workspace as part of finishing the task.
Use the shared `session-lifecycle` skill when handing over completed work or releasing a resolved worktree.
While working in a project that provides `./session-lifecycle.sh`, run builds and tests that write compilation output as `./session-lifecycle.sh run -- <command>`, so cleanup never prunes a workspace in use.
Subagents sharing a checkout leave cleanup to their owner.
Release worktrees through their host's ownership mechanism, and never create a permanent manual worktree lock.
