---
name: audit-merges
description: Audit a batch of merges for defects created where otherwise-correct branches interact. Started only by the repository owner invoking it explicitly.
disable-model-invocation: true
---

# Audit the combined merge range

**The owner starts this,** since whether a batch is worth a multi-agent run is a judgement about what the owner is spending.
A session that has just watched branches land says the range looks worth auditing and stops there, rather than running the procedure below by hand.
Codex ignores `disable-model-invocation`, so there this paragraph is the rule itself.

Audit the code that has landed on the repository's primary branch since the last audit for bugs that no single branch could have contained:
each branch was developed against the primary branch it started from, so a per-branch review cannot see failures created only when two are combined.
Read the combined diff, not the PRs one at a time.

## Choose the range

Use the first ref supplied after the invocation when one is present.
In Claude that argument is `$0`;
in Codex it is the text following `$audit-merges`.
Otherwise start where the last audit ended:
the `<end>` of the newest first-parent commit whose subject begins `Merge audit <since>..<end>`.
If no commit carries the marker, start after the newest commit the log shows to be an earlier audit's fixes,
and failing that inspect the last 12 first-parent commits on the primary branch.

```sh
git log --first-parent -1 --format=%s -E --grep='^Merge audit [0-9a-f]+\.\.[0-9a-f]+'
git log --oneline --first-parent -12
git diff --stat <since>..HEAD
```

`--first-parent` matters:
without it, the list can fill with branch catch-up merges rather than work landing on the primary branch.

If the range is trivially small—one or two merges touching disjoint files—report that and stop.

## Survey, in parallel

Read [the merge-auditor brief](references/merge-auditor.md) completely before delegating.
Give each survey agent that brief, the selected range, and one disjoint subsystem, and run them concurrently rather than one over everything.
Their work is consequential judgement; size them by the global subagent guidance.

## Prove and repair in the calling agent

The calling agent validates every candidate.
A finding is not a finding until a test or focused reproduction fails on the old code.
Observe the failure, fix it, and observe it pass.

Give every suspicion a survey agent returns one focused attempt from the input it names, building no new harness for it.
One that reproduces is a finding.
Drop one only when the attempt shows that input behaving correctly;
otherwise file it with the evidence still missing.

**Nothing the audit leaves unfixed lives only in its pull request:** it is filed as an issue or dropped with a reason,
since items listed only in pull request bodies get no follow-up, while filed ones are fixed.
Before filing, search the open issues and the closed ones the owner declined,
and add to or link the one that covers it instead of filing again:
a clean audit leaves no marker, so the next one finds the same things.

Follow the repository's local contract for worktrees, validation, commits, and pull requests.

### Repair the prose agents execute; file the rest

**Repair** the prose a session runs on:
`AGENTS.md`, `CLAUDE.md`, the agent configuration directory, the skills, and the helper scripts,
and any step in another document that one of these sends a session to run.
A wrong path or false claim there misroutes the next agent, and nothing else checks it.

**File, and do not fix,** drift in reference documentation and long-form design notes:
one grouped issue per audit, naming each file and the claim that no longer holds.
Fixed in the audit's pull request, this drift, the easiest thing to find, buries the defects the audit exists to catch.
Where the search shows a document's drift filed before, file, as an issue of its own for the owner, the question whether that document still earns its place,
so the grouped issue needs no decision and `sweep-issues` can take it.

Comments in source files follow the code they sit beside:
repair one in a file the audit is already changing, file it with the drift otherwise.

## Lead every finding with what someone would have noticed

Each finding opens with one line naming what a person using the software would have observed —
the wrong picture, the wrong number, the failed export, the session that could not run its own checks.
Write it as the symptom, not the mechanism:
the reader decides whether to care from that line alone.

**A finding with no such line is filed as an issue rather than fixed here,**
saying what it would take to reach the state it needs:
a defect nobody reaches is real but unranked, and competes better as an issue than as a hunk in a diff about something else.

## Report the result

If there are findings, describe each one with the observable line above, then what breaks, the real-world trigger, the reproduction, and the fix.
List the issues filed and the suspicions dropped, with their reasons.
Also name the areas and hypotheses checked clean, and record the `<since>..HEAD` range and the pull requests or merges it contains.
Where the range's fixes return to a mechanism that earlier fixes also corrected, name it and those PRs and say a maintainability audit of it looks due:
repeated corrections are the debt that audit exists to find.

Title the pull request `Merge audit <since>..<end>: <what it fixes>`, with `<end>` the abbreviated hash of the primary-branch commit the audit read rather than the branch's own head.
Like any pull request it merges only on the owner's word, and the marker exists only once it lands:
the commit that lands on the primary branch must keep that subject, since the next audit starts from it.

If nothing is found, report the range and the specific clean list and make no code change.
A clean audit leaves no marker anywhere: the next audit surveying the range again is a cheaper failure than a marker outside the history that can skip work.
