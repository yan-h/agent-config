---
name: audit-maintainability
description: Audit a project, or one named area, for structure that makes its likely changes costly — duplicated mechanisms, state with several owners, boundaries every change has to cross — grounded in where history shows changes and fixes actually land. Started only by the repository owner invoking it explicitly.
disable-model-invocation: true
---

# Audit for structure that taxes change

**The owner starts this.** A session that notices costly structure says an audit looks due and stops there;
it does not run the procedure below by hand instead.
`disable-model-invocation` above enforces that in hosts that honour it;
Codex does not, so in Codex this paragraph is the rule itself.

Read the project's local contract before starting, with its roadmap and recorded decisions.
Worktrees, branch and PR conventions, and where intent records live all come from there;
where it says nothing about intent records, use `docs/intent/<area>.md`.
Recorded decisions are not reopened here; one the evidence strongly contradicts becomes a question for the owner.

This audit shares its area map, report layout and answer records with the `audit-drift` skill, installed beside this one.
Read that skill's `SKILL.md` for the sections named below; if it is not installed, say so and stop.

## What this audit is

The whole-area counterpart of the `design-review` skill:
not whether one change should have been written differently,
but whether the structure as it stands makes the changes this project actually makes more costly than they need to be.

It is not the `audit-drift` skill.
Whether a mechanism's reason still holds is drift; when a finding turns out to be that, note it for a drift audit and move on.
It is not a style review either: naming, formatting and local tidiness are out of scope.

**Debt counts only when it taxes changes that happened or that the roadmap commits to.**
Every finding cites the commits or PRs that paid for it — edits repeated in several places, fixes landing in the same spot —
or the roadmap item it would make costly.
Structure that looks wrong but has cost nothing and blocks nothing is listed as seen and left, not proposed for change.

## Choose the scope

The text after the invocation names one area (`$ARGUMENTS` in Claude, the text after `$audit-maintainability` in Codex).

With none, audit every area.
Use the area map from the last audit's tracking issue if there is one, so findings from different audits line up;
otherwise map the project as the `audit-drift` skill's "Choose the scope" section describes.
Read each area's intent record if it exists.
Read the last maintainability audit's tracking issue too, for its seen-and-left list,
and the open tracking issues and rework issues from earlier audits, so a candidate already listed is linked rather than listed twice.

## Map where change lands

Before any auditor reads code, survey the history of the primary branch, over the last year or the last few hundred commits,
whichever the project's pace makes more telling.
Name the primary branch's ref explicitly, as below; in a feature worktree `HEAD` is the wrong history.
This is bounded, mechanical work: do it in the calling session or in one agent on a fast model.

- **Hotspots:** the files changed most often, read beside their size.
- **Change coupling:** files, especially in different areas, that keep changing in the same commit.
- **Fix clusters:** where commits and PRs described as fixes land.
- **Scattered changes:** PRs that touched many files to change one concept.

```sh
git log <primary> --since=1.year --format= --name-only | sed '/^$/d' | sort | uniq -c | sort -rn | head -40
git log <primary> --since=1.year -i -E --grep='fix|bug' --format= --name-only | sed '/^$/d' | sort | uniq -c | sort -rn | head -40
```

Split the map by area.
It tells each auditor where reading will pay, and it is the evidence the findings cite.

## Per area, one auditor

Read [the auditor brief](references/auditor.md) completely before delegating.
Give each auditor that brief, its area, its part of the history map, the area's intent record, and the project contract.
The auditor's work is consequential judgement; size it by the global subagent guidance.
Auditors are read-only.
Run a few areas at a time rather than every agent at once, so each area's results are verified while the next ones run.

## Verify, then sort

Verify every finding against the primary branch before it goes anywhere:
that the duplication, the owners, or the coupling are what the auditor says, and that the cited commits paid what it says they paid.

Then sort what survived:

- **Mechanical:** behaviour-preserving, local, and needing no decision — a dead path, a duplicated helper with an obvious survivor.
  File one grouped issue per area, skipping anything an open issue already covers.
- **Rework candidates:** findings that share a design cause, or need a change across areas or interfaces.
  Group findings by cause first: one restructuring that dissolves several is worth more than each fixed locally.
  One paragraph each: the cause, the evidence, a sketch of the target, a rough upfront cost, and what it removes.
  The owner can take one into the `propose-rework` skill.
- **Needs the owner's call:** a fix that changes behaviour, a public interface or a recorded decision.
  At most five questions per area, each answerable yes or no, each with what you would do on either answer.
- **Seen and left:** debt with no history of cost and no roadmap pull, one line each,
  so the next audit does not rediscover it.

## Report

Lay the report out as the `audit-drift` skill's "Report so it can be taken piecemeal" section describes,
with the rework candidates ranked together after the index, by net benefit, since they often cross areas.
List the auditors' drift items in their area's section, for the next drift audit.
Record the owner's answers as that skill's "Record the answers" section describes;
a rework the owner has declined is recorded with the reason, so it is not proposed again unchanged.
