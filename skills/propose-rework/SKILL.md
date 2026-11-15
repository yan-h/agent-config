---
name: propose-rework
description: Design one large rework — a restructuring with high upfront cost for lasting gains in maintainability, performance or correctness, possibly changing behaviour — as a costed, attacked proposal with an incremental migration, for the owner to decide. Use when asked to plan or evaluate a rework, rewrite or re-architecture of a named part of a project; not for a change that fits in one PR.
---

# Propose one rework

The target is what the invocation names (`$ARGUMENTS` in Claude, the text after `$propose-rework` in Codex):
a rework candidate from an audit, an issue, or a problem or goal in the owner's words.
If it names no outcome — what should become cheaper, faster, or impossible to get wrong — ask before designing.
If it names a design, the outcome that design serves is the target and the named design is one option:
a target written as "replace today's seven collision answers… with a column model" never considered the free placement with snapping that the owner proposed after its verdict and chose.

This skill borrows from two skills installed beside it; if either is not installed, say so and stop.
From `audit-drift`: the describer brief and "Record the answers" section.
From `audit-premises`: [its rules](../audit-premises/references/rules.md), for what a guarantee is, how each rating judges a design and how a broken design is reshaped,
and its tester brief.

Read the project's local contract before starting, with its roadmap, recorded decisions, the owner's standing preferences, and the intent records of every area the rework touches.
A recorded decision the rework collides with is weighed, and superseded or put to the owner, as the global preferences say.

Upfront cost is treated as the global preferences say: the report states it, and the verdict rests on what lasts.
That holds inside the design too: a piece of the target is not cut, deferred or shrunk for scope, and a piece that fails a spike or an attack is reshaped before it is cut down — widened, combined with another candidate or given a different mechanism, as the rules say.
In one run the owner had to ask whether the revised design had reshaped rather than cut; it had made three cuts, one "for scope".

If this run is itself a subagent that cannot start agents, do the describer's work yourself,
and stop after "Behaviour that changes", returning the design marked unattacked for the session that started you to attack.

## Ground the problem

State what the current design costs today, with evidence:
the commits and PRs that paid for it, the bugs it produced, the roadmap items it blocks, and what a user notices.
A runtime cost no user notices is reported as that; it is a weak reason to rework.
A cost a user does notice is measured before it is called nothing:
one verdict called the current design's cost "nothing concrete" without measuring a judder, which a later port of the target's gain cut from 4% of frames missed to 1%.
A gain claimed for the target — an upstream fix, a speed-up — is checked the same way before a verdict rests on it.
If the cost cannot be shown, say so; the proposal may end there.

List the open issues, pull requests and branches on the part; the report says what the rework does to each.

A candidate the `audit-premises` skill tested arrives with this done: its section of that audit's report is the grounding, once you have checked it still holds on the primary branch.

## Map what exists, in parallel

Run one read-only agent, the describer, while you read the design yourself:
the describer brief of the `audit-drift` skill (`references/describer.md` in that skill), applied to the part being reworked.
For an internal part, the behaviour to describe is what its callers observe at its interface.
An earlier audit's describer report on the part serves instead while the code it describes is unchanged.
The places it finds where the code and its own comments disagree are worth fixing whatever the verdict.

While it runs, ask the owner for consent to write the proposal, and the spike's outputs, to the tracker, in the words the host's global file says such writes need;
without it, they go in a Markdown design document on a branch, as a draft pull request where the project has them.

Guarantees are not rated up front. A rating stands only where the intent records hold one or a candidate from `audit-premises` arrived with a ratings file;
every other guarantee is open as the rules say, and one the target gives up is judged as "Behaviour that changes" says.
Tolerances for the run are taken only where the owner states them.

## Design

Ask how you would build this part if it did not exist, given everything else in the codebase as it is.
Aim for the most far-reaching design that reaches the outcome, not the safest: widen it beyond the named part, or take in another candidate, wherever that removes more.
Label variants by confidence and look for prior art as the global preferences say, and look too at what in this codebase already does part of it:
the owner asked for prior art in two runs and for that in a third.
Then set out:

- **The target design:** what it removes — concepts, duplicated mechanisms, invariants callers must remember, classes of bug, measured cost — and what it adds.
  Each concept it adds cites the present use that needs it.
- **The smaller change:** the best targeted change within the current structure, removing a mechanism and accepting what it gave included,
  with how much of the gain it gets and what it costs to own.
  Twice the run's cheaper alternative added a mechanism, a tuned heuristic or a push, and the owner took doing nothing or a removal instead.
- **Doing nothing:** what the current design will keep costing, given the roadmap.

The smaller change is the verdict only when it leaves nothing lasting in place that the target would remove, or the target's risks and lasting costs outweigh what more it removes;
never because it is cheaper to build or easier to defend.

If a design is open between two real options, compare them rather than picking silently.

## Spike the riskiest assumption

If an assumption could sink the target design — a performance target, a library's fit, migrating real data — test it now, before planning around it,
with a throwaway prototype in a worktree of its own, created as the project contract says.
Never use the session's own checkout, its branch or the shared stash: one spike switched the branch of a checkout another agent was reading.
Before trusting a result, check that the prototype implements the design and changes what it claims:
one spike's change built identical to the baseline, and the report's headline number came from it.
Keep the diff and outputs where the proposal lives, then remove the worktree. Do not merge it.
If it fails, reshape the design to answer what it showed and test again; end with the smaller change or with leaving it only when no shape reaches the outcome.
For a candidate the `audit-premises` skill tested, spike only what the audit's report marks untested, and build on a prototype the audit kept as a draft pull request instead of starting another.

