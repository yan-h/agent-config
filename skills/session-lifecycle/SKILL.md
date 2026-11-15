---
name: session-lifecycle
description: Preserve build handoffs and reclaim compilation output when a coding task finishes, then release resolved worktrees through their owner. Use at handoff, after a merge or abandonment, and when a completed session leaves large build caches.
---

# Finish the work and its workspace

Read the project's `.agent-lifecycle.json` and handover contract.
The shared CLI is `python3 <this-skill>/scripts/lifecycle.py --repo <checkout>`, which any Python 3.9+ on macOS or Linux runs, macOS's own `python3` included (its Cargo layout check needs `cargo` on PATH);
configured repositories also provide `./session-lifecycle.sh`.
No configuration means no guessed artifact or cache paths.

## During work

`./session-lifecycle.sh run -- <command>` holds the workspace lock and invalidates an old completion record before starting.
Custom Cargo target/build directories are unsupported; keep their caches rather than guessing.
Cleanup takes an exclusive flock on each profile's `.cargo-lock`, which the Cargo versions `lifecycle.py` names hold through a build, so a build waits for cleanup and cleanup refuses during a build; revisit that when the configured projects change Cargo version, output layout or locking.

A project's loader runs under `lifecycle.py load`, which hands it the catalog lock so a retention sweep cannot retire the publication it is copying.
Write a loader to build before it enters `load` and only select and copy under it:
every child inherits the lock, and a daemon a build starts, such as sccache's server, keeps it, refusing every `handoff`, `finish`, `catalog`, `load` and hourly sweep in the repository until it exits.

## Hand over

Commit, push and open the required draft PR before building.
Run `./session-lifecycle.sh handoff` after tests finish.
It runs the project's declared build, publishes the complete artifact set with its commit under the repository's common Git directory, verifies checksums, then removes compilation intermediates, keeping the source checkout and top-level loadable binaries.
It refuses dirty source; a failed build or publication keeps the previous handoff and prunes no caches.

For a pause during active iteration use `handoff --keep-cache`, or the project's ordinary build command if source is still uncommitted.
Do not call a pause completed.
For a source-only task that requires no new build, use `finish --source-only` after its verification.
For an already published handoff, `finish` verifies the publication before pruning.
Local completion does not prove a remote push; check the push/PR separately before owner release.

After a merge in a configured repository, run `finish` at the branch head that merged, since any `run --` after the handoff cleared its completion record.
If it refuses for want of a handoff, run `handoff` when the change reaches the deliverable, and `finish --source-only` when it does not.
Work continued in the same worktree afterwards ends the same way, on its own head.

Report the preserved build, how to load it, and whether source cleanup remains pending.
The helper publishes the build but never installs it into the application that loads it; do not report it as installed.

## Release source through its owner

After a confirmed merge or explicit abandonment, check that no new work or owned process remains.
For a Codex-managed worktree, use the app's archive-worktree tool with its actual attachment identity.
If it cannot archive a primary, pinned or shared checkout, report owner release pending.
Do not delete it with Git or modify Codex's private state.
Archive the chat only when that is wanted; retaining chat history does not require retaining compilation caches.

A Claude session's own worktree needs no command from it, except one it created with `EnterWorktree`:
once its HEAD is the merged PR's head commit (`gh pr view --json headRefOid`), its tree is clean and anything worth keeping is elsewhere,
call `ExitWorktree` with `action: "remove"` and `discard_changes: true`, which a squash merge needs since it leaves the branch's commits off the primary branch; the HEAD check is what makes that safe.
Otherwise three things release worktrees: the hourly sweep runs this skill's `scripts/reclaim-worktrees.sh` for each registered repository; a repository's SessionStart hook runs it, as hand-runs do, through a thin `.claude/reclaim-worktrees.sh` wrapper;
and the desktop app removes the worktree of a session it started when that session is archived.
The reclaimer passes over the worktree a live session is in, so running it by hand releases nothing of yours.
Report which of these will release your worktree, and where none applies that it stays until the owner removes it, rather than promise a removal.
Unknown/manual locks remain protected and need the owner's decision.
On other hosts, unsupported ownership is a reported limitation, not permission to force removal.
Do not delete another session's worktree because your work has finished.

## Fallback and retention

`sweep` is a preview; `sweep --apply` reclaims completed caches and runs the shipped reclaimer.
The installed macOS job runs this hourly without an AI session, only for explicitly registered projects.
A registered project without `.agent-lifecycle.json` on its main checkout gets the reclaimer alone, which removes resolved, clean worktrees and prunes no build cache; it resolves against `main` or `origin/main`, so a repository whose primary branch has another name has nothing reclaimed.
The sweep leaves source release for Codex pending.

Resolved handoffs, and older handoffs of the same branch, are evicted oldest first while a repository's handoffs exceed the 5 GiB artifact budget, or once they are 14 days old.
The newest unresolved branch build, the currently selected preserved build, and publications containing a `PIN` file survive both limits, and a GitHub lookup failure retains artifacts.
If protected artifacts exceed the budget, report that rather than evicting them.
The budget covers preserved deliverables; active source/build caches can still exceed it and are not forcibly deleted.

Install or update with agent-config's `scripts/install.sh --repo /path/to/repository`, repeating `--repo` for each project; a rerun keeps those registered.
It links this skill into the user catalogs and runs `scripts/install.py`, which installs the job and keeps unrelated hooks and settings.
