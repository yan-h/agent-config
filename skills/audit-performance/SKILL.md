---
name: audit-performance
description: Audit a project, or one named area or workload, for performance costs a user would notice, each proved by measurement. Started only by the repository owner invoking it explicitly.
disable-model-invocation: true
---

# Audit for performance a user would notice

**The owner starts this.** A session that notices something slow says an audit looks due and stops there, rather than running the procedure below by hand.
Codex ignores `disable-model-invocation`, so there this paragraph is the rule itself.

This audit follows the sections of [the `audit-shared` skill](../audit-shared/SKILL.md) named below, installed beside this one; if it is not installed, say so and stop.
Start by reading the project's local contract as its "Read the contract" section describes; build profiles, benchmark and profiling commands and validation gates come from it too.
Measure the build users run, not a debug build, unless the contract says otherwise.

## What counts

A cost a person using the software would notice at the sizes the product actually meets:
latency on an interactive path, throughput of a batch job, startup time, memory, idle CPU.
A speedup no one would notice is not worth the code it costs, however clean the benchmark looks.

## Choose the scope

The text after the invocation names an area or a workload (`$ARGUMENTS` in Claude, the text after `$audit-performance` in Codex).

With none, audit every workload the product depends on.
Draw them from the project's benchmarks, its contract and roadmap, and what the product is for,
each with the input sizes it meets today and the largest the roadmap commits to.
Usually three to eight.
Put the list at the top of the report so the owner can correct it next time.

Intent records are kept per area, so place each workload in the areas its hot path crosses:
take the area map as the `audit-shared` skill's "Map the areas" section describes.
Read those areas' intent records as its "Read the intent records" section describes, so a trade the owner has already declined is not asked again,
and the open tracking issues and rework issues from earlier audits, so a candidate already listed is linked rather than listed twice.

## Measure first

Before anyone reads code for slow patterns, build per the contract, run each workload, and profile it.

**Measure the whole task the user waits for before any stage of it**:
the export with its real encoder, the request through its real database, the launch to the first usable frame.
Then break it into stages and find which ones overlap.
A stage off the critical path is not a finding however much it speeds up: the user still waits on the slower one.

Record wall time, memory, and where the time goes.
Run each measurement enough times to know its noise, and report the median and spread;
a difference inside the noise is not a finding, and where the noise is larger than the effect, say so rather than ranking by it.
Compare A against B in alternating back-to-back pairs rather than in separate rounds, since a shared machine's load swings within the hour,
and record the machine's load beside every number.

**Check that every variant changed only what it claims.**
Read its whole output for warnings and fallbacks, not just the timing line, and confirm each setting still exists:
options named in earlier audits get renamed or deleted, and a configuration that fails to parse may silently run at defaults.

If the project has no repeatable way to run a workload, the first deliverable is a minimal harness that does, since every later finding is proved with it.

**Only the calling agent takes timings that decide anything, one at a time,
and not while a surveyor or any process of the caller's own is building, profiling or encoding.**
Parallel agents running builds and benchmarks on the same machine distort each other's numbers.
Stop the caller's own background runs by PID, children included, and check they are gone before the next timing.

## Survey, in parallel

Read [the surveyor brief](references/surveyor.md) completely before delegating.
Give each surveyor that brief, one workload's or area's profile, and the workload sizes.
Judging what will matter at scale is consequential work.

## Prove, sort, then fix

A candidate becomes a finding only when a measurement on a realistic workload shows its cost.
Anything unmeasured is listed under **Suspicions** with the measurement that would settle it, and not fixed.

Sort the findings.
Local fixes are made in the run without being asked, because the baseline and harness that prove them exist only then;
they go up as PRs, reviewed as the `audit-shared` skill's "Review and merge the fixes" section describes,
and are not merged here unless the owner's own message asked for the fixes to be merged.

- **Behaviour-preserving and local:** fix it, measure again, and keep the fix only if the gain clears the noise and justifies its complexity.
  A fix that changes what a user sees belongs in the next group instead.
- **Trades behaviour for speed** — staler data, less precision, new limits, visible laziness:
  a yes/no question for the owner, with the gain measured from a throwaway prototype and what is given up.
  Not fixed in this run.
- **Needs a data-model, interface or cross-area change:** a rework candidate.
  One paragraph each: the measured cost, the change it needs, a rough upfront cost, and what it would gain.

## Report

Each finding opens with what a person would notice and its numbers, at a stated size:
"opening a 50k-line file: 3.1 s → 0.4 s" for a fix, the measured cost alone for a question or candidate.
Then the cause, and the PR, question or candidate it became.

Also give the baseline table for every workload, the workloads and hypotheses checked clean, and the harness if one was added.

For a run covering several workloads, lay the report out as `audit-shared`'s "Report so it can be taken piecemeal" section describes,
one section per workload, with the rework candidates ranked together after the index.
Record the owner's answers as that skill's "Record the answers" section describes,
in the intent record of the area the traded behaviour belongs to.
