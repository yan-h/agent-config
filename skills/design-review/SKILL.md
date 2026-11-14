---
name: design-review
description: Review a change for correctness and for whether a different design would leave less long-term debt. Use when asked to review a diff, branch or PR for design, simplicity or maintainability, not only bugs.
---

# Review the design, not only the diff

Besides whether the change is correct as written, this review asks whether it should have been written this way:
whether another design, perhaps a larger change now, would leave the code simpler to own.

The target is the PR, branch or path the invocation names, or the current branch's diff against the primary branch when it names none.
In Claude that text is `$ARGUMENTS`; in Codex it is the text following `$design-review`.

Read the project's local contract, and the issue or PR description behind the change, before starting.
What counts as maintainable depends on where the project is going: its roadmap, its recorded decisions, and the scale it must support.
A recorded decision the change collides with is weighed as the global preferences say and becomes a question for the owner; none is reopened here otherwise.
A decision this change is the first to build is part of the design under review, not settled ground:
defects that trace to its rule are evidence against it, as an otonal pass that patched a just-accepted selection rule showed when the owner, after the merge, had to ask why the module had so many edge cases.

## Correctness

Run a correctness review in parallel with the design pass, in a subagent:
the review tool the project contract names, or else whatever review command the host provides, or else a fresh subagent briefed with the diff and the project contract.
A review command that loads into your own context is not a subagent, and when you wrote or shaped the change it is the author reviewing:
Claude Code's `/code-review` did that in five audited runs, two of whose reports then claimed independent reviewers. Brief a fresh subagent instead.
Start the design pass first, in the background, so a review that blocks does not run the two in turn.

## Design

Do this pass yourself, unless you wrote or shaped the change: its author is anchored to the design it chose.
Then brief a fresh agent with the change at a named commit, the owner's words from the issue or conversation, the project contract, this section and `references/design-pass.md`, and use its result as the design pass.
Leave your own view of the change out: no alternatives you suspect, no list of things to weigh, no fix direction for a defect you know of (state the defect alone), and no choice of yours described as the owner's.
Passes briefed that way patched what they were pointed at, returned the author's suspected alternative as their top finding when it did not work, and repeated an unverified premise;
the pass told "I will not tell you what its author thinks of it" found the restructuring that removed three copies of a rule.
Do not edit the checked-out tree while it reads: one pass reviewed a worktree that moved under it.
It is consequential judgement; size it by the global subagent guidance.
Where that guidance picks Fable and the `api-second-opinion` skill's test for an unasked call holds, one `ask-api --review` call is the pass instead:
add with `-f` the files beyond the diff that the design turns on, chosen as that skill's "Choosing the context" section says, because the model cannot open them.
Its question leaves your view out as a brief does; two such calls were told what to weigh, one with the author's choices given as the owner's.

The pass itself, and the shape of the report, are in [references/design-pass.md](references/design-pass.md).

## Report

Report as that file says.

Change no code in this pass; run from `review-and-merge`, that skill says what follows it.
The owner chooses which alternatives to take; offer to implement them, or to file follow-ups, afterwards.
