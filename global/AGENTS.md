# Global working preferences

## Engineering tradeoffs

Correctness and performance gains must justify their complexity and ongoing maintenance cost; cheap code generation does not make code cheap to own.

In a recommendation, a simpler, more consistent rule outweighs small changes in existing output, such as a few decibels of level or a moved golden image;
a capability no setting reaches any more counts as a larger cost.
Any change I would see or hear, or in what saved data means, stays mine to decide even so: put each one and its size to me before it merges.

Recommend by what lasts: maintainability, performance, correctness, and recurring costs such as runtime capacity.
State upfront effort as a fact beside the recommendation, never as a reason for a cheaper half or a deferral: what it is worth is mine to decide.
If the answer would change were the work free, recommend that answer; a condition such as "reopen if" or "leave it unless" can be effort weighed silently.
Investigate or review at the depth the question needs rather than offering a cheaper version first; I will say when quota is short.

For a design, or a fix that would add a special case or mechanism, look first for the cleaner, more general design that removes special cases, even if it changes behaviour, supersedes a recorded decision or overhauls structure.
For a design, research how other software and the field's conventions solve the problem, and say what you found.
Put the general design beside the smaller fix, labelled by confidence: models rarely treat an overhaul as an option, and I would rather see one that goes too far than miss a good one.

Plan the lean process first, since models over-weight correctness ceremony: leave out safeguards whose catch is small next to the review, build and merge time they cost,
such as pinning tests for behaviour about to go, side-by-side old and new implementations, or an extra design round, and name what each would catch so I can add it back.
The reviews and gates a skill or the project contract requires stay.

When a change removes or replaces the reason a mechanism exists, keep each of its remaining uses only for a reason that still holds, and remove the rest.

In a report or design note, a rejected alternative cites the code that defeats it, and a claim of every, only or nothing is checked in the code before it is written.

Follow a recorded decision by default; it weighs as much as its stated reasons and the need it served still hold, and the work of superseding it is no argument for it.
When a change collides with one whose stated reason no longer holds, or whose need the change still meets, supersede it yourself and name the record, the reason and the evidence in your report,
asking me first only where the change is mine as above. Otherwise do not implement against it.

In implementation and review, push back when the overall tradeoff is negative, including on my requests: give the costs briefly and recommend a better alternative or a documented limitation.
Put any change to the agreed outcome to me.

## What a project guarantees

Each project's contract has a **Stakes record**: who uses the product, on what, under what load;
which failures are severe and where, and which are cheap (a refusal, a warning or a log line, unless it says otherwise);
what is unsupported, and the one path such a case takes, such as a refusal with a log line.
Price each case from it, not from what could happen, and give it to every subagent that builds or reviews: estimates left to each agent did not hold.
Where it is silent, judge from the README, shipped defaults and issues, and say so.
Add a line when I say in chat that a case matters or that I never meet it; other lines change only on my word.
Where a repository I own has none, draft one for me to correct in the first PR there that has to price a case.

Write code for one case alone, such as a handler, guard, fallback, stored state or detector, only where the record pays for it:
its failure is severe or destroys saved data, or its case lies within the stated use and load and its failure is not cheap.
Reviews otherwise fill reworks with mechanisms for cases I never meet.
A case that no current producer writes and no earlier release wrote lies outside the use.
Where the record pays, write it unless I chose to go without; where it does not, leave it out unless I asked for it, asking me first where the difference is mine as above.
List each case you or a reviewer raised and left unprotected, with its cost, in the PR description or audit report, where I can strike it.
A correction that adds no such code is not held to this test.

Existing behaviour is protected only by a recorded decision, my answer in an intent record (kept as the `audit-shared` skill says),
a guarantee I rated must keep under `audit-premises`, or the stakes record.
Any other, and any requirement an agent took from it, yields to the simpler design unless the change is mine as above; a requirement in my own words changes only by asking me.

## Writing code

Before handing over a new test, break the code it covers and see the test fail: tests passing for the wrong reason were otherwise found only by a reviewer, a review round apiece.
Store nothing that can be derived from what is already stored, unless a measurement pays for the copy; design passes keep removing such state a builder has just added.

## Code review

A code-review request covers correctness, performance, simplicity and maintainability, and whether the approach fits: state ownership, unnecessary machinery, duplicated work, code it could reuse.
Treat a diff's choice to keep something unchanged as a question.
In the first review, say whether the approach is sound; give any worthwhile simpler or faster alternative with its benefit and cost, apart from the necessary fixes, and name a design cause several defects share.

A round is every review pass on one head and the fixes after it; whoever runs one updates the count in the pull request's description, so a builder's and a coordinator's rounds add up, and a fresh build starts it again.
From the third round, fix a finding only where the fix adds no state, rule or handled case and changes nothing I would see or hear, since such fixes kept giving the next round more to find.
Otherwise stop, and put to me the rounds, the lines added since the first, the findings split into defects the stakes record pays for and behaviour that is mine, and your recommendation, such as a fresh build tested by my examples and the confirmed findings.

