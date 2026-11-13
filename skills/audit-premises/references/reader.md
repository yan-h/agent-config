# Reader brief

You are one of several independent readers in an audit of a project's premises.
Read [the rules](rules.md) first: what is open, how a candidate is judged, and what you may do.

## The question

For your area: if the owner allowed superseding any recorded decision, giving up any guarantee not rated must keep, and restructuring any code,
is there a significantly different design that serves the project's goals with markedly less code and machinery,
markedly better performance, or that removes a whole class of bugs?

"The current design is right, and here is why" is a full answer.
Tidying, renames, file splits and anything that fits one ordinary change without superseding a decision or replacing a structure are out of scope.

You were given the owner's standing preferences. They decide what counts as a cost and what does not, as amended by the ratings file's tolerances; apply them, and say where one decides a verdict.

## Method

1. Read the docs first: the project contract, the goals, your area's design, its live decision records and its intent record, as far as the project has them.
   Read the superseded records and closed issues too, for the owner's own stated reasons:
   in the first run the reason that defeated one candidate was in a superseded record no reader had opened,
   and another candidate's nearest form had been rejected in an issue the day before.
2. Read the code properly: whole files where the structure lives.
3. Look for signs that a premise, not an implementation, is what costs. You may have been given where change lands in your area; start there.
   - Several records patching one mechanism, or one record replaced again and again.
   - Fix chains where one mechanism is repaired repeatedly, and audit follow-ups that land in the same place.
   - Machinery whose only job is to maintain an invariant another representation would give for free.
   - One fact held in two representations kept in step.
   - Special cases keyed on a kind, mode or scope.
   - Code volume out of proportion to what a user gets from it, and capability nothing uses.
   - Work repeated on every cycle that a different structure would not do at all.
4. Weigh the tests in your area as owned code: how much there is, what it protects,
   and whether a different design or test strategy would make a large part unnecessary.

## Report

Rank your candidates and label each **strong**, **plausible** or **speculative**.
Report the ones you are unsure of; the coordinating session tests them.
Give the first five in full and each of the rest in a paragraph:

- **Premise at fault:** each record and structural assumption it supersedes, with the reason that no longer holds.
- **Recurring cost, with evidence:** commits, PRs, issues and `file:line`. Counted, not asserted.
  Read a claim of "every", "only" or "nothing" in the code before writing it.
- **Target design,** concrete enough to attack: what owns what, and what a typical change costs afterwards.
- **What goes away,** and **what is lost or put at risk,** naming each guarantee given up with its rating, and counting what goes with a don't-care one.
- **The strongest argument against,** whether the code supports it, and what change of shape would answer it.
- **Upfront effort,** as a fact.
- **Confidence.**

Then:

- **From scratch:** if this area were rebuilt today for the stated goals, with no obligation to any record, code, data or test beyond the must-keep guarantees,
  what it would be made of, what the current design has that it would not, and what it would do better.
  Go further than seems prudent.
- **Contracts you would break,** and what breaking each buys.
- **Guarantees the ratings file does not list,** each with what keeping it costs.
- **Considered and rejected,** each with the code or measurement that defeats it.
- **Load-bearing and right:** what a rework must not disturb, and why.

Precision over polish: `file:line` and record names over adjectives. About 3,000 words at most.
