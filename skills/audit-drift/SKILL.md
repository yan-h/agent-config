---
name: audit-drift
description: Audit a project, or one named area, for drift from the owner's intent — code whose reason has gone or never paid for it, frozen values that stopped fitting, tests guarding a mechanism, prose describing code that no longer exists. Started only by the repository owner invoking it explicitly.
disable-model-invocation: true
---

# Audit for drift from intent

**The owner starts this.** A session that notices drift says an audit looks due and stops there, rather than running the procedure below by hand.
Codex ignores `disable-model-invocation`, so there this paragraph is the rule itself.

This audit follows the sections of [the `audit-shared` skill](../audit-shared/SKILL.md) named below, installed beside this one; if it is not installed, say so and stop.
Start by reading the project's local contract as its "Read the contract" section describes.
The `propose-rework` skill uses the describer brief by name; rename it only together with that skill.

## What drift is

Code that no longer serves the owner's intent although every change on the way was locally reasonable:
a reason that moved while the code it justified stayed, or a reason that never paid for that code.
The auditor brief lists its kinds and typical shape.

## Choose the scope

The text after the invocation names one area (`$ARGUMENTS` in Claude, the text after `$audit-drift` in Codex):
a feature or part of the product as the owner names it.

With no area, audit every area, mapped as the `audit-shared` skill's "Map the areas" section describes.
Read each area's intent record as its "Read the intent records" section describes.

## Per area, two agents in parallel

Both read-only, on the primary branch fetched fresh from its remote, since a local one may be stale.
Pass each its brief from `references/` and the area, and tell them never to swap any shared installed build.
The auditor also gets the area's intent record and the project's stakes record; the describer gets nothing else.

- **Describer** (`references/describer.md`): writes how the area BEHAVES from the current code alone,
  blind to history on purpose, so it reports what the code does rather than what anyone meant.
- **Auditor** (`references/auditor.md`): traces the area's mechanisms to the PRs that added them and asks whether each reason still holds and ever paid for the mechanism.

The auditor's work is consequential judgement; the describer's is lighter.
Run a few areas at a time rather than every agent at once, so each area's results are verified while the next ones run.

## Verify, then sort

Verify every finding against the primary branch before it goes anywhere, a necessity row's line counts included:
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

**Never hand the owner a raw description**; a long page comes back mostly "fine".
Keep at most five questions per area, each answerable yes or no, each with what you would do on either answer.

## Report, fix what needs no answer, and record the answers

Lay the report out as the `audit-shared` skill's "Report so it can be taken piecemeal" section describes.
When the owner asks for the fixes too, make them as its "Fix what needs no answer" section describes.
Record the owner's answers as its "Record the answers" section describes.
