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

Run the `design-review` skill on your own change without asking when the change warrants it: a substantial, cross-cutting or risky diff, or a design you are unsure of.
Skip it for small, mechanical or documentation-only changes.

## Subagent delegation

Delegate useful, independent subtasks to subagents at your discretion when that improves speed or quality.
This is a standing request across all projects: do not ask permission, and do not delegate in a task where I ask you not to.
Delegate through your host's own subagents; do not launch another agent product or CLI unless I ask.

Right-size each subagent explicitly: use a faster model at medium effort for bounded lookup, inventory, and mechanical work; a capable workhorse at medium or high for normal coding and review; and the strongest model at high for complex, ambiguous, cross-cutting, or consequential work. Reserve xhigh for the hardest cases, and choose the stronger option when borderline.
Prefer bounded context when it is sufficient so model and effort can be selected; inherit the parent configuration when losing context could affect correctness.
Keep simple tasks local when delegation would add more overhead than value.

Follow each project's rules for worktrees and concurrent edits, and avoid overlapping writes.
The main agent remains responsible for integrating and verifying delegated results and completing the task.

## Pull requests

Combine related changes into one pull request when they serve one purpose, touch the same code, or would be reviewed together; do not split one piece of work into a pull request per step.
When an unmerged pull request for the same work is already open, add to it instead of opening another.
Keep unrelated changes in separate pull requests so each can be reviewed, reverted, and merged on its own.
Keep commits logically separated within a combined pull request.
Squash-merge by default; use a merge commit only when the commits are separable decisions, each worth finding on its own, rather than revisions of one another.

## Session lifecycle

The owning session finishes its workspace as part of finishing the task.
Use the shared `session-lifecycle` skill when handing over completed work or releasing a resolved worktree.
Keep project-specific build commands and required deliverables in that project's lifecycle configuration.
Preserve loadable deliverables before reclaiming compilation output; keep unfinished source and paused work.
Subagents sharing a checkout leave cleanup to their owner.
Release worktrees through their host's ownership mechanism, and never create a permanent manual worktree lock.
Report any blocked owner release rather than silently leaving cleanup unfinished.
