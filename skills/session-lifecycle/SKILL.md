---
name: session-lifecycle
description: Preserve build handoffs and reclaim disposable compilation output when a coding task finishes, then release resolved worktrees through their owner. Use at handoff, after a merge or abandonment, and when a completed session leaves large build caches.
---

# Finish the work and its workspace

The owning session handles cleanup; subagents sharing its checkout report completion to that owner.
A pause, an unanswered question, or an open PR is not permission to discard source work.
Never manufacture a permanent Git worktree lock.

Read the project's `.agent-lifecycle.json` and handover contract.
Package names, artifact paths and loader commands belong there, not in this skill.
The helper requires Python 3.11+ on macOS or Linux.
The shared CLI is `python3 <this-skill>/scripts/lifecycle.py --repo <checkout>`;
configured repositories also provide `./session-lifecycle.sh`.
No configuration means no guessed artifact or cache paths.

## During work

Use `./session-lifecycle.sh run -- <command>` for builds, tests, checks and other commands that write compilation output.
The helper holds one workspace lock outside `target/` and invalidates an old completion record before starting.
Project CI also participates when this skill is installed.
Custom Cargo target/build directories are unsupported; keep their caches rather than guessing.
The configured projects pin Cargo 1.92; cleanup also takes its native debug/release locks, without replacing those lock files.
Revisit that contract when changing Cargo's output layout or locking behavior.

## Hand over

Commit, push and open the required draft PR before building.
Run `./session-lifecycle.sh handoff` after tests finish.
It runs the project's declared build, publishes the complete artifact set under the repository's common Git directory, verifies checksums, then removes compilation intermediates.
The source checkout and top-level loadable binaries remain available.
The publication records the actual committed source used by this build; dirty source is refused.
A failed build or publication preserves the previous handoff and does not prune caches.

For a pause during active iteration use `handoff --keep-cache`, or the project's ordinary build command if source is still uncommitted.
Do not call a pause completed.
For a source-only task that requires no new plugin build, use `finish --source-only` after its verification.
For an already published handoff, `finish` verifies the publication before pruning.
Local completion does not prove a remote push; check the push/PR separately before owner release.

Report the preserved build, how to load it, and whether source cleanup remains pending.
The helper never swaps the DAW's installed slot.

## Release source through its owner

After a confirmed merge or explicit abandonment, check that no new work or owned process remains.
For a Codex-managed worktree, use the app's archive-worktree tool with its actual attachment identity.
If it cannot archive a primary, pinned or shared checkout, report owner release pending.
Do not delete it with Git or modify Codex's private state.
Archive the chat only when that is wanted; retaining chat history does not require retaining compilation caches.

For a Claude-owned worktree, use the reclaimer this skill ships at `scripts/reclaim-worktrees.sh`.
The sweep runs it directly for each configured repository; a repository's SessionStart hook and hand-runs reach it through a thin `.claude/reclaim-worktrees.sh` wrapper.
Its lock, clean-tree and merge gates are tested by `scripts/test_reclaim_worktrees.sh`, which agent-config's `scripts/check.py` runs.
Unknown/manual locks remain protected and need the owner's decision.
Use the native owner mechanism for other hosts; unsupported ownership is a reported limitation, not permission to force removal.
Do not delete another agent's worktree because your work has finished.

## Fallback and retention

`sweep` is a preview; `sweep --apply` reclaims completed caches and runs the shipped reclaimer.
The installed macOS job runs this hourly without an AI session and only for explicitly registered projects with lifecycle support on their main checkout.
It leaves source release for Codex pending; there is no supported shell replacement for the app archive tool.

The default artifact budget is 5 GiB per repository, with resolved handoffs eligible after 14 days.
The newest unresolved branch build, the currently selected preserved build, and publications containing a `PIN` file survive both limits.
Older handoffs for the same branch are eligible for eviction when the budget or age limit is exceeded.
A GitHub lookup failure retains artifacts.
If protected artifacts exceed the budget, report that fact rather than evicting them.
The budget covers preserved deliverables; active source/build caches can still exceed it and are not forcibly deleted.

Install or update with `python3 scripts/install.py --repo /path/to/repository` (repeat `--repo` for each project).
The installer links this skill into the Claude and shared agent catalogs, installs the deterministic job, and retains unrelated hooks and settings.
Shared global defaults come from agent-config's existing global instruction links; they take effect in new sessions after that revision is installed.
