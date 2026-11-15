---
name: audit-shared
description: Sections the audit skills follow by name. Read one only when another skill names it; never a task of its own.
user-invocable: false
disable-model-invocation: true
---

# What the audit skills share

`audit-drift`, `audit-maintainability`, `audit-performance` and `audit-premises` follow the sections below by name, and `propose-rework` follows this skill's "Record the answers" section.
A section binds only the skills that name it, and each of its sentences must hold for every one of them; change one only with all of them in view.

## Read the contract

Read the project's local contract, with its roadmap and recorded decisions.
Worktrees, branch and PR conventions, and where intent records live and their form all come from there;
where it says nothing about intent records, use `docs/intent/<area>.md`.

## Map the areas

Use the area map from the last area-based audit's tracking issue if there is one, so findings line up across audits and the owner's corrections carry over;
otherwise map the project into areas as the owner would name them —
features and parts of the product, not crates or directories — usually six to twelve,
each small enough for one auditor to verify in a sitting.

## Read the intent records

Read each area's intent record if it exists: the owner's answers from earlier audits.
A finding that contradicts it is the strongest kind, and a question it already answers is not asked again.

## Report so it can be taken piecemeal

One tracking issue per run, titled with the kind of audit and the date:

- **An index first:** a table of every area with its question count, the issues filed for it, and a status the owner's answers tick off.
- **Then one self-contained section per area:**
  its questions, the mechanical issue filed for it, and anything notable that needed no decision.

Put the areas with the most consequential questions first, and the area map at the top of the report so the owner can correct its boundaries next time.

## Fix what needs no answer, when the owner asks

The audit ends at its report unless the owner's own message asks for its fixes to be made, or made and merged.
Then, once the report is filed, sweep the issues this run filed:
follow the `sweep-issues` skill's sections from "Triage" through "Fix" with those issues as the scope, then this skill's "Review and merge the fixes" section.
Following the sweep's sections does not invoke that skill; if it is not installed, say so and leave the fixes filed.

Triage holds the audit's sorting to the sweep's bar; the report's questions and its rework candidates are outside the sweep.
When a fix the audit called mechanical proves wrong once built or reviewed, say on its issue what was tried and why it failed, and link the draft,
since the next sweep and audit read the issue, not the draft.

## Review and merge the fixes

Take each pull request through the `review-and-merge` skill's sections from "Decide whether to review" through "Review", its design pass included, because the audit designed these fixes itself.
Then merge them as `sweep-issues`' "Merge" section describes only where the owner's own message asked for the merge, and otherwise leave draft pull requests.
Following those sections invokes neither skill; if either is not installed, say so and leave the pull requests unmerged.

## Record the answers

Whenever the owner answers an area's questions — in this session, a later one, or on the tracking issue —
the session receiving them writes them into that area's intent record, in the form the project contract sets,
or where it sets none, one line per decision: the behaviour, the owner's call, the date and any issue it produced.
Record a "that's fine" too, and a struck necessity row as a keep, so the next audit does not ask again.
Nothing the owner did not answer goes in: the record is the owner's picture, not the describer's.

Tick the area in the index (an issue edit, so on the owner's word in chat as the global preferences say), file what the answers call for,
and land the intent records by the project's PR conventions.
