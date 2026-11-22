---
name: design-review
description: Review a change for correctness and for whether a different design would leave less long-term debt. Use when asked to review a diff, branch or PR for design, simplicity or maintainability, not only bugs.
---

# Review the design, not only the diff

The target is the PR, branch or path the invocation names, or the current branch's diff against the primary branch when it names none.
In Claude that text is `$ARGUMENTS`; in Codex it is the text following `$design-review`.

Read the project's local contract and roadmap, the intent records of the areas the change touches, and the issue or PR description behind it, before starting.
A recorded decision the change collides with is weighed as the global preferences say: superseding it is an alternative like any other, or a question where they make it the owner's.
None is reopened here otherwise, except a decision this change is the first to build, as `references/design-pass.md` says.

## Correctness

Run a correctness review in parallel with the design pass, in a fresh subagent:
brief it to run the review tool the project contract names, or the host's review command, or where neither exists to review the diff against the project contract.
Have it say of each finding whether its case lies within the use and load the stakes record states, and the worst the case does.
Name the commit, and brief it as the global delegation guidance says of a subagent that shares a checkout.
Do not run that tool in your own session: Claude Code's `/code-review` loads into the context that calls it, so the author reviews its own change.
Codex's passes start alongside it, as "Codex beside Claude" says.

## Design

Do this pass yourself, unless you wrote or shaped the change: its author is anchored to the design it chose.
If you wrote or shaped it, brief a fresh agent with the change at a named commit, the owner's words from the issue or conversation, the project contract, the intent records of the areas the change touches, and `references/design-pass.md`, and use its result as the design pass.
Leave your own view of the change out: no alternatives you suspect, no list of things to weigh, no cost prior, no fix direction for a defect you know of (state the defect alone), and no choice of yours described as the owner's; send design-pass.md itself, not a summary.
Passes given the author's view patched what they were pointed at and returned the author's own suspicion as their top finding.
Do not edit the checked-out tree while it reads, or it reviews a tree that moves under it.
Run that agent as an Opus subagent, since Opus matched Fable on the same input.
Run it on Fable where a missed defect costs most, a change touching a case its stakes record calls severe, persistence, concurrency or a public interface, or one you judge as hard:
one `ask-api --review` call, a Fable subagent where that call cannot carry the context, or an Opus subagent once the credits have run out.
To that call add with `-f` those intent records and the files beyond the diff that the design turns on, as the `api-second-opinion` skill says, because the model cannot open them.
Its question carries the owner's words and leaves your view out as a brief does.

The pass itself, and the shape of the report, are in [references/design-pass.md](references/design-pass.md).

## Codex beside Claude

Where `codex` is on PATH, a Claude session reviewing a PR or branch also has Codex review it: over 44 reviews, each of its two passes and each of Claude's found confirmed defects no other pass did (yan-h/agent-config#124).
Add a detached worktree of the reviewed head at a scratch path outside every checkout, and from it start both in the background with a one-hour limit, each with `-c model=gpt-6.2-sol -c review_model=gpt-6.2-sol -c model_reasoning_effort=xhigh -c sandbox_mode=read-only -c approval_policy=never`:
`codex review --base <merge base with the freshly fetched primary branch>`, whose standard output is its correctness review,
and `codex exec -o <file outside the worktree> -`, given on standard input the brief the Design section gives a fresh agent, with the absolute path of `references/design-pass.md` in place of the file, as its design pass.
Wait for both before acting on any pass, then remove the worktree; a run that cannot start, fails or times out is reported as such and holds nothing.

Codex reads the first reviewed head once, and its verdict steers nothing: a finding from either side that a check confirms is handled like any other.
The report marks each finding Claude, Codex or both, and gives Codex's verdict and alternatives beside Claude's, with the model each ran on.

## Report

Report as that file says.

Change no code in this pass; run from `review-and-merge`, that skill says what follows it.
The owner chooses which alternatives to take; offer to implement them, and file those placed in a follow-up as issues.
