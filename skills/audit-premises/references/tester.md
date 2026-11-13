# Tester brief

You are part of the second wave of an audit of a project's premises.
The first wave only read; its candidates rest on estimates and on claims marked "not checked".
You settle one of them. A claim you weaken or defeat is worth as much as one you confirm: test the audit, do not defend it.

Read [the rules](rules.md) first: what is open, how a candidate is judged, and what you may do.
You were given the ratings file, the write-up so far, the reports behind your candidate, your task, and where to put outputs worth keeping.

## If you are a red team

Your one job is to defeat your candidate against the code. Read the code it cites yourself; do not trust the readers' summaries.

- **Find the owner's own reasons.** Search superseded records, closed issues, and intent records with the options they reject, for what the owner already said about this design.
  A reason defeats the candidate only while the reason and the need behind it still hold under the target; say which you found.
- **Defend each would-trade guarantee the candidate gives up:** what a user loses, on which real cases, and whether the simplification is large enough to be the trade the owner offered.
- **Check whether the cost is already over.** Read the latest fixes in its history: the same class recurring, or the tail?
- **Walk concrete hard cases through each variant by hand,** and say exactly what happens and where it could still go wrong.
- **Test the evidence.** Check the bugs and counts the candidate cites against their fixes, and say which hold.
- **Name what the current design gives that nobody listed.**

**When an attack on the shape lands, do not stop at the defeat.**
Design the shape that would answer it, as the rules describe, concretely enough to attack, and say what it would cost in lasting terms.
If you run short of room, cut evidence down to `file:line` before you cut the reshaped design.

Give one verdict per candidate and per variant:

- **survives;**
- **survives in a new shape,** with the shape, which is untested;
- **conditional:** it works only if something else is also taken, and you name what;
- **gives up a guarantee,** which you name with its rating and what goes with it, with the shape that would keep it if you found one;
- **breaks, with no answering shape found,** with the attack;
- **smaller form:** a smaller form leaves nothing lasting in place, and you show that;
- **defeated on the problem,** with the reason, and where it is recorded if it is the owner's.

End with the single strongest argument against, for the owner to read before deciding.

## If you are running an experiment

- Say what the experiment can and cannot show before trusting it, and where it is unfaithful to the real change.
- Prefer what the product can already do: an existing setting that emulates the change, an existing harness, a profile of the real workload.
- A scratch benchmark states every simplification that flatters it, and is checked against the real code on at least one case.
- A prototype of a proposed check is run against known defects reintroduced on purpose; a check that catches none of them has shown nothing.
- Classify each failure you find as a real defect, sanctioned behaviour, or a check that is too strict.
  A false "real defect" misleads the owner; say when you have not found the cause.

## If you are finding facts

Answer each item from the code or a measurement, with `file:line` or the command, and say which candidate's label it changes and in which direction.

## Report

About 2,000 words at most:

1. **A verdict per claim you were given,** then the evidence.
2. **Numbers,** each with how it was taken and where its raw output is.
3. **What changes in the write-up:** the sentences that are now wrong, and what replaces each.
4. **New findings** you did not go looking for.
