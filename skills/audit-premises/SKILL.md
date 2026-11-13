---
name: audit-premises
description: Audit a project for overhauls that become possible if recorded decisions may be superseded and behaviour guarantees given up — designs a different premise would make simpler, faster or impossible to get wrong. The owner rates the guarantees first, readers propose, red teams and experiments test, and a candidate whose shape an attack breaks is reshaped before it is cut down. Produces tested rework candidates for the owner, not fixes. Started only by the repository owner invoking it explicitly.
disable-model-invocation: true
---

# Audit the premises

**The owner starts this.** A session that suspects a wrong premise says an audit looks due and stops there;
it does not run the procedure below by hand instead.
`disable-model-invocation` above enforces that in hosts that honour it;
Codex does not, so in Codex this paragraph is the rule itself.

Read the project's local contract before starting, with its roadmap, recorded decisions and intent records.
Worktrees, branch and PR conventions, and where intent records live all come from there;
where it says nothing about intent records, use `docs/intent/<area>.md`.
This audit uses the `audit-drift` skill's "Choose the scope" and "Record the answers" sections, installed beside this one;
if it is not installed, say so and stop.

## What this audit is

It asks whether a group of decisions shares a premise that a different design would not need.
It has no bar that a change must already have paid for the cost: a candidate may come from the goals alone, from prior art, or from what would change the cost class.

**Every recorded decision is open here, as is every guarantee the owner has not rated must keep;** a candidate an attack breaks is reshaped before it is cut down.
[The rules](references/rules.md) say what that means and how a candidate is judged; read them completely, and give every agent that file.

The output is tested rework candidates for the `propose-rework` skill. This audit changes no code beyond scratch probes.

## Before starting

**Cost.** The first run used 27 agents over two waves, about 260k tokens each, 7 million in all besides the coordinating session; the last round below adds a few more.
Invoking the skill is the owner accepting a run of that order. State the number of agents before the inventory and before each wave, so the owner can interrupt.
The owner's ratings of the guarantees shrink the waves: in the first project they removed most of the planned agents before any ran.
Run both waves or neither: the first wave alone produced a confident, convergent ranking in which four of the top five candidates were later defeated or cut to a third or less.

**Where the report lives.** The run writes to the tracker: one tracking issue, each agent's report as a comment on it, an issue for each defect reproduced on the way, and later rewrites of the tracking issue's body.
Before any agent runs, ask the owner for those writes in one question, in whatever words the host's global file says such writes need.
Without a tracker, or without that consent, the report is a Markdown file in the repository with each agent's report as a file beside it,
on a branch, as a draft pull request where the project has them, and a defect is a section of the report instead of an issue.

**What earlier runs settled.** Read the last premises audit's report, the open rework issues, and the declined candidates in the intent records.
Do not pass them to the readers, who would anchor on them. Use them between the waves:
a candidate the owner declined is raised again only with evidence that was not there before, and says what changed.

Size each agent by the global subagent guidance.
The red teams and the designers among the stances are the consequential judgement; fact-finding is lighter.

## Choose the scope

The text after the invocation names one area (`$ARGUMENTS` in Claude, the text after `$audit-premises` in Codex); with none, audit every area.
Use the area map from the last area-based audit's tracking issue if there is one; otherwise map the project as the `audit-drift` skill's "Choose the scope" section describes.
Split an area too large for one reader to read whole along its own seams.

With one area named, its readers and every stance work inside it;
a premise that crosses its boundary is reported as seen and out of scope.

If the `audit-maintainability` skill is installed, run the history map in its directory as its "Map where change lands" section describes,
once for the project and once per area, and hand each reader its slice: a reader that counts history by hand splits every renamed file's history in two.

## Rate the guarantees

A guarantee is what the product promises its user, recorded or not: a behaviour, a look, a capability, identity between runs or builds, a performance target, compatibility with saved data or a host.
Readers hold an unrecorded guarantee fixed. In the first project, three designs kept every behaviour the product had;
the larger rework came only once the owner gave up guarantees no record stated, among them seamless output across structural edits and identical output between builds.

Run one inventory agent per area, bounded lookup, with the area's paths, docs and history slice. It lists each guarantee the area gives:
where it is recorded, if anywhere; the code and tests that serve it, with their lines; and the commits that paid for it.
Sizes are estimates and are labelled so.

Then go through the list with the owner in chat, one guarantee at a time:

- **Must keep:** a constraint every agent is given. A candidate that breaks it ends before anything tests it.
- **Would trade for a large simplification:** open. A candidate may give it up; a red team defends it, and the owner decides with the size in hand.
- **Don't care:** open. A candidate that removes it needs only a count of what goes.

A rating may name a form the owner would accept instead, and the owner may change a rating later:
"must keep, but a grid would do" opened a redesign of placement, and the owner kept an animation they had first given up.
Ask too for the owner's tolerances for the run: what counts first, how much machinery an edge case may keep, how loose performance targets may be, and how much change in output is acceptable.

Write the ratings and tolerances to a file every later agent is given by path, and record them as "Record the answers" describes.
Both areas rated so far were rated with sizes from a full earlier run in hand; an inventory alone has not been shown to size guarantees well enough to rate.
If the owner cannot rate without sizes, run the first wave on the decisions alone, rate between the waves, and point the second wave at the rated premises. Say in the report which way the run went.

## First wave: readers who propose

