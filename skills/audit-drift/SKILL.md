---
name: audit-drift
description: Audit a project for drift from the owner's intent — machinery whose reason has gone or that the project's stakes do not pay for, frozen values that stopped fitting, tests guarding a mechanism instead of a behaviour, prose describing code that no longer exists. Every area by default, or one named area. Started only by the repository owner invoking it explicitly.
disable-model-invocation: true
---

# Audit for drift from intent

**The owner starts this.** A session that notices drift says an audit looks due and stops there;
it does not run the procedure below by hand instead.
`disable-model-invocation` above enforces that in hosts that honour it;
Codex does not, so in Codex this paragraph is the rule itself.

Read the project's local contract before starting.
Worktrees, branch and PR conventions, and where intent records live and their form all come from there;
where it says nothing about intent records, use `docs/intent/<area>.md`.

This audit follows the sections of the `audit-shared` skill named below, installed beside this one; if it is not installed, say so and stop.
The `propose-rework` skill uses the describer brief by name; rename it only together with that skill.

## What drift is

Code that no longer serves the owner's intent although every change on the way was locally reasonable.
It is a different axis from a merge audit:
not a bug born where two branches meet, but a reason that moved while the code it justified stayed,
or a reason that never paid for that code.

The shape it takes, from the case that prompted this skill:
a mechanism was added for one case, extended to others by analogy, and its setting removed and frozen at full strength.
Later the first case got a better method and left the mechanism,
and the PR that moved it said the remaining cases "keep their existing behaviour" —
leaving a mechanism no reason still held up, and a control that could no longer reach its own end.
Tests asserted the mechanism rather than the behaviour, so two kept passing after it stopped being true.

The kinds seen so far:

- **Orphaned mechanism:** its motivating case was removed or replaced, and it stays for the others.
- **Mechanism the stakes record does not pay for,** as the global preferences say of what a project guarantees, though its reason holds.
- **Frozen or captured value that stopped fitting** once something beside it moved.
- **Test guarding a mechanism rather than a behaviour, or a fixture that cannot reach its case.**
- **Intent restated wrongly, then built on:** a handoff or cleanup keeps the data and loses the model.
- **Prose describing something removed.**

## Choose the scope

The text after the invocation names one area (`$ARGUMENTS` in Claude, the text after `$audit-drift` in Codex):
a feature or part of the product as the owner names it.

With no area, audit every area, mapped as the `audit-shared` skill's "Map the areas" section describes.
Read each area's intent record as its "Read the intent records" section describes.

## Per area, two agents in parallel

Both read-only, on the primary branch.
Pass each its brief from `references/` and the area, and tell them never to swap any shared installed build.
The auditor also gets the area's intent record and the project's stakes record; the describer gets nothing else.

- **Describer** (`references/describer.md`): writes how the area BEHAVES from the current code alone.
  Blind on purpose: in the first trial it found the known live case with none of the history the auditor had.
- **Auditor** (`references/auditor.md`): traces the area's mechanisms to the PRs that added them and asks whether each reason still holds and ever paid for the mechanism.

The auditor's work is consequential judgement; the describer's is lighter.
Per area, a describer has cost about 115k to 220k tokens and an auditor 210k to 300k, across the first trial and three later full runs, the latest of which priced necessity;
the first trial's area took twelve minutes of wall clock.
A full run is several million tokens; invoking with no area is the owner accepting that.
Run a few areas at a time rather than every agent at once, so each area's results are verified while the next ones run.

## Verify, then sort

Verify every finding against the primary branch before it goes anywhere, a necessity row's line counts included;
an auditor's line numbers drift, and its "dead" can be a caller it missed.

Then sort what survived:

- **Mechanical:** nothing the owner would see changes, or the fix follows from a decision already on record.
  File one grouped issue per area, skipping anything an open issue already covers.
- **Needs the owner's call:** the behaviour may or may not be what the owner wants.
  A describer item qualifies only when the auditor's history shows its reason moved, a recorded decision contradicts it,
  or it has a consequence the owner would notice.
- **Necessity rows:** sort each simplification or cut in the auditor's table as the global preferences say of what a project guarantees.
  One that is yours to decide joins the area's mechanical issue.
  The owner's go into the report as a table, largest removal first and ten rows at most, saying for each what the owner would see when the case occurs;
  rows past ten go in the area's grouped issue, marked as the owner's.
  That table counts as one of the area's questions: the owner takes it whole or strikes rows.

**Never hand the owner a raw description.**
In the first trial a forty-item page was tiring and came back mostly "fine" or "don't care".
Keep at most five questions per area, each answerable yes or no, each with what you would do on either answer.

## Report, fix what needs no answer, and record the answers

Lay the report out as the `audit-shared` skill's "Report so it can be taken piecemeal" section describes.
When the owner asks for the fixes too, make them as its "Fix what needs no answer, when the owner asks" section describes.
Record the owner's answers as its "Record the answers" section describes.