## Behaviour that changes

Compare the describer's account with the target. Every difference is one of:

- **a guarantee given up,** judged by its rating: a must-keep is a regression the design must remove;
  a would-trade one, or an unrated one the global preferences bring to the owner, is a yes/no question, with what a user loses on which real cases and what happens on either answer;
  any other unrated one is listed;
  a don't-care is listed;
- **a fix,** citing the record, issue or intent entry that makes today's behaviour a defect: listed as a fact; without such a citation it is a question with a recommended yes;
- **a regression** the design must remove.

## Attack the design

Start fresh red teams with `audit-premises`' tester brief and rules, telling each that it is the red team, that its candidate is this design and the write-up is the design document, and giving it
the `audit-premises` ratings file if the candidate came with one, the ratings the intent records hold, any tolerances the owner stated, the design, the spike's results, the behaviour differences and a path for its report, not your reasoning:
one on the whole design, and one on each piece the verdict rests on that could fail alone. State the number of agents before each round.
Check each attack's central claim against the code yourself before acting on it.

An attack lands when it would change the verdict, a must-keep, a question for the owner or the point of no return,
or when it shows a failure that a check the design relies on passes over or never runs; anything else is corrected, or goes unprotected as the global preferences say of what a project guarantees, and is not attacked again.
Before any further round, report the design open, with what the next attack would aim at, when a second reshape answers an attack on the same piece,
when it now removes less than it did entering the first round, or when the third round's attack lands, listing every attack:
one design ran a third round on a piece already reshaped twice, and reshaped it a third time.
Otherwise attack the answer where it revised the design, with one red team at what it revised and what that touches: up to three rounds for the design, reshapes included.
An answer that only adds or rewords a question for the owner earns no round.

Seven of the fourteen runs before this step existed had an attack or independent review added, and every one found something the report would otherwise have carried,
among them a headline figure from a spike that changed nothing, a watchdog the shipped change needed and about eight defeated claims in one design.
Under the earlier stopping rule every second round in four designs landed, one with a failure that passed all 224 of the plugin's tests;
a rework that cut its second round met seven defects in the build, two of which a second attack would plausibly have caught, though none reworked a merged step.
The stopping rule above has not yet run.

## Map the migration surface

If the verdict leans toward the rework, run one read-only agent, a lookup a light model can do:
every caller, entry point, persisted format, public interface, configuration key and test that touches the part.
Run before the attack, it mapped migrations that never happened: in two runs whose verdicts went elsewhere it took seven and twelve minutes and fed one sentence between them.
A finding the design did not account for is a landed attack, answered as an attack is; where no round is left, the design is reported open with the finding.

For persisted data, file formats and public interfaces, say how existing data and callers migrate or stay compatible.

## Migration

Plan the fewest steps that each land on their own with the project's gate passing.
The target's behaviour and speed hold at the migration's end, and between its steps only where the owner said they must.
Plan the safeguards lean, as the global preferences say.
Pin with tests only the must-keeps that existing tests do not cover; pin nothing the rework deletes.

Where the outcome is judged by ear or eye, or the target adds a capability, the first step is the smallest build the owner can try, since in one run his verdict on it redirected the design.
The plan stops there for that verdict only where the owner asked for the stop, as the global preferences say of a check asked of him.
Each step names the decision records and intent entries it edits.
A flag or compatibility layer introduced for the migration gets its own removal step.
Name the point of no return, if there is one, and what must be true before passing it.

If the rework cannot be incremental, say why, and what a single cut-over risks.

## Report

Write the report where the proposal lives as soon as a draft exists, and keep it current, opening with what remains to do:
a run stopped part-way, as one was by quota, is continued by a fresh session given its link.

Lead with a one-line verdict — do the rework, do the smaller change, or leave it — then:

- **Questions for the owner:** each yes/no, with a recommendation and what happens on either answer.
- **Problem:** the cost today, with evidence.
- **Guarantees:** each with its rating, and what each must-keep ruled out.
- **Designs:** target, smaller change and doing nothing, each with what it removes and what it costs.
- **Spike:** what it tested and what it showed, or why none was needed.
- **Attacks:** what each round hit and what changed, and whether the design was left open.
- **Behaviour changes:** the fixes, as facts, and the don't-cares given up.
- **Migration:** the steps, each sized roughly as a PR, the safeguards left out, and the point of no return.
- **Cost and risk:** total upfront cost, with tests, oracles and test-only hooks counted apart from production lines; what is left if the work stops after any step;
  and the signs during the migration that should stop it.
  An oracle that restates the design has a lasting cost too, stated with the target's: every change to what it restates must edit it.
  One rework estimated at 300 lines removed landed 940 added, its 860 lines of event-sequence enumeration and file scanner costed at about 60.
- **Open work and side findings:** what happens to each open issue and pull request on the part, and the describer's comment fixes.

Put the questions to the owner as the global preferences say, each in what a user hears or sees with one concrete case.
A step that rests on an unanswered question does not start.
When the owner answers, record the answers as `audit-drift`'s "Record the answers" section describes; this report has no index to tick.

Change no code beyond the spike.
If the owner takes the proposal, offer to carry out the whole migration from a fresh session by the project's procedure for multi-PR work,
asking up front for its merges and tracker writes in the words the host's global file says they need:
the owner once stopped a builder started from a run's long context and asked for a fresh session to orchestrate.
