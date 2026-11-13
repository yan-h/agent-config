---
name: audit-premises
description: Audit a project for overhauls that become possible if recorded decisions may be superseded — designs a different premise would make simpler, faster or impossible to get wrong. Readers propose, red teams and experiments test, and a candidate an attack breaks is reshaped before it is cut down. Produces rework candidates for the owner, not fixes. Started only by the repository owner invoking it explicitly.
disable-model-invocation: true
---

# Audit the premises

**The owner starts this.** A session that suspects a wrong premise says an audit looks due and stops there;
it does not run the procedure below by hand instead.
`disable-model-invocation` above enforces that in hosts that honour it;
Codex does not, so in Codex this paragraph is the rule itself.

Read the project's local contract before starting, with its roadmap, recorded decisions and intent records.
Worktrees, branch and PR conventions all come from there.
This audit uses the `audit-drift` skill's "Choose the scope" and "Record the answers" sections, installed beside this one;
if it is not installed, say so and stop.

## What this audit is

The other audits take the recorded design as given: `audit-maintainability` finds costly structure inside it, `audit-drift` finds reasons that moved.
This one asks whether a group of decisions shares a premise that a different design would not need.
Sessions follow recorded decisions by default and supersede one only when a change collides with it, so nothing else asks that question.

**Every recorded decision is open here.**
A candidate may supersede any record, any intent entry the owner chose, and any contract the project calls hard.
It names each one it supersedes; the audit proposes and the owner decides.

Two rules judge every candidate, and every agent is told them, since an agent left to itself judges by whether a piece is worth its cost:

- The verdict rests on what lasts, as the global preferences say: upfront cost is stated as a fact and is never a reason to shrink a candidate.
- **A candidate may grow or change shape.** When an attack lands, the first question is what change of shape or scope would answer it:
  a wider rework, a combination with another candidate, a different mechanism for the same outcome.
  A candidate is cut down only when the smaller form gets the lasting gain, and dropped only when no shape answers the attack.

In the first run red teams reduced one candidate to its smallest surviving variant and defeated three other variants one at a time.
The objections answered each other once the variants were combined, and the full form came back only when the owner said to ignore cost and allow reshaping.

The output is rework candidates for the `propose-rework` skill. This audit changes no code beyond scratch probes.

## Cost and consent

The first run used 27 agents over two waves, about 7 million subagent tokens besides the coordinating session; each agent ran for six to thirty-five minutes.
Invoking the skill is the owner accepting that. Run both waves or neither:
the first wave alone produced a confident, convergent ranking in which four of the top five candidates were later defeated or cut to a third or less.

Before the first wave, ask the owner once for every write the run will make to the tracker:
the tracking issue, the agents' reports as its comments, an issue for each defect reproduced on the way, and later rewrites of the tracking issue's body.
Without that the run keeps its report in local files.

Size each agent by the global subagent guidance.
The red teams and the designers among the stances are the consequential judgement; fact-finding is lighter.

## Choose the scope

The text after the invocation names one area (`$ARGUMENTS` in Claude, the text after `$audit-premises` in Codex); with none, audit every area.
Map the project as the `audit-drift` skill's "Choose the scope" section describes, and add what an area map leaves out:
the test suite, the records and docs themselves, and vendored code are each an area here.

## First wave: readers who propose

Read [the reader brief](references/reader.md) and [the stances](references/stances.md) completely before delegating. Run all of them in parallel, read-only:

- **One reader per area**, with the reader brief, the area's paths and docs, and the owner's standing preferences from the project contract and the global preferences.
  Give it questions to hold, not your own guesses at its answer: an agent handed a hypothesis returns it confirmed.
- **One agent per stance.** Area readers are anchored on what exists.
  The stances are not: one designs from the goals before opening the code, one designs to a third of the size,
  one asks what would change the cost class, one looks at prior art, one reads how the project is kept correct, and one mines the decision history.

Readers report candidates they are unsure of, labelled strong, plausible or speculative, with no cap on their number.
A brief that asked only for candidates that survived the reader's own attack, three at most, had to be amended mid-run.

When the reports are in, list the files and subsystems no reader read whole, and send a reader to each that matters.
In the first run every reader had skipped one subsystem, whose fields were nearly a third of the central data record.

## Between the waves: do not rank yet

Agreement among readers is weak evidence: they read the same records.
Seven readers reached one candidate that a red team then cut to a third, and five reached one that was defeated.

Group the candidates by the premise each questions, across areas.
Check each report's central claims yourself by reading the cited lines.
A search that matches a word is not a check: two statements made to the owner from such searches were false.
Tell the owner what came back, as candidates under test, not as a ranking.

## Second wave: test, and reshape what breaks

Read [the tester brief](references/tester.md) completely before delegating.
Every candidate that could lead the report, and every one that needs the owner's decision, gets:

- **A red team:** one agent, one candidate, with the single job of defeating it against the code.
  It reports the shape that would answer each attack that lands, as the brief requires.
- **An experiment, wherever the product can already answer:**
  - a profile before trusting an inferred split. An inferred 77/11/12 measured 65/17/16, and "about 5 times" measured 1.6;
  - an emulation with features the product already has. One candidate could be played, timed and compared with two existing settings;
  - a scratch prototype for a candidate that proposes a new check or mechanism, run against historical defects reintroduced on purpose.
    A proposed check caught neither of two until a fourth check was added;
  - pictures of every real case where the question is taste.
- **Fact-finding** for each "not checked" item a candidate rests on.

An agent that writes scratch code works in its own worktree; long builds stay in the coordinating session.
Reproduce every defect an agent reports before telling the owner, and file each that reproduces as its own issue.
A prototype worth keeping goes on a branch as a draft pull request:
an ignored directory in a worktree that can be reclaimed is where the first run nearly left its only copy.

## Recombine, then attack the combination

Sort every defeat and reduction by its reason:

- **The owner's own recorded reason, or behaviour the owner rejected:** it stays defeated. Say where the reason is recorded.
- **A lost capability:** a question for the owner, or a shape that keeps the capability.
- **"This piece alone does not remove X":** conditional. Combine it with the piece that does.
- **"A smaller version is enough", or cost:** not a reason under the two rules. Restore the full form and say what the smaller one leaves in place.

Build the combined forms whose pieces answer each other's objections.
A combined form is your own synthesis: send a fresh red team at each one that would lead the report, and mark any other as untested where it appears.

## Report

One tracking issue (a Markdown file in the repository if the project has no tracker), written as the current state:

- **Verdict first,** in a few lines, then what to do next, in order.
- **Decisions that are the owner's,** each answerable yes or no, with what happens on either answer.
- **Each standing candidate:** the premise, what it costs today with evidence, the target, what it removes, what it loses,
  the records it supersedes, what was tested and how, and what is untested.
- **Defeated or set aside,** one line each with the reason, so it is not proposed again unchanged.
- **Load-bearing and right:** what no candidate touches and why.
- **Measurements,** issues filed on the way, and what nobody checked.
- **Record:** each agent's report as a comment, unedited, and where local outputs are.

Write what stands, not how the audit got there.
The first run's issue became a superseded body, a correcting comment and a column in a table, and had to be rewritten;
when a later wave or a new instruction from the owner changes the verdicts, rewrite the body and keep the earlier text as a comment marked superseded.
Open your next message to the owner with anything you told them that turned out wrong.

A standing candidate goes to `propose-rework` with its outcomes named; offer the invocation.
Record the owner's answers as the `audit-drift` skill's "Record the answers" section describes;
a candidate the owner declines is recorded with the reason in every area it touches.
