---
name: design-review
description: Review a change for correctness and for whether a different design would leave less long-term debt, weighing upfront cost against maintainability. Use when asked to review a diff, branch or PR for design, simplicity or maintainability, not only bugs.
---

# Review the design, not only the diff

A bug review asks whether the change is correct as written.
This review also asks whether it should have been written this way:
whether another design, perhaps a larger change now, would leave the code simpler to own.

The target is the PR, branch or path the invocation names, or the current branch's diff against the primary branch when it names none.
In Claude that text is `$ARGUMENTS`; in Codex it is the text following `$design-review`.

Read the project's local contract, and the issue or PR description behind the change, before starting.
What counts as maintainable depends on where the project is going: its roadmap, its recorded decisions, and the scale it must support.
Recorded decisions are not reopened here; one that the evidence strongly contradicts becomes a question for the owner.

The global engineering tradeoff and code review defaults apply throughout.
The owner will usually spend substantial upfront work for a significant, lasting gain in maintainability, and not for a marginal one.

## Correctness

Run a correctness review in parallel with the design pass, in a subagent:
the review tool the project contract names, or else whatever review command the host provides, or else a fresh subagent briefed with the diff and the project contract.
Verify what it reports before passing it on.

## Design

Do this pass yourself; it is the part that needs judgement.

First state the problem the change solves, in terms of behaviour rather than code.
Then ask how you would solve that problem in this codebase if the change did not exist, reading beyond the diff as far as the answer needs.
The best alternative often changes existing code the diff only works around.

Compare the change against that design. Look in particular for:

- state with more than one owner, or derived state stored rather than computed;
- a new mechanism that parallels one the codebase already has;
- special cases a better representation or boundary would remove;
- edge-case handling out of proportion to how often the case occurs and what it costs when it does;
- invariants every caller must remember, where the type or module could hold them instead;
- abstractions, options or extension points with one user and no planned second;
- changes that will force edits in several places the next time this area moves;
- tests pinned to implementation details rather than behaviour.

Speculative generality and cosmetic churn are debt too.
An alternative is worth raising only when it removes something: a concept, a duplicated mechanism, an invariant, a class of future edits, or a real performance cost.
If the current approach is sound, say so and stop looking.

For each alternative worth raising, give:
what changes and where; the upfront cost, including migration and risk; what it removes or prevents over time; and whether it belongs in this change, in a follow-up, or nowhere.
Prefer one focused restructuring that dissolves several findings over a list of local fixes.

## Report

Lead with a one-line verdict: merge as is, adjust within this change, merge and follow up, or rethink the approach.

Then:

- **Correctness:** each confirmed defect, and each uncertain one marked as such.
- **Design:** the current approach in a few sentences, then the alternatives ranked by net benefit, each with its tradeoff as above.
  Keep necessary fixes apart from optional improvements.
- **Questions:** decisions that belong to the owner, with a recommendation for each.

Change no code in this pass.
The owner chooses which alternatives to take; offer to implement them, or to file follow-ups, afterwards.
