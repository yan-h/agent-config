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
Do not run that tool in your own session: Claude Code's `/code-review` loads into the calling context, so the author reviews its own change.
With reviewers beside Claude, brief it to run the host's review command at xhigh, which fits in their wait: lower, it missed what they caught.

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

## Reviewers beside Claude

A Claude session reviewing a PR or branch also has each reviewer below whose command is on PATH review it, with two passes started in the background with a one-hour limit:
a correctness review of the diff against the merge base with the freshly fetched primary branch,
and a design pass given the brief the Design section gives a fresh agent, with the absolute path of `references/design-pass.md` in place of the file.
Wait for all before acting on any pass; a run that cannot start, fails or times out is reported and holds nothing.

- **Codex** (`codex`): over 44 reviews, each of its passes and of Claude's found confirmed defects no other did (yan-h/agent-config#124).
  From a detached worktree of the reviewed head at a scratch path outside every checkout, removed once both end, run both with `-c model=gpt-6.2-sol -c review_model=gpt-6.2-sol -c model_reasoning_effort=xhigh -c sandbox_mode=read-only -c approval_policy=never`:
  `codex review --base <merge base>`, whose standard output is its correctness review, and `codex exec -o <file outside the worktree> -`, given the design brief on standard input.
- **Gemini** (`agy`), on trial (yan-h/agent-config#137): run each pass as `scripts/gemini-pass <checkout> <full head SHA> <full merge base SHA> <brief file> <output file>`, which reviews from a clone with no remote in `agy`'s sandbox and fails unless `agy` reports success.
  Its correctness brief is the one the Correctness section gives a fresh subagent, with the PR description.
  The sandbox has no network, so each brief carries the text of every issue it names.
  Once its findings are confirmed or dismissed, comment on the reviewed PR headed "Gemini trial" where the owner owns the repository, or else put it in the report:
  each finding marked by who found it, whether it was confirmed, dismissed or left uncertain and by what check, and each verdict with its model.

Each reads the first reviewed head once, and its verdict steers nothing: a finding from any side that a check confirms is handled like any other.
The report marks who found each finding, and gives each reviewer's verdict and alternatives beside Claude's, with its model.

## Report

Report as that file says.

Change no code in this pass; run from `review-and-merge`, that skill says what follows it.
The owner chooses which alternatives to take; offer to implement them, and file those placed in a follow-up as issues.