Read [the reader brief](references/reader.md) and [the stances](references/stances.md) completely before delegating.
Give each agent the paths of the rules, of its brief and of the ratings, not their contents, with the owner's standing preferences from the project contract and the global preferences, and a path for its report.
Run all of them in parallel:

- **One reader per area,** with the area's paths, docs and history slice.
  Give it questions to hold, not your own guesses at its answer: an agent handed a hypothesis returns it confirmed.
- **One agent per stance,** told which section of the stances file is its own, with the whole history map for the process and decision-history stances.
  Area readers are anchored on what exists. The stances are not:
  one designs from the goals before opening the code, one designs to a third of the size, one asks what would change the cost class,
  one looks at prior art, one reads how the project is kept correct, and one mines the decision history.

Readers report candidates they are unsure of, labelled strong, plausible or speculative.
A brief that asked only for candidates that survived the reader's own attack, three at most, had to be amended mid-run.

Each report lists what its agent read whole. From those lists, find the subsystems no one read, and send a reader to each that matters.
In the first run every reader had skipped one subsystem, whose fields were nearly a third of the central data record.

## Between the waves: do not rank yet

Agreement among readers is weak evidence: they read the same records.
Seven readers reached one candidate that a red team then cut to a third, and five reached one that was defeated.

Group the candidates by the premise each questions, across areas, and set aside what earlier runs settled.
A guarantee a reader found that the inventory missed goes to the owner to rate before any candidate resting on it is tested.
Check each report's central claims yourself by reading the cited lines.
A search that matches a word is not a check: two statements made to the owner from such searches were false.

Write the groups to a file. It is the write-up the second wave is given, and what you tell the owner:
candidates under test, not a ranking, with the number of agents the second wave will use. Then start it.

## Second wave: test, and reshape what breaks

Read [the tester brief](references/tester.md) completely before delegating.
Give each tester the paths of the rules, of that brief and of the ratings, the write-up, the reports behind its group, its task, a directory for outputs and a path for its report.

- **One red team per premise group that holds a strong or plausible candidate:** one agent, with the single job of defeating it against the code.
  A group with only speculative candidates is listed in the report as untested.
- **An experiment, wherever the product can already answer:**
  - a profile before trusting an inferred split. An inferred 77/11/12 measured 65/17/16, and "about 5 times" measured 1.6;
  - an emulation with features the product already has. One candidate could be run, timed and compared using two existing settings;
  - a scratch prototype for a candidate that proposes a new check or mechanism, run against historical defects reintroduced on purpose.
    A proposed check caught neither of two until a fourth check was added;
  - a rendering of every real case, for the owner to look at, where the question is taste.
- **Fact-finding** for each "not checked" item a candidate rests on.

An agent that writes scratch code works in its own worktree. Long builds, and every timing a verdict rests on, stay in the coordinating session.

Check what comes back as you checked the readers.
Reproduce every defect an agent reports before telling the owner, and file each that reproduces as its own issue.
Check a defeat's central claim too: a red team is an agent handed a hypothesis, and a false defeat stays in the report as a reason not to propose something again.

A prototype worth keeping goes on a branch as a draft pull request, which the report lists:
an ignored directory in a worktree that can be reclaimed is where the first run nearly left its only copy.

## Recombine, then attack once more

Take each red team's verdict in turn:

- **Defeated on the problem:** the candidate ends. Where the reason is the owner's, say where it is recorded.
- **Loses a capability:** a yes/no question for the owner, or the shape that keeps the capability.
- **Conditional:** combine it with the piece it names.
- **Breaks, with no answering shape found:** look for the answer among the other candidates' pieces before setting it aside with the attack recorded.
- **Smaller form:** it is the candidate where the red team showed it leaves nothing lasting in place; otherwise restore the full form and say what the smaller one leaves.

Build the combined forms whose pieces answer each other's objections.
A reshaped or combined form is a new candidate, whoever designed it. Send one fresh red team at each form the report's verdict would rest on.
A form that this red team also breaks is reported as open, with both attacks, for the owner to decide whether to spend more on it.
Every other reshaped or combined form is marked untested wherever it appears.

The first run stopped before this round, so it is the least tested step here; say in the report how it went.

## Report

Written as the current state:

- **Verdict first,** in a few lines, then what to do next, in order.
- **Decisions that are the owner's,** each answerable yes or no, with what happens on either answer.
- **The ratings,** with what each would-trade and don't-care guarantee was found to cost, and which candidates gave it up.
- **Each standing candidate:** the premise, what it costs today with evidence, the target, what it removes, what it loses,
  each record it supersedes with the reason that no longer holds, what was tested and how, what is untested, and which reader or stance proposed it.
- **Defeated or set aside,** one line each with the reason, so it is not proposed again unchanged.
- **Load-bearing and right:** what no candidate touches and why.
- **Measurements,** issues filed on the way, open prototype pull requests, and what nobody checked.
- **Record:** the area map, each agent's report unedited, and where local outputs are.

Write what stands, not how the audit got there.
The first run's issue became a superseded body, a correcting comment and a column in a table, and had to be rewritten;
when a later round or a new instruction from the owner changes the verdicts, rewrite the report and keep the earlier text beside it, marked superseded.
Open your next message to the owner with anything you told them that turned out wrong.

A standing candidate goes to `propose-rework` with its section of the report and its outcomes named; offer the invocation.
When the owner answers, record each answer as the `audit-drift` skill's "Record the answers" section describes, in the intent record of every area the candidate touches;
a declined candidate is recorded there with the reason.
This report has no index to tick: rewrite the answered decision's line in the report instead.
