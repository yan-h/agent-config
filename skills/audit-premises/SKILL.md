---
name: audit-premises
description: Audit a project for overhauls that become possible if recorded decisions may be superseded and behaviour guarantees given up — designs a different premise would make simpler, faster or impossible to get wrong. The owner names the guarantees that must be kept, readers propose, red teams and experiments test, and a candidate whose shape an attack breaks is reshaped before it is cut down. Produces tested rework candidates for the owner, not fixes. Started only by the repository owner invoking it explicitly.
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
The `propose-rework` skill uses the rules, the inventory and tester briefs and "Rate the guarantees" by name; rename them only together with that skill.

## What this audit is

It asks whether a group of decisions shares a premise that a different design would not need.
It has no bar that a change must already have paid for the cost: a candidate may come from the goals alone, from prior art, or from what would change the cost class.

**Every recorded decision is open here, as is every guarantee the owner has not rated must keep;** a candidate an attack breaks is reshaped before it is cut down.
[The rules](references/rules.md) say what that means and how a candidate is judged; read them completely, and give every agent that file.

The output is tested rework candidates for the `propose-rework` skill. This audit changes no code beyond scratch probes.

## Before starting

**Cost.** The first run used 27 agents over two waves, about 260k tokens each, 7 million in all besides the coordinating session; the last round below adds up to three red teams for each form the verdict rests on.
Invoking the skill is the owner accepting a run of that order. State the number of agents before the inventory and before each wave, so the owner can interrupt.
The owner's must-keeps shrink the second wave: readers report what a must-keep rules out as that guarantee's price, which the second wave does not test.
In the first project, rating every guarantee with sizes in hand removed most of the planned agents before any ran; naming only must-keeps prunes less, so expect a larger second wave.
Run both waves or neither: the first wave alone produced a confident, convergent ranking in which four of the top five candidates were later defeated or cut to a third or less.

**Where the report lives.** The run writes to the tracker: one tracking issue, each agent's report as a comment on it, an issue for each defect reproduced on the way, and later rewrites of the tracking issue's body.
Before any agent runs, ask the owner for those writes in one question, in whatever words the host's global file says such writes need.
Without a tracker, or without that consent, the report is a Markdown file in the repository with each agent's report as a file beside it,
on a branch, as a draft pull request where the project has them, and a defect is a section of the report instead of an issue.

**What earlier runs settled.** Read the last premises audit's report, the open rework issues, and the declined candidates in the intent records.
Do not pass them to the readers, who would anchor on them. Use them between the waves:
an earlier decline, defeat or set-aside settles a candidate only while its recorded reason holds here.
A decision or guarantee this audit holds open does not settle it, and neither does an audit's or review's weighing of upfront effort;
the owner's own reason does, whichever process showed the owner the candidate, unless that reason is a guarantee the owner has not named must keep in this run.
A settled candidate is raised again only with evidence that was not there before, and says what changed.

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

[The rules](references/rules.md) define a guarantee and what each rating does to a candidate.

Run one inventory agent per area with [the inventory brief](references/inventory.md), the area's paths, docs and history slice, the ratings already recorded in the intent records,
the measurements earlier audits made of the area (sizes and costs, not their candidates or verdicts), and a path for its report.
Size it as judgement, not lookup: the guarantees that mattered in the first project were ones no record stated.
Merge the lists, keeping a product-wide guarantee once.

Then show the owner the merged list in chat, area by area, largest first, with the recorded ratings shown as standing unless the owner changes one,
and ask one thing: which must be kept, and what form the owner would accept instead. Must-keeps prune most:
"must keep, but a grid would do" opened a redesign of placement.
Every guarantee the owner does not name stays unrated, and comes back to the owner only through the guarantee question below.
The owner may rate more now, but is not walked through the list one guarantee at a time:
that spends the owner's attention on guarantees no candidate touches, and asks before the size is known, where the guarantee question comes with a reader's size.
The default leans open for the reason the rules give under "What is open".
Ask too for the run's tolerances where they depart from the standing preferences in the project contract:
what counts first, how much machinery an edge case may keep, how loose performance targets may be, and how much change in output is acceptable.

