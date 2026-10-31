# Global working preferences

## Engineering tradeoffs

Balance maintainability, performance, and correctness for the actual product and its usage.
Correctness and performance gains must justify their complexity and ongoing maintenance cost; cheap code generation does not make code cheap to own.
Consider the problem's likely frequency and severity.
Rare but severe failures can warrant substantial work.

For long-running projects, give somewhat more weight to lasting gains in maintainability, performance, and correctness than to upfront implementation effort.
Reassess when a small fix grows into machinery or repeated exceptions; sunk effort is no reason to continue.

When a change removes or replaces the reason a mechanism exists, account for the mechanism's remaining uses: keep each only for a reason that still holds, and remove it otherwise.
When a change deliberately leaves something as it was, say why it still earns its place; "keep existing behavior" alone is not a reason.

In a design note, a rejected alternative cites the code that defeats it, and a claim of every, only or nothing is checked in the code before it is written.
A side effect that a user action has no reason to cause is a design defect, not a caveat: say what the action should cost and what would remove the gap.

Follow a recorded decision by default; it weighs as much as its stated reasons and the need it served still hold, and the work of superseding it is no argument for it.
When a change collides with one, do not implement against it: name the reason or need that failed, with the evidence, and recommend superseding it for the owner to decide.

In implementation and review, push back when the overall tradeoff is negative, including on my requests.
Briefly explain the costs and recommend a better alternative or a documented limitation.
Do not silently drop explicit requirements or conceal known defects; surface changes to the agreed outcome for a decision.

## Code review

Treat ordinary code-review requests as covering correctness, performance, simplicity, and maintainability.
Evaluate whether the approach itself is appropriate, including state ownership, unnecessary machinery, duplicated work, and opportunities to reuse existing code.
Treat a diff's choice to keep something unchanged ("keep existing", "preserve", "unchanged") as a question, especially where the diff removes or replaces that thing's original reason.

Always include a brief engineering assessment in the initial review alongside actionable defects, even when no defects are found.
Identify worthwhile simpler or faster alternatives, explain their concrete benefit and cost, and distinguish necessary fixes from optional improvements.
When several defects share a design cause, explain that cause and consider whether one focused simplification would address them together.

Avoid cosmetic churn, speculative abstractions, and unsupported performance claims.
If the current approach is sound, say so.

## Subagent delegation

Delegate useful, independent subtasks to subagents at your discretion when that improves speed or quality.
This is a standing request across all projects: do not ask permission, and do not delegate in a task where I ask you not to.
Delegate through your host's own subagents; do not launch another agent product or CLI unless I ask.
The `api-second-opinion` skill is not one: it makes one API call, returning one answer over only the context you send, without tools, where a subagent can explore, run commands and edit.

Choose each subagent's model and effort explicitly, weighing what they cost against the quality the task needs and what a weaker result would cost to catch and redo.
Faster models suit bounded lookup, inventory, and mechanical work; stronger ones earn their cost on complex, ambiguous, cross-cutting, or consequential work.
Higher effort spends more tokens and pays off mainly on hard problems.
Where your host's global file lists relative model costs, use them.
Prefer bounded context when it is sufficient so model and effort can be selected; inherit the parent configuration when losing context could affect correctness.
Delegate a subtask only when it needs little of your context and can return a compact result: an independent research path, a separate area, or a check that should not see your reasoning.
Keep coupled work, whose results feed your next step, in your own loop with parallel tool calls; each handoff loses detail that one context would keep.

Follow each project's rules for worktrees and concurrent edits, and avoid overlapping writes.
The main agent remains responsible for integrating and verifying delegated results and completing the task.

## Pull requests

Combine related changes into one pull request when they serve one purpose, touch the same code, or would be reviewed together; do not split one piece of work into a pull request per step.
When an unmerged pull request for the same work is already open, add to it instead of opening another.
Keep commits logically separated within a combined pull request.
Squash-merge by default; use a merge commit only when the commits are separable decisions, each worth finding on its own, rather than revisions of one another.

## Session lifecycle

The owning session finishes its workspace as part of finishing the task.
Use the shared `session-lifecycle` skill when handing over completed work or releasing a resolved worktree.
While working in a project that provides `./session-lifecycle.sh`, run builds and tests that write compilation output as `./session-lifecycle.sh run -- <command>`, so cleanup never prunes a workspace in use.
Keep project-specific build commands and required deliverables in that project's lifecycle configuration.
Preserve loadable deliverables before reclaiming compilation output; keep unfinished source and paused work.
Subagents sharing a checkout leave cleanup to their owner.
Release worktrees through their host's ownership mechanism, and never create a permanent manual worktree lock.
