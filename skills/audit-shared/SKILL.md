---
name: audit-shared
description: Sections the audit skills share — the area map, intent records, the tracking issue's layout, sweeping an audit's fixes, and recording the owner's answers. Read only when another skill names one of its sections; never a task of its own.
user-invocable: false
disable-model-invocation: true
---

# What the audit skills share

`audit-drift`, `audit-maintainability`, `audit-performance` and `audit-premises` follow the sections below by name, and `propose-rework` also follows this skill's "Record the answers" section.
A section binds only the skills that name it, so each of its sentences must hold for every one of them; change a section only with all of them in view.

## Map the areas

Use the area map from the last area-based audit's tracking issue if there is one, so findings from different audits line up and the owner's corrections carry over;
otherwise map the project into areas as the owner would name them —
features and parts of the product, not crates or directories — usually six to twelve.
Each should be small enough for one auditor to verify in a sitting.
Put the map at the top of the report so the owner can correct its boundaries next time.

## Read the intent records

Read each area's intent record if it exists: the owner's answers from earlier audits.
It is the one place the owner's picture of that area is written down;
a finding that contradicts it is the strongest kind, and a question it already answers is not asked again.

## Report so it can be taken piecemeal

One tracking issue per run (a Markdown file in the repository if the project has no tracker), titled with the kind of audit and the date:

- **An index first:** a table of every area with its question count, the issues filed for it, and a status the owner's answers tick off.
- **Then one self-contained section per area:**
  its questions, the mechanical issue filed for it, and anything notable that needed no decision.

Put the areas with the most consequential questions first.

## Fix what needs no answer, when the owner asks

The audit ends at its report unless the owner's own message asks for its fixes to be made, or made and merged.
Then, once the report is filed, sweep the issues this run filed:
follow the `sweep-issues` skill's sections from "Triage" through "Fix" with those issues as the scope,
then take each pull request through the `review-and-merge` skill's sections from "Decide whether to review" through "Review", its design pass included, because the audit designed these fixes itself,
and merge them as `sweep-issues`' "Merge" section describes, or leave draft pull requests when the owner asked only for fixes.
Following those sections invokes neither skill; if either is not installed, say so and leave the fixes filed.

Triage holds the audit's sorting to the sweep's bar; the report's questions and its rework candidates are outside the sweep.
When a fix the audit called mechanical proves wrong once built or reviewed, say on its issue what was tried and why it failed, and link the draft:
in one run three such fixes were built and reverted, and the issue is what the next sweep and the next audit read.

## Record the answers

Whenever the owner answers an area's questions — in this session, a later one, or on the tracking issue —
the session receiving them writes them into that area's intent record, in the form the project contract sets,
or where it sets none, one line per decision: the behaviour, the owner's call, the date and any issue it produced.
A "that's fine" is worth recording too, and so is a struck necessity row, as a keep; it is what stops the next audit asking again.
Nothing the owner did not answer goes in: the record is the owner's picture, not the describer's.

Tick the area in the index, file what the answers call for,
and land the intent records by the project's PR conventions.