Write the ratings file: each guarantee in user terms with its rating, or marked unrated, and any accepted form, then the run's tolerances.
Leave out the inventory's code pointers, which would anchor the clean-room designer. Every later agent gets the file's path.
Record each rating the owner gave in the intent record of every area the guarantee touches, as the `audit-drift` skill's "Record the answers" section describes but with no index to tick;
record a don't-care as open to giving up in a rework, not as leave to remove the guarantee outside one. The run's tolerances are not recorded there.
When the owner changes a rating, update the file and the record before the next agent starts, and recheck the candidates that rested on the old rating;
the owner reversed one within the same session in the first project.

Both areas rated so far were rated with sizes from a full earlier run in hand, which is why the inventory gets earlier audits' measurements;
whether an inventory sizes guarantees well enough without them is untested.
Say in the report how many must-keeps the owner named before the first wave, whether the inventory had earlier measurements, and where readers' sizes disagreed with the inventory's;
naming only must-keeps up front is untried too.

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
Check each report's central claims yourself by reading the cited lines.
A search that matches a word is not a check: two statements made to the owner from such searches were false.

Write the groups to a file. It is the write-up the second wave is given, and what you tell the owner:
candidates under test, not a ranking, with the number of agents the second wave will use.
Ask the guarantee question for the groups that will be tested, then start the wave.

## The guarantee question, before any attack

No form goes to a red team while a guarantee it gives up is unrated or flagged unclear.
For those forms only, show the owner what each gives up, with the sizes readers reported, and what each must-keep has ruled out so far, so the owner can release one;
then ask the question asked before the first wave: which must be kept, and in what form.
What is shown and not named becomes "would trade (not named)" in the ratings file, not in the intent records, since the owner rated nothing.
Ask it before the second wave and before every round of the last one. A rating changed here is handled as "Rate the guarantees" says.

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

## Recombine, and attack until a form holds

Take each red team's verdict in turn:

- **Defeated on the problem:** the candidate ends. Where the reason is the owner's, say where it is recorded.
- **Gives up a guarantee:** judged by its rating as the rules say; a would-trade one is a yes/no question for the owner in the report, with what goes with it, and an unrated or unclear one goes to the guarantee question before the form's next attack.
- **Conditional:** combine it with the piece it names.
- **Breaks, with no answering shape found:** look for the answer among the other candidates' pieces before setting it aside with the attack recorded.
- **Smaller form:** it is the candidate where the red team showed it leaves nothing lasting in place; otherwise restore the full form and say what the smaller one leaves.

Build the combined forms whose pieces answer each other's objections.
A reshaped or combined form is a new candidate, whoever designed it. Send one fresh red team, briefed as in the second wave with the current ratings file, at each form the report's verdict would rest on,
aimed at what the form adds or revises and what that touches.
Keep a ledger per form: for each round, what the attack hit, and what the form removes compared with the form that entered the first round.

A form holds when an attack changes nothing the owner would decide: what it finds is work `propose-rework` would do in designing the form,
not an attack on the problem, a lost must-keep, or a guarantee given up that is unrated or unclear.
A would-trade guarantee it gives up is a question in the report and does not stop it holding. "Survives in a new shape" is a reshape, not a hold.
A form that does not hold is reshaped by the verdicts above and attacked again: up to three attacks in all for each form that entered the first round, its reshapes included.
Stop sooner, and report the form open, when a second reshape answers an attack on the same piece, the sign of a premise left unresolved,
or when the form now removes less than the one that entered the first round, which is reported beside it: reshaping toward what survives is the shrinking the rules warn of.
A smaller form accepted by the verdict above is exempt, having shown it leaves nothing lasting in place.
State the round and the running total of agents before each round.
A form stopped by the cap, by either stop or by the owner is reported as open, with every attack and what the next would aim at; no answering shape sets it aside with every attack recorded.
Every other reshaped or combined form is marked untested wherever it appears.

The first project stopped too early here: its combined rework was never attacked whole, the design that followed was attacked once,
and the claims revised to answer that attack, the ones most in need of one, never were.
Say in the report how many rounds each form took.

## Report

Written as the current state:

- **Verdict first,** in a few lines, then what to do next, in order.
- **Decisions that are the owner's,** each answerable yes or no, with what happens on either answer.
- **The ratings,** with what each would-trade and don't-care guarantee was found to cost, which candidates gave it up,
  and what each must-keep ruled out, marked untested where nothing attacked it: the rating that limits the audit most is otherwise the one whose price the owner never sees.
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
a declined candidate is recorded there with the owner's reason, in the owner's words.
This report has no index to tick: rewrite the answered decision's line in the report instead.
