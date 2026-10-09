---
name: audit-merges
description: Audit a batch of merges for defects created where otherwise-correct branches interact. Started only by the repository owner invoking it explicitly.
disable-model-invocation: true
---

# Audit the combined merge range

**The owner starts this.** A session that has just watched branches land says the range looks worth auditing and stops there;
it does not run the procedure below by hand instead.
Whether a batch is worth a multi-agent run is a judgement about what the owner is spending.

`disable-model-invocation` above enforces that in hosts that honour it.
Claude does, and Codex does not — and Codex reaches a skill by reading this file, so in Codex these three lines are the rule itself rather than a description of one.

Audit the code that has landed on the repository's primary branch since the last audit, looking for bugs that no single branch could have contained.

Parallel branches are each developed against the primary branch state they started from, so a per-branch review cannot see failures created only when two branches are combined.
Read the combined diff, not the PRs one at a time.

## Choose the range

Use the first ref supplied after the invocation when one is present.
In Claude that argument is `$0`;
in Codex it is the text following `$audit-merges`.
Otherwise start where the last audit ended:
the `<end>` of the newest first-parent commit whose subject begins `Merge audit <since>..<end>`.
That marker lives in the primary branch's history, so a cloud session and every clone find the same one;
a local tag is invisible to a cloud audit, which cannot move it either, so it goes stale and starts the next audit too early.
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

Anything that cannot be reproduced stays under a separate **Suspicions** heading and is not fixed.

Follow the repository's local contract for worktrees, validation, commits, and pull requests.

### Repair the prose agents execute; only report the rest

**Repair** the prose a session runs on:
`AGENTS.md`, `CLAUDE.md`, the agent configuration directory, the skills, and the helper scripts.
These are loaded or executed every session, so a wrong path or a falsified claim in them misroutes the next agent —
they are code with no compiler, and this audit is the only gate they have.

**Report, and do not fix,** drift in reference documentation and long-form design notes.
List it under a **Documentation drift** heading with the file and the claim that no longer holds, so it is on the record and cheap to pick up.
Left to itself this drift grows to dominate the finding count —
it is the easiest thing to find and the least likely to be read,
and an audit that spends its pull request on it buries the defects it exists to catch.

Comments in source files follow the code they sit beside:
repair one in a file the audit is already changing, report it otherwise.

## Lead every finding with what someone would have noticed

Each finding opens with one line naming what a person using the software would have observed —
the wrong picture, the wrong number, the failed export, the session that could not run its own checks.
Write it as the symptom, not the mechanism:
the reader decides whether to care from that line alone, and a mechanism they have to translate is a decision they will skip.

**A finding with no such line is filed as an issue rather than fixed here.**
A defect that needs a state nobody reaches is real but unranked, and it competes better as an issue than as a hunk in a diff about something else.
Say in the issue what it would take to reach it, so triage has the thing the audit already knows.

A reviewer who merges the result without reading it gets no value from a finding list they cannot rank,
and a list that opens with mechanism reads as uniform whether it holds six live defects or none.

## Report the result

If there are findings, describe each one with the observable line above, then what breaks, the real-world trigger, the reproduction, and the fix.
Also name the areas and hypotheses checked clean, and record the `<since>..HEAD` range and the pull requests or merges it contains.

Title the pull request `Merge audit <since>..<end>: <what it fixes>`, with `<end>` the abbreviated hash of the primary-branch commit the audit read rather than the branch's own head.
It merges into the marker the next audit starts from, so the commit that lands on the primary branch must keep that subject.

If nothing is found, report the range and the specific clean list and make no code change.
A clean audit leaves no marker, so the next audit surveys its range again;
re-checking is the cheaper failure than a marker outside the history that can skip work.
