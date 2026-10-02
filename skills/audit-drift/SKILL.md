---
name: audit-drift
description: Audit a project for drift from the owner's intent — machinery whose reason has gone, frozen values that stopped fitting, tests guarding a mechanism instead of a behaviour, prose describing code that no longer exists. Every area by default, or one named area. Started only by the repository owner invoking it explicitly.
disable-model-invocation: true
---

# Audit for drift from intent

**The owner starts this.** A session that notices drift says an audit looks due and stops there;
it does not run the procedure below by hand instead.
`disable-model-invocation` above enforces that in hosts that honour it;
Codex does not, so in Codex this paragraph is the rule itself.

Read the project's local contract before starting.
Worktrees, branch and PR conventions, and where intent records live all come from there;
where it says nothing about intent records, use `docs/intent/<area>.md`.

The `audit-performance`, `audit-maintainability` and `propose-rework` skills use "Choose the scope", "Report so it can be taken piecemeal",
"Record the answers" and the describer brief by name; rename them only together with those skills.

## What drift is

Code that no longer serves the owner's intent although every change on the way was locally reasonable.
It is a different axis from a merge audit:
not a bug born where two branches meet, but a reason that moved while the code it justified stayed.

The shape it takes, from the case that prompted this skill:
a mechanism was added for one case, extended to others by analogy, and its setting removed and frozen at full strength.
Later the first case got a better method and left the mechanism,
and the PR that moved it said the remaining cases "keep their existing behaviour" —
leaving a mechanism no reason still held up, and a control that could no longer reach its own end.
Tests asserted the mechanism rather than the behaviour, so two kept passing after it stopped being true.

The kinds seen so far:

- **Orphaned mechanism:** its motivating case was removed or replaced, and it stays for the others.
- **Frozen or captured value that stopped fitting** once something beside it moved.
- **Test guarding a mechanism rather than a behaviour, or a fixture that cannot reach its case.**
- **Intent restated wrongly, then built on:** a handoff or cleanup keeps the data and loses the model.
- **Prose describing something removed.**

The common signal is a removal or replacement PR saying WHAT it keeps ("keep existing", "preserve", "unchanged", "comments only") and not WHY the kept part still has a reason.

## Choose the scope

The text after the invocation names one area (`$ARGUMENTS` in Claude, the text after `$audit-drift` in Codex):
a feature or part of the product as the owner names it.

With no area, audit every area.
First map the project into areas as the owner would name them —
features and parts of the product, not crates or directories — usually six to twelve.
Each should be small enough for one auditor to verify in a sitting.
Put the map at the top of the report so the owner can correct its boundaries next time.

Read each area's intent record if it exists: the owner's answers from earlier audits.
It is the one place the owner's picture of that area is written down;
a finding that contradicts it is the strongest kind, and a question it already answers is not asked again.

## Per area, two agents in parallel

Both read-only, on the primary branch.
Pass each its brief from `references/` and the area, and tell them never to swap any shared installed build.

- **Describer** (`references/describer.md`): writes how the area BEHAVES from the current code alone —
  no history, no PRs, no issues, no notes.
  Blind on purpose: in the first trial it found the known live case with none of the history the auditor had.
- **Auditor** (`references/auditor.md`): traces the area's mechanisms to the PRs that added them and asks whether each reason still holds.

Size them by the global subagent guidance: the auditor's is consequential judgement, the describer's is lighter.
In the first trial one area cost about 190k tokens for the describer and 275k for the auditor, twelve minutes of wall clock.
A full run is several million tokens; invoking with no area is the owner accepting that.
Run a few areas at a time rather than every agent at once, so each area's results are verified while the next ones run.

## Verify, then sort

Verify every finding against the primary branch before it goes anywhere;
an auditor's line numbers drift, and its "dead" can be a caller it missed.

Then sort what survived:

- **Mechanical:** nothing the owner would see changes, or the fix follows from a decision already on record.
  File one grouped issue per area, skipping anything an open issue already covers.
- **Needs the owner's call:** the behaviour may or may not be what the owner wants.
  A describer item qualifies only when the auditor's history shows its reason moved, a recorded decision contradicts it,
  or it has a consequence the owner would notice.

**Never hand the owner a raw description.**
In the first trial a forty-item page was tiring and came back mostly "fine" or "don't care".
Keep at most five questions per area, each answerable yes or no, each with what you would do on either answer.
The descriptions stay as working notes.

## Report so it can be taken piecemeal

One tracking issue per run (a Markdown file in the repository if the project has no tracker), titled with the kind of audit and the date:

- **An index first:** a table of every area with its question count, the issues filed for it, and a status the owner's answers tick off.
- **Then one self-contained section per area:**
  its questions, the mechanical issue filed for it, and anything notable that needed no decision.
  No section depends on another, so the owner can take one area in a sitting and leave the rest for another day.

Put the areas with the most consequential questions first.

## Record the answers

Whenever the owner answers an area's questions — in this session, a later one, or on the tracking issue —
the session receiving them writes them into that area's intent record, one line per decision:
the behaviour, the owner's call, the date and any issue it produced.
A "that's fine" is worth recording too; it is what stops the next audit asking again.
Nothing the owner did not answer goes in: the record is the owner's picture, not the describer's.

Tick the area in the index, file what the answers call for,
and land the intent records by the project's PR conventions.
