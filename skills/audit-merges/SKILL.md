---
name: audit-merges
description: Audit a batch of merges for defects created where otherwise-correct branches interact. Use after several branches have landed together, not as a per-PR review.
---

# Audit the combined merge range

Audit the code that has landed on the repository's primary branch since the last audit, looking for bugs that no single branch could have contained.

Parallel branches are each developed against the primary branch state they started from.
A per-branch review therefore cannot see failures created only when two branches are combined.
Read the combined diff, not the PRs one at a time.

## Choose the range

Use the first ref supplied after the invocation when one is present.
In Claude that argument is `$0`;
in Codex it is the text following `$audit-merges`.
Otherwise use the local Git tag `last-merge-audit`.
If that tag does not exist, inspect the last 12 first-parent merge commits into the primary branch.

The tag is local, so it is missing on a fresh clone.
Before trusting the fallback, look for a previous audit's merge in the log and start from there when one exists.

```sh
git rev-parse -q --verify last-merge-audit
git log --oneline --merges --first-parent -12
git diff --stat <since>..HEAD
```

`--first-parent` matters:
without it, the list can fill with branch catch-up merges rather than work landing on the primary branch.

If the range is trivially small—one or two merges touching disjoint files—report that and stop.

## Use the invoking host's own subagents

Read [the merge-auditor brief](references/merge-auditor.md) completely before delegating.
Give each survey agent that brief, the selected range, and one disjoint subsystem.

Use the invoking host's native subagent mechanism.
Never invoke another agent product, model host, or CLI to perform the audit.
A Codex invocation is performed entirely by Codex agents;
a Claude invocation is performed entirely by Claude agents.

For a range spanning more than one subsystem, run one subagent per disjoint subsystem concurrently rather than one over everything.
Subagents are read-only for the survey:
they return candidate findings and suspicions but do not edit, commit, tag, or open a PR.

## Prove and repair in the calling agent

The calling agent validates every candidate.
A finding is not a finding until a test or focused reproduction fails on the old code.
Observe the failure, fix it, and observe it pass.

Anything that cannot be reproduced stays under a separate **Suspicions** heading and is not fixed.
This keeps speculative repairs separate from demonstrated defects.

Follow the repository's local contract for worktrees, validation, commits, and pull requests.

### Repair the prose agents execute; only report the rest

Stale prose divides by who acts on it, and only one half is worth a hunk in this diff.

**Repair** the prose a session runs on:
`AGENTS.md`, `CLAUDE.md`, the agent configuration directory, the skills, and the helper scripts.
These are loaded or executed every session, so a wrong path or a falsified claim in them misroutes the next agent —
they are code with no compiler, and this audit is the only gate they have.

**Report, and do not fix,** drift in reference documentation and long-form design notes.
List it under a **Documentation drift** heading with the file and the claim that no longer holds, so it is on the record and cheap to pick up.
Left to itself this half grows to dominate the finding count —
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
That is the test for whether a defect belongs in this pull request at all.
A reachable defect earns the audit's failing test and its fix;
one that needs a state nobody reaches is real but unranked, and it competes better as an issue than as a hunk in a diff about something else.
Say in the issue what it would take to reach it, so triage has the thing the audit already knows.

This is the rule the audit exists to serve.
A reviewer who merges the result without reading it gets no value from a finding list they cannot rank,
and a list that opens with mechanism reads as uniform whether it holds six live defects or none.

## Report the result

If there are findings, describe each one with the observable line above, then what breaks, the real-world trigger, the reproduction, and the fix.
Also name the areas and hypotheses checked clean, and record the `<since>..HEAD` range and the pull requests or merges it contains.

If nothing is found, report the range and the specific clean list and make no code change.

After the audit, move the local marker so the next audit starts where this one ended:

```sh
git tag -f last-merge-audit HEAD
```

The tag is local on purpose and must not be pushed.
