---
name: audit-performance
description: Audit a project, or one named area or workload, for performance costs a user would notice, proving each with a measurement and each fix with numbers before and after. Started only by the repository owner invoking it explicitly.
disable-model-invocation: true
---

# Audit for performance a user would notice

**The owner starts this.** A session that notices something slow says an audit looks due and stops there;
it does not run the procedure below by hand instead.
`disable-model-invocation` above enforces that in hosts that honour it;
Codex does not, so in Codex this paragraph is the rule itself.

Read the project's local contract before starting.
Build profiles, benchmark and profiling commands, worktrees, validation gates, PR conventions, and where intent records live all come from there;
where it says nothing about intent records, use `docs/intent/<area>.md`.
Measure the build users run, not a debug build, unless the contract says otherwise.

This audit shares its area map, report layout and answer records with the `audit-drift` skill, installed beside this one.
Read that skill's `SKILL.md` for the sections named below; if it is not installed, say so and stop.

## What counts

A cost a person using the software would notice at the sizes the product actually meets:
latency on an interactive path, throughput of a batch job, startup time, memory, idle CPU.
A speedup no one would notice is not worth the code it costs, however clean the benchmark looks.
The global engineering tradeoffs apply: a fix earns its place only when its gain outweighs what it costs to own.

## Choose the scope

The text after the invocation names an area or a workload (`$ARGUMENTS` in Claude, the text after `$audit-performance` in Codex).

With none, audit every workload the product depends on.
Draw them from the project's benchmarks, its contract and roadmap, and what the product is for,
each with the input sizes it meets today and the largest the roadmap commits to.
Usually three to eight.
Put the list at the top of the report so the owner can correct it next time.

Intent records are kept per area, so place each workload in the areas its hot path crosses:
use the area map from the last area-based audit's tracking issue if there is one, otherwise map the project as `audit-drift`'s "Choose the scope" section describes.
Read those areas' intent records, so a trade the owner has already declined is not asked again,
and the open tracking issues and rework issues from earlier audits, so a candidate already listed is linked rather than listed twice.

## Measure first

Before anyone reads code for slow patterns, build per the contract, run each workload, and profile it.
Record wall time, memory, and where the time goes.
Run each measurement enough times to know its noise, and report the median and spread;
a difference inside the noise is not a finding.

If the project has no repeatable way to run a workload, the first deliverable is a minimal harness that does.
It is what makes every later finding provable, and it stays useful after the audit.

**Only the calling agent takes timings that decide anything, one at a time, and not while a surveyor is building or profiling.**
Parallel agents running builds and benchmarks on the same machine distort each other's numbers.
Surveyors may profile to locate cost; they do not produce the numbers a finding rests on.

## Survey, in parallel

Read [the surveyor brief](references/surveyor.md) completely before delegating.
Give each surveyor that brief, one workload's or area's profile, and the workload sizes,
and tell them never to swap any shared installed build.
Size them by the global subagent guidance; judging what will matter at scale is consequential work.
Surveyors are read-only: they return candidates and suspicions, and do not edit, commit, or open a PR.

## Prove, sort, then fix

A candidate becomes a finding only when a measurement on a realistic workload shows its cost.
Anything unmeasured is listed under **Suspicions** with the measurement that would settle it, and not fixed.

Sort the findings.
Local fixes are made in the run because the baseline and harness that prove them exist only then;
they go up as PRs and are not merged here.

- **Behaviour-preserving and local:** fix it, measure again, and keep the fix only if the gain clears the noise and justifies its complexity.
  The project's tests must still pass; a fix that changes what a user sees belongs in the next group instead.
  Follow the contract for worktrees, commits and PRs.
- **Trades behaviour for speed** — staler data, less precision, new limits, visible laziness:
  a yes/no question for the owner, with the gain measured from a throwaway prototype and what is given up.
  Not fixed in this run.
- **Needs a data-model, interface or cross-area change:** a rework candidate.
  One paragraph each: the measured cost, the change it needs, a rough upfront cost, and what it would gain.
  The owner can take one into the `propose-rework` skill.

## Report

Each finding opens with what a person would notice and its numbers, at a stated size:
"opening a 50k-line file: 3.1 s → 0.4 s" for a fix, the measured cost alone for a question or candidate.
Then the cause, and the PR, question or candidate it became.

Also give the baseline table for every workload, the workloads and hypotheses checked clean, and the harness if one was added.

For a run covering several workloads, lay the report out as `audit-drift`'s "Report so it can be taken piecemeal" section describes,
one section per workload, with the rework candidates ranked together after the index.
Record the owner's answers as that skill's "Record the answers" section describes,
in the intent record of the area the traded behaviour belongs to.
