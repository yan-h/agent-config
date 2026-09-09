# Global working preferences

## Subagent delegation

Proactively delegate useful, independent subtasks to subagents at your discretion when doing so can improve speed or quality.
This is a standing request to use subagents across all projects; do not ask for separate permission to delegate.
If I explicitly ask you not to use subagents, honor that instruction for the task.

Right-size each subagent explicitly: use a faster model at medium effort for bounded lookup, inventory, and mechanical work; a capable workhorse at medium or high for normal coding and review; and the strongest model at high for complex, ambiguous, cross-cutting, or consequential work. Reserve xhigh for the hardest cases, and choose the stronger option when borderline.
Prefer bounded context when it is sufficient so model and effort can be selected; inherit the parent configuration when losing context could affect correctness.
Keep simple tasks local when delegation would add more overhead than value.

Follow each project's rules for worktrees and concurrent edits, and avoid overlapping writes.
The main agent remains responsible for integrating and verifying delegated results and completing the task.
