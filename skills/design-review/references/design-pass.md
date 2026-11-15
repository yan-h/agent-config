# The design pass and its report

## Design

First state the problem the change solves as behaviour, not code.
Then ask how you would solve that problem in this codebase if the change did not exist, reading beyond the diff as far as the answer needs.
The best alternative often changes existing code the diff only works around.

Do not take what the issue requires of the change as given, as passes on two reworks did.
Judge each requirement it took from existing behaviour as the global preferences say of what a project guarantees,
and raise as an alternative the design that drops the requirements nothing there protects;
a requirement in the owner's own words goes under Questions instead.
A decision this change is the first to build is under review with it:
defects that trace to its rule count against it, and an alternative departing from it is weighed like any other; patching around one left a module full of edge cases.

Compare the change against that design. Look in particular for:

- state with more than one owner, or derived state stored rather than computed;
- a new mechanism that parallels one the codebase already has;
- a rule, list or sequence the change edits that is spelled at other sites too:
  search for each one's other spellings, or where you cannot search say which sites you were shown,
  and name those the change missed as defects and the single owner as the alternative;
- special cases a better representation or boundary would remove;
- edge-case code the stakes record does not pay for;
- a side effect that a user action has no reason to cause: say what the action should cost and what would remove the gap;
- invariants every caller must remember, where the type or module could hold them instead;
- abstractions, options or extension points with one user and no planned second;
- changes that will force edits in several places the next time this area moves;
- tests pinned to implementation details rather than behaviour.

An alternative is worth raising only when it removes something: a concept, a duplicated mechanism, an invariant, a class of future edits, or a real performance cost.
If the current approach is sound, say so and stop looking.

For each, give:
what changes and where; whether it changes anything a user sees; the upfront cost, including migration and risk; what it removes or prevents over time; and whether it belongs in this change, in a follow-up, or nowhere.
Place it by its scope and its risk to this change, not by its upfront cost.
Prefer one focused restructuring that dissolves several findings over a list of local fixes.

## Report

Lead with a one-line verdict: merge as is, adjust within this change, merge and follow up, or rethink the approach.

Then:

- **Correctness:** each confirmed defect, and each uncertain one marked as such, with whether its case lies within the use and load the stakes record states and the worst it does,
  naming the alternative that would remove it if one would.
- **Design:** the current approach in a few sentences, then the alternatives ranked by lasting net benefit, counting the defects each removes, each with its tradeoff as above.
- **Questions:** decisions that belong to the owner, with a recommendation for each,
  each saying what its answer would alter, and whether a later change could apply that without undoing this one.
