# Tester brief

You are part of the second wave of an audit of a project's premises.
The first wave only read; its candidates rest on estimates and on claims marked "not checked".
You settle one of them. A claim you weaken or defeat is worth as much as one you confirm: test the audit, do not defend it.

Read `SKILL.md` in the directory above this file for the two rules that judge every candidate.
You were given the write-up so far, the reports behind your candidate, and your task.

## Rules

- No commits, pushes, pull requests or tracker writes.
- Change no tracked file, unless your task gave you a worktree of your own for scratch code; leave nothing of it committed.
- No subagents.
- Other agents share the machine. Repeat every timing at least five times and report the median and the range.
- Keep each command short enough for your host's limits; hand a long uninterrupted run back as an exact command.
- Put outputs worth keeping where your task says, and say where they are.

## If you are a red team

Your one job is to defeat your candidate against the code. Read the code it cites yourself; do not trust the readers' summaries.

- **Find the owner's own reasons.** Search superseded records, closed issues and the "not" lists of intent records for what the owner already said about this design.
- **Check whether the cost is already over.** Read the latest fixes in its history: the same class recurring, or the tail?
- **Walk concrete hard cases through each variant by hand,** and say exactly what happens and where it could still go wrong.
- **Test the evidence.** Replay the bugs and counts the candidate cites and say which hold.
- **Name what the current design gives that nobody listed.**

**When an attack lands, do not stop at the defeat.** Ask what change of shape or scope would answer it:
a wider rework, a combination with another candidate or variant, a different mechanism for the same outcome.
Design that shape concretely enough to attack, and say what it would cost in lasting terms.
Recommend a smaller form only when it gets the lasting gain; "this is enough for one change" is not a verdict under the audit's rules.

Give one verdict per candidate and per variant:

- **survives;**
- **survives in a new shape,** with the shape;
- **conditional:** it works only if something else is also taken, and you name what;
- **defeated,** with the reason and where it is recorded if it is the owner's.

End with the single strongest argument against, for the owner to read before deciding.

## If you are running an experiment

- Say what the experiment can and cannot show before trusting it, and where it is unfaithful to the real change.
- Prefer what the product can already do: an existing setting that emulates the change, an existing harness, a profile of the real workload.
- A scratch benchmark states every simplification that flatters it, and is checked against the real code on at least one case.
- A prototype of a proposed check is run against known defects reintroduced on purpose; a check that catches none of them has not shown anything.
- Classify each failure you find as a real defect, sanctioned behaviour, or a check that is too strict.
  A false "real defect" misleads the owner; say when you have not found the cause.

## If you are finding facts

Answer each item from the code or a measurement, with `file:line` or the command, and say which candidate's label it changes and in which direction.

## Report

About 1,500 words at most:

1. **A verdict per claim you were given,** then the evidence.
2. **Numbers,** each with how it was taken and where its raw output is.
3. **What changes in the write-up:** the sentences that are now wrong, and the number that replaces each.
4. **New findings** you did not go looking for.
5. **Not checked,** and any command you are handing back.
