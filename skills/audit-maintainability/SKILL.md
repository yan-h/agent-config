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

Whether a mechanism's reason still holds is drift, the `audit-drift` skill's question; such a finding is noted for a drift audit, not pursued.

**Debt counts only when it taxes changes that happened or that the roadmap commits to.**
Without a roadmap, weigh debt by how often the area changed over the last year.
Every finding cites the commits or PRs that paid for it, or the roadmap item it would make costly.

## Choose the scope

The text after the invocation names one area (`$ARGUMENTS` in Claude, the text after `$audit-maintainability` in Codex).

With none, audit every area.
Use the area map from the last area-based audit's tracking issue if there is one, so findings from different audits line up;
otherwise map the project as the `audit-drift` skill's "Choose the scope" section describes.
Read each area's intent record if it exists.
Earlier audits' "checked and healthy" lists hold only for what they checked:
a performance audit's clean list says nothing about structure, so pass an auditor only what bears on its question.
Read the last maintainability audit's tracking issue too, for its seen-and-left list,
and the open tracking issues and rework issues from earlier audits, so a candidate already listed is linked rather than listed twice.

## Map where change lands

Before any auditor reads code, survey the history of the primary branch, over the last year or the last few hundred commits,
whichever the project's pace makes more telling.
Fetch first, then name the remote primary branch explicitly, or the local one if the project has no remote;
in a feature worktree `HEAD` is the wrong history, and a local primary branch may be stale.

Run [`scripts/history-map.py`](scripts/history-map.py) from inside the project, once for the whole project and once per area with `--path`:

```sh
python3 <this skill's directory>/scripts/history-map.py origin/<primary> --since "1 year ago" \
  --exclude '^docs/' --exclude '\.lock$' [--path <file or directory> ...]
```

It follows renames to each file's current path, which plain `git log --name-only` does not:
a project that renamed its crates otherwise splits each file's history in two and hides its hotspots.
`--max-count N` takes the last N changes instead of a date. It reports:

- **Hotspots:** the files changed most often, beside their size.
- **Change coupling:** files in different directories that keep changing together.
- **Fix clusters:** beside each hotspot, how many of its changes have a fix-like subject.
  A rough signal at best — in the first trial most hits were feature PRs or predated a rewrite.
  Prefer the project's bug label or linked bug issues where it has them, and read each commit before citing it.
- **Widest changes:** the changes that touched the most files.
  Hand the auditor the file lists of those that changed a single concept, such as adding or removing one setting.

Exclude generated files, lockfiles and prose the project regenerates.
For an area's slice pass every file and directory it spans; an area that does not map onto paths gets the whole map, and the auditor picks its files from it.

## Per area, one auditor

Read [the auditor brief](references/auditor.md) completely before delegating.
Give each auditor that brief, its area, its part of the history map, the area's intent record, and the project contract.
The auditor's work is consequential judgement; size it by the global subagent guidance.
Run a few areas at a time rather than every agent at once, so each area's results are verified while the next ones run.

## Verify, then sort

Verify every finding against the primary branch before it goes anywhere:
that the duplication, the owners, or the coupling are what the auditor says, and that the cited commits paid what it says they paid.

Then sort what survived:

- **Mechanical:** behaviour-preserving, local, and needing no decision — a dead path, a duplicated helper with an obvious survivor.
  File one grouped issue per area, skipping anything an open issue already covers.
- **Rework candidates:** findings grouped by a shared design cause, or needing a change across areas or interfaces.
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
a rework the owner has declined is recorded with the reason in every area it touches, so it is not proposed again unchanged.
