---
name: propose-rework
description: Design one large rework — a restructuring with high upfront cost for lasting gains in maintainability, performance or correctness, possibly changing behaviour — as a costed proposal with an incremental migration, for the owner to decide. Use when asked to plan or evaluate a rework, rewrite or re-architecture of a named part of a project; not for a change that fits in one PR.
---

# Propose one rework

An audit finds many things cheaply; this goes deep on one.
The output is a proposal the owner can say yes or no to, and a plan that can stop partway without leaving things worse.

The target is what the invocation names (`$ARGUMENTS` in Claude, the text after `$propose-rework` in Codex):
a rework candidate from an audit, an issue, or a problem or goal in the owner's words.
If it names no outcome — what should become cheaper, faster, or impossible to get wrong — ask before designing.

This skill borrows from the `audit-drift` skill, installed beside this one; if it is not installed, say so and stop.

Read the project's local contract before starting, with its roadmap, recorded decisions, and the intent records of every area the rework touches.
Recorded decisions are not reopened silently; a rework that contradicts one says so and makes it a question.

The global engineering tradeoffs apply throughout.
The owner will usually pay substantial upfront work for a significant, lasting gain, and not for a marginal one.
"Don't" and "do the cheaper thing" are proposals too.

## Ground the problem

State what the current design costs today, with evidence:
the commits and PRs that paid for it, the bugs it produced, the measurements, the roadmap items it blocks.
If the cost cannot be shown, say so; the proposal may end there.

## Map what exists, in parallel

Run two read-only agents while you read the design yourself:

- **Describer:** the describer brief of the `audit-drift` skill (`references/describer.md` in that skill).
  Read it and pass it on, applied to the part being reworked;
  for an internal part, the behaviour to describe is what its callers observe at its interface.
  Its blind description is the behaviour the rework must keep or change on purpose.
- **Inventory**, on a fast model: every caller, entry point, persisted format, public interface, configuration key and test that touches the part.
  This is the surface the migration has to carry.

## Design

Ask how you would build this part if it did not exist, given everything else in the codebase as it is.
Then set out:

- **The target design:** what it removes — concepts, duplicated mechanisms, invariants callers must remember, classes of bug, measured cost — and what it adds.
- **The cheaper alternative:** the best set of targeted fixes within the current structure, and how much of the gain it gets.
- **Doing nothing:** what the current design will keep costing, given the roadmap.

If a design is open between two real options, compare them rather than picking silently.

## Spike the riskiest assumption

If an assumption could sink the target design — a performance target, a library's fit, migrating real data — test it now, before planning around it,
with a throwaway prototype in a worktree, following the contract for worktrees.
Do not open a PR or merge it; record what it showed and remove the worktree.
If it fails, revise the design and test again, or end with the cheaper alternative or with leaving it.
Skip this when nothing is uncertain enough to need it.

## Behaviour that changes

Compare the describer's account with the target.
Every difference is either a deliberate change — a yes/no question for the owner, with what happens on either answer —
or a regression the design must remove.
For persisted data, file formats and public interfaces, say how existing data and callers migrate or stay compatible.

## Migration

Plan steps that each land on their own, with the tests passing and the product shippable:

- First, tests that pin current behaviour where the rework will touch it, so an accidental change shows up as a failure and a deliberate one as an edited expectation.
- Then the smallest steps that move callers across, new and old side by side where needed.
  A flag or compatibility layer introduced for the migration gets its own removal step.
- Name the point of no return, if there is one, and what must be true before passing it.

If the rework cannot be incremental, say why, and what a single cut-over risks.

## Report

Lead with a one-line verdict: do the rework, do the cheaper alternative, or leave it.

Then:

- **Problem:** the cost today, with evidence.
- **Designs:** target, cheaper alternative and doing nothing, each with what it removes and what it costs.
- **Spike:** what it tested and what it showed, or why none was needed.
- **Behaviour changes:** the owner's yes/no questions, each with a recommendation.
- **Migration:** the steps, each sized roughly as a PR, and the point of no return.
- **Cost and risk:** total upfront cost, what is left if the work stops after any step,
  and the signs during the migration that should stop it.

Change no code beyond the spike.
Offer to file the proposal as an issue or a design document by the project's conventions, and to start the first step if the owner takes it.
When the owner answers the behaviour questions, offer to record them as `audit-drift`'s "Record the answers" section describes.
