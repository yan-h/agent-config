---
name: design-review
description: Review a change for correctness and for whether a different design would leave less long-term debt, weighing upfront cost against maintainability. Use when asked to review a diff, branch or PR for design, simplicity or maintainability, not only bugs.
---

# Review the design, not only the diff

Besides whether the change is correct as written, this review asks whether it should have been written this way:
whether another design, perhaps a larger change now, would leave the code simpler to own.

The target is the PR, branch or path the invocation names, or the current branch's diff against the primary branch when it names none.
In Claude that text is `$ARGUMENTS`; in Codex it is the text following `$design-review`.

Read the project's local contract and the issue or request behind the change before starting, and the PR description only once the design pass has a design of its own.
What counts as maintainable depends on where the project is going: its roadmap, its recorded decisions, and the scale it must support.
A recorded decision the change collides with is weighed as the global preferences say and becomes a question for the owner; none is reopened here otherwise.

The owner will usually spend substantial upfront work for a significant, lasting gain in maintainability, and not for a marginal one.

## Correctness

Run a correctness review in parallel with the design pass, in a subagent:
the review tool the project contract names, or else whatever review command the host provides, or else a fresh subagent briefed with the diff and the project contract.

## Design

Do this pass yourself, unless you wrote or shaped the change: its author is anchored to the design it chose.
Then brief a fresh agent with the change, the project contract, this section and `references/design-pass.md`, and use its result as the design pass.
It is consequential judgement; size it by the global subagent guidance.
Where the `api-second-opinion` skill's test for an unasked call holds, one `ask-api --review` call is the pass instead, whether you would have done it yourself or briefed an agent:
add with `-f` the files beyond the diff that the design turns on, because the model cannot open them.

The pass itself, and the shape of the report, are in [references/design-pass.md](references/design-pass.md).

## Report

Report as that file says.

Change no code in this pass.
The owner chooses which alternatives to take; offer to implement them, or to file follow-ups, afterwards.
