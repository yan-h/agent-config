---
name: sweep-issues
description: Fix and merge every open issue the owner need not weigh in on, asking simple decisions up front and reporting the rest. Started only by the repository owner invoking it explicitly.
disable-model-invocation: true
---

# Sweep the open issues

**The owner starts this.** A session that thinks a sweep is due says so and stops there.
`disable-model-invocation` above enforces that in hosts that honour it;
Codex does not, so in Codex this paragraph is the rule itself.

**Invoking this skill is the owner's permission to merge.**
It overrides a project default that nothing merges unless the owner asks, for this run only,
and only for changes this procedure classifies as needing no owner input.

Scope is every open issue, unless the invocation names issues or a label.
In Claude that text is `$ARGUMENTS`; in Codex it is the text following `$sweep-issues`.

Read the project's local contract before starting.
Worktrees, branch and PR conventions, validation gates, review tools, merge method, and cleanup all come from there.

## Triage

Read every issue in scope, with its comments and linked PRs, and sort each into one of three groups.

- **No input:** the right fix is clear from the issue, the code, and the project's stated direction.
- **One simple decision:** a single choice between concrete options stands between the issue and a fix.
- **Needs input:** anything open-ended, or anything touching the areas below beyond what the issue already settles.

The owner weighs in on user-visible behaviour and design, removing features or options,
file formats, public interfaces, dependencies, and anything that conflicts with the roadmap or a recorded decision.
When unsure, the issue is not a no-input issue.

Ask every simple decision in one message, each with its options and a recommendation.
Start the no-input work without waiting for the answers; answered issues join it.

Do not close issues directly.
An issue closes when its fix merges; list issues that look already fixed or obsolete in the report.

## Plan

Group issues that change the same code into one branch, or order them.
Record which merges must precede which, including dependencies on PRs outside this sweep.

## Fix

One issue, or one tight group, per branch.
Delegate by the global subagent guidance; implementers run fast checks, and the coordinating session runs the full gates.

Keep each branch to its issue.
Implementers and reviewers report other problems they find to the coordinating session rather than fixing them in passing.
The coordinating session triages each one by the same bar:
a small no-input fix joins the sweep on its own branch, or rides along when it is a line or two in code the branch already changes;
anything else is filed as an issue.

If a fix turns out to need a decision after all, stop that issue, leave its branch as a draft PR, and ask.
Do not guess and merge.

Stop only processes this session started, by PID.
Sibling worktrees run the same gates, and a pattern kill such as `pkill -f` stops theirs too.

## Review

Review is at your discretion.
Review changes with real logic, shared state, concurrency, persistence, or an implementer who reported uncertainty.
Skip it for mechanical, documentation-only, or obviously correct one-line changes.

A review is independent: a different agent from the implementer, using the tool the project contract names.
Its fixes stay within the diff under review; anything else it finds goes to the coordinating session, as above.

## Merge

Merge one PR at a time, in the planned order.
Rebase onto the current primary branch, rerun the gates on the rebased branch, merge by the project's method, and confirm the merge landed before starting the next.

If the rebase conflicts beyond the change's own scope, or the gates fail for a reason outside it, leave the PR open and report it.

Clean up worktrees and branches as the project contract says.

## Report

- **Merged:** each PR with the issues it closes, and any problems it fixed that had no issue.
- **Open:** each PR left unmerged and what blocks it.
- **Needs input:** each skipped issue with the specific question that blocks it.
- **Other:** issues that look already fixed or obsolete, and issues filed during the sweep.
