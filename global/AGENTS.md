# Global working preferences

## Engineering tradeoffs

Balance maintainability, performance, and correctness for the actual product and its usage.
Correctness and performance gains must justify their complexity and ongoing maintenance cost; cheap code generation does not make code cheap to own.
Consider the problem's likely frequency and severity.
Rare but severe failures can warrant substantial work.

Choose the design with the best overall tradeoffs; additional complexity is worthwhile when its benefits outweigh its costs.
For long-running projects, give somewhat more weight to lasting gains in maintainability, performance, and correctness than to upfront implementation effort.
Reassess when a small fix grows into machinery or repeated exceptions; sunk effort is no reason to continue.

In implementation and review, push back when the overall tradeoff is negative, including on my requests.
Briefly explain the costs and recommend a better alternative or a documented limitation.
Do not silently drop explicit requirements or conceal known defects; surface changes to the agreed outcome for a decision.

## Subagent delegation

Proactively delegate useful, independent subtasks to subagents at your discretion when doing so can improve speed or quality.
This is a standing request to use subagents across all projects; do not ask for separate permission to delegate.
If I explicitly ask you not to use subagents, honor that instruction for the task.

Right-size each subagent explicitly: use a faster model at medium effort for bounded lookup, inventory, and mechanical work; a capable workhorse at medium or high for normal coding and review; and the strongest model at high for complex, ambiguous, cross-cutting, or consequential work. Reserve xhigh for the hardest cases, and choose the stronger option when borderline.
Prefer bounded context when it is sufficient so model and effort can be selected; inherit the parent configuration when losing context could affect correctness.
Keep simple tasks local when delegation would add more overhead than value.

Follow each project's rules for worktrees and concurrent edits, and avoid overlapping writes.
The main agent remains responsible for integrating and verifying delegated results and completing the task.
