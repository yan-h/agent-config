# Rules for every agent in the audit

Every agent the audit starts is given this file and its own brief, by path.

## What is open

Every recorded decision is open: a candidate may supersede any record, any intent entry the owner chose, and any contract the project calls hard.
The audit proposes; the owner decides.
For each record a candidate supersedes, it says which of the record's stated reasons no longer holds, or how the target still meets the need the record served:
a record weighs what its reasons and its need still weigh, as the global preferences say.

## How a candidate is judged

- **Upfront effort never decides.** State it as a fact.
  What decides is what lasts: what the design costs to own, what it puts at risk, and what it removes.
- **An attack on the problem ends the candidate in every shape.**
  The cost it cites did not happen as claimed, or has stopped; or a recorded reason still holds and no form that reaches the outcome could meet its need.
- **An attack on the shape holds against this design but not against the outcome:**
  a hard case it gets wrong, a capability it loses, a piece that does not work alone, a recorded need this form leaves unmet.
  It is answered by reshaping first: a wider rework, a combination with another candidate or variant, a different mechanism for the same outcome.
  The reshaped candidate is a new candidate, untested until something attacks it.
  A candidate for which no answering shape is found is set aside with the attack recorded, not counted as defeated on the problem.
- **A smaller form is the candidate only when it leaves nothing lasting in place.**
  "This is enough for one change" is not a reason to shrink one.

An agent left to itself judges by whether a piece is worth its cost, and stops at the first form that survives.
In the first run red teams reduced one candidate to its smallest surviving variant and defeated three other variants one at a time;
the objections answered each other once the variants were combined, and the full form came back only when the owner said to ignore cost and allow reshaping.

## What you may do

- Work read-only on the primary branch unless your task gives you a worktree of your own for scratch code. Leave nothing of it committed. Your report file is your one write outside it.
- No commits, pushes, pull requests or tracker writes. Never change the checked-out branch of a checkout you share.
- No subagents.
- Nothing identifying goes in a web query: no project or owner name, no repository address, no file contents.
- Parallel agents' timings distort each other. Report your own as rough, with the load at the time,
  and hand back as an exact command any timing a verdict rests on, for the coordinating session to take serially.
- Write your report to the path your task names, and return it as your answer too.
  List in it what you read whole, and what you did not check.
