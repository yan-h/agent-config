---
name: review-and-merge
description: Review one pull request for correctness and design if its diff warrants a review, fix what the review confirms, wait for its checks, then merge it. Started only by the repository owner invoking it explicitly.
disable-model-invocation: true
---

# Review if warranted, then merge

**The owner starts this.** A session that thinks a PR is ready says so and stops there.
`disable-model-invocation` above enforces that in hosts that honour it;
Codex does not, so in Codex this paragraph is the rule itself.

**Invoking this skill is the owner's permission to merge one PR.**
It satisfies a project default that nothing merges unless the owner asks, for that PR only, not for the rest of the session.

The PR is the one the invocation names, or the current branch's PR when it names none.
In Claude that text is `$ARGUMENTS`; in Codex it is the text following `$review-and-merge`.

Read the project's local contract before starting.
Review tools, required checks, build obligations, merge method and cleanup all come from there.

## Decide whether to review

Read the PR's full diff against the primary branch, fetched fresh, not a local branch ref that may be stale.

Review changes with real logic, shared or cached state, concurrency, persistence, security, or anything the project contract marks as risky.
Skip it for documentation, configuration, mechanical renames, test-only edits, and obviously correct one-line changes.
When unsure, review.
State the decision and its reason in one line.

## Review

A review is independent:
a different agent from whoever wrote the change, reading the whole diff for correctness first.
Use the review tool the project contract names;
if it names none, use whatever review command the host provides, or else a fresh subagent briefed with the diff and the project contract.

Alongside it, run the design pass of the `design-review` skill:
a fresh subagent on the strongest model, briefed with the PR, the project contract and that skill's Design section, returning its verdict and alternatives.

Fix every finding the review confirms, and fix or answer the uncertain ones in the PR description.
Keep fixes inside the PR's scope; anything else found along the way is reported, not fixed here.
A finding that is a design question rather than a defect stops the run and goes to the owner.
Commit and push the fixes, and redo any build or check the project contract owes for them.

The design verdict decides what happens next.
File every alternative it places in a follow-up as an issue, link them from the PR, and continue.
Make every alternative it places in this change, then have the correctness review read the new diff and fix what it confirms.
An adjustment that would change user-visible behaviour or a public interface is a design question, and goes to the owner instead.
A verdict to rethink the approach stops the run: leave the PR open and report the alternatives with the recommendation, for the owner to choose.

## Wait for the checks

Wait in this session, not in a subagent, until every check on the latest pushed head has finished and passed.
A mergeable status reported before the checks have started is not a pass.
A conflict with the primary branch may stop checks from running at all:
bring the primary branch in by the project's method, rerun the gates, push, and wait again.
A failing check is fixed, not merged past; one failing for a reason outside the PR leaves the PR open and is reported.

## Merge

Mark the PR ready if it is a draft, then merge it by the project's method.
Confirm the merge landed on the remote primary branch before reporting, and clean up the branch as the project contract says.

## Report

The merge commit, whether the PR was reviewed and why, what the review changed, the design verdict, the adjustments made for it, and any follow-up issues filed.
If the PR is left open, say so and name what blocks it.