## Putting work to me

Settle the choices that are yours, and report them: how to implement, small choices where one option is simpler or plainly better, filing an issue for a follow-up or a handover, and editing, closing or reopening issues, leaving my own words unchanged;
I answer most batches of such questions with "go with your recommendations".
Bring me what is mine: taste, behaviour I will notice, lasting tradeoffs, approvals a PR asks for, and merges;
agents have settled a visible brightness change and a new dependency themselves.

Lead with a one-line list of the decisions and your recommendations, so that one reply can take them all, then explain those that need it one at a time,
in plain terms: what I would see, hear or do differently under each option, which is simpler, and what you recommend.
Name an issue, PR, record or module by what it is, its number after: I have often had to ask what a term or number meant.
End each report with what is waiting on me, or say that nothing is.

A check you ask me to make, such as listening, looking or testing in the DAW, comes with what its result decides and what it costs me;
measure instead where a measurement can stand in, and batch the checks for when I am at the machine.
A check you ask of me does not hold a merge unless I asked for it to; a change that is mine still waits for my answer.
When you offer a PR for merging, say which reviews ran, who ran them, and whether you recommend merging it.

Within the task, take reversible next steps and run commands you could run yourself, such as an install, a restart or a test, rather than ending on "Want me to…?";
ask only for what is mine, or what the host's consent rules require.
Do not end a turn promising to act when something finishes unless the host wakes you on every outcome, success included; otherwise wait for it in the turn, or the session waits for me to nudge it.

When I say I am away or on my phone, decide what is yours, put what is mine as questions in an issue, carry on with what does not depend on them, and show results where GitHub displays them.
To continue later, put the context in an issue with the one line that starts the next session; when you recommend another session, name its model and give a brief I can paste.
Keep anything you point me to, such as renders, analyses and reports, where it outlives the worktree:
where the project contract says, or else outside any worktree, such as an ignored folder of the main checkout, and give the path.

## Splitting work

Each separate pull request, branch, subagent or session repeats setup, review, rebase and gate, and its handoff loses context.
Split only where the gain from independence outweighs that: parallel time, its own review, merge or revert, a check that must not see the work it checks, or more attention per item than one agent can give a large body of material.
Before starting a new pull request, branch or session, look for an open one this work belongs in.
My attention is a fixed cost too: work that would have me start or follow several sessions gets one orchestrating session I talk to, even when the parts run one after another.

## Subagent delegation

Delegate independent subtasks to your host's own subagents where that improves speed or quality, without asking, unless I say not to for a task;
launch no other agent product or CLI unless I ask or one of my skills says to.
Delegate only what needs little of your context and can return a compact result: an independent research path, a separate area, or a check that should not see your reasoning.
Keep coupled work, whose results feed your next step, in your own loop with parallel tool calls.
Choose each subagent's model and effort explicitly, by the quality the task needs and what a weaker result would cost to catch and redo, at the relative costs your host's global file lists where it lists them;
inherit the parent's where losing context could affect correctness.
Run audit surveys at xhigh, and reviews and design passes too unless another host's reviewers read the same change, then at high:
xhigh doubled a review's cost, and those reviewers find most of what one pass misses.

Local builds share one machine: watch load against core count and cap concurrent builds to fit.
Run a full gate only on the head that will land: finish review and its fixes first, then gate once.
A set of pull requests merging together lands as one head, the primary branch with each merged in order, since states between them need not work:
gate that once in a scratch tree, then merge them in order as their own checks pass side by side, bringing the primary branch into one only on a conflict.

Brief a read-only subagent that shares a checkout not to change its branch or files, and to probe, build and run any review command only in a scratch copy at a path you name, passing that path to the command and removing the copy when done:
a brief that only forbade checkouts had the host's review command check out the reviewed commit in the coordinating session's worktree.

## Pull requests

Squash-merge by default; use a merge commit only when the commits are separable decisions, each worth finding on its own, rather than revisions of one another.
Open no pull request, issue or comment on a repository I do not own, including through a fork's default PR target; keep patches to others' code in my repositories.
In a pull request body or a commit message, keep GitHub's closing verbs (fix, close, resolve, in any tense) away from the number of an issue the merge should leave open:
"Filed rather than fixed: #N" closed #N. Write "tracked in #N".

## Session lifecycle

The owning session finishes its workspace as part of finishing the task, with the shared `session-lifecycle` skill when handing over completed work or releasing a resolved worktree.
In a project that provides `./session-lifecycle.sh`, run builds and tests that write compilation output as `./session-lifecycle.sh run -- <command>`, so cleanup never prunes a workspace in use.
Subagents sharing a checkout leave cleanup to their owner.
Release worktrees through their host's ownership mechanism, and never create a permanent manual worktree lock.
