# The design pass and its report

## Design

State the problem from the issue or request, in terms of behaviour rather than code.
Design your own solution in this codebase before reading the diff or the author's reasoning, reading as far as the answer needs.
The best alternative often changes existing code the diff only works around.

Then compare the change against that design.
An alternative the author rejected is a claim to check in the code, not a settled point.
Look in particular for:

- state with more than one owner, or derived state stored rather than computed;
- a new mechanism that parallels one the codebase already has;
- special cases a better representation or boundary would remove;
- edge-case handling out of proportion to how often the case occurs and what it costs when it does;
- invariants every caller must remember, where the type or module could hold them instead;
- abstractions, options or extension points with one user and no planned second;
- changes that will force edits in several places the next time this area moves;
- tests pinned to implementation details rather than behaviour.

An alternative is worth raising only when it removes something: a concept, a duplicated mechanism, an invariant, a class of future edits, or a real performance cost.
If the current approach is sound, say so and stop looking.

For each alternative worth raising, give:
what changes and where; the upfront cost, including migration and risk; what it removes or prevents over time; and whether it belongs in this change, in a follow-up, or nowhere.
Prefer one focused restructuring that dissolves several findings over a list of local fixes.

## Report

Lead with a one-line verdict: merge as is, adjust within this change, merge and follow up, or rethink the approach.

Then:

- **Correctness:** each confirmed defect, and each uncertain one marked as such, naming the alternative that would remove it if one would.
- **Design:** the current approach in a few sentences, then the alternatives ranked by net benefit, counting the defects each removes, each with its tradeoff as above.
- **Questions:** decisions that belong to the owner, with a recommendation for each.
