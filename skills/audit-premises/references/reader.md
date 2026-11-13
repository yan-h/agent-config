# Reader brief

You are one of several independent readers in an audit of a project's premises.
Read `SKILL.md` in the directory above this file for what the audit is and the two rules that judge every candidate.

Audit the primary branch, read-only: no edits, no commits, no branch changes, no builds, no subagents.
Version-control history, PR titles and bodies, and issues are all available.

## The question

Every other audit took the recorded design as given.
For your area: if the owner allowed superseding any recorded decision and restructuring any code,
is there a significantly different design that serves the project's goals with markedly less code and machinery,
markedly better performance, or that removes a whole class of bugs?

"The current design is right, and here is why" is a full answer.
Tidying, renames, file splits and anything that fits one ordinary change without superseding a decision or replacing a structure are out of scope.

You were given the owner's standing preferences. They decide what counts as a cost and what does not; apply them, and say where one decides a verdict.

## Method

1. Read the docs first: the project contract, the goals, your area's design section, its live decision records, and its intent record.
   Read the superseded records and closed issues too, for the owner's own stated reasons:
   in the first run the reason that defeated one candidate was in a superseded record no reader had opened,
   and another candidate's nearest form had been rejected in an issue the day before.
2. Read the code properly: whole files where the structure lives.
3. Look for signs that a premise, not an implementation, is what costs:
   - several records patching one mechanism, or one record replaced again and again;
   - fix chains where one mechanism is repaired repeatedly, and audit follow-ups that land in the same place;
   - machinery whose only job is to maintain an invariant another representation would give for free;
   - one fact held in two representations kept in step;
   - special cases keyed on a kind, mode or scope;
   - code volume out of proportion to what a user gets from it, and capability nothing uses;
   - work done on every tick or frame that a different structure would not do at all.
4. Weigh the tests in your area as owned code: how much there is, what it protects,
   and whether a different design or test strategy would make a large part unnecessary.

## Report

As many candidates as you find, ranked, each labelled **strong**, **plausible** or **speculative**.
Report the ones you are unsure of; the coordinating session tests them. For each:

- **Premise at fault:** the records and structural assumptions it supersedes.
- **Recurring cost, with evidence:** commits, PRs, issues and `file:line`. Counted, not asserted.
  Read a claim of "every", "only" or "nothing" in the code before writing it.
- **Target design,** concrete enough to attack: what owns what, and what a typical change costs afterwards.
- **What goes away,** and **what is lost or put at risk.**
- **The strongest argument against,** whether the code supports it, and what change of shape would answer it.
- **Upfront effort,** as a fact.
- **Confidence,** and what you did not check.

Then:

- **From scratch:** if this area were rebuilt today for the stated goals, with no obligation to any record, code, data or test,
  what it would be made of, what the current design has that it would not, and what it would do better.
  Go further than seems prudent.
- **Contracts you would break,** and what breaking each buys.
- **Considered and rejected,** each with the code or measurement that defeats it.
- **Load-bearing and right:** what a rework must not disturb, and why.

Precision over polish: `file:line` and record names over adjectives. About 2,500 words at most.
