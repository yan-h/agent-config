# Stances

A stance is one agent working across every area in scope, beside the area readers.
Read [the rules](rules.md) first, then "Every stance" and the section your task names.

## Every stance

You answer the audit's question, as [the reader brief](reader.md) states it, from your stance instead of from one area.
You were given the owner's standing preferences; apply them, and say where one decides a verdict.
Your section's method replaces the reader brief's.
Report your candidates in the reader brief's form, plus whatever your section asks for, in about 3,000 words at most.
Where the project lacks something your section rests on, say so and work from what it has.

## Clean-room designer

Design before looking.
First read only what states the goals and what a user does: the goals, the user's guide, the non-goals, the roadmap, the headline measurements and the ratings file.
Do not open the source or the decision records yet.
Design the product from scratch for those goals and the must-keep guarantees alone, as two architectures that differ in kind, not degree.
Then read the design docs and the code, and for each place your designs differ from what exists, decide who is right:
does the existing design know something yours missed, citing the record or code that shows it, or is it carrying a premise that was reasonable once?
Withdraw what the code defeats, and say so.
Report the two designs as revised, and a table of differences with who is right.

## Budget designer

Design for the same user, keeping only the must-keep guarantees, in about a third of today's lines including tests:
not by denser style, but by choosing structures under which the lines are not needed.
Measure where the lines are, by concern and split into source and tests, as a ledger.
For each large concern find what multiplies it, and the structural choice behind each multiplier.
Report the ledger today and in your design, the multipliers ranked by lines,
the overhauls they imply ranked by lines removed per would-trade guarantee given up, and what cannot shrink.

## Performance architect

Earlier performance work optimised inside the architecture. Ask whether a different architecture changes the cost class.
Read the measurements first and trust them over reasoning; where a claim needs a number nobody took, say so and name the probe that would take it.
Read the hot paths whole.
For each structural alternative give the arithmetic from measured figures, the contract or record it breaks, and what it costs in complexity.
Say plainly whether performance is a constraint for this user at all, starting from the ratings file's tolerances, and which roadmap items cost blocks.
Report where the time goes today, the architectures that would change the class, the design you would build from scratch, and what you judged not worth it.

## Prior-art researcher

The project owns pieces other projects have also had to build.
Where could it borrow a structure, an idea or a dependency instead, and where did comparable systems choose a structurally different answer that turned out simpler?
Use web search if you have it.
For each borrowable thing: what it is, who does it, what it would replace here, what it loses, and how sure you are it applies.
Mark what you could not verify, and say where the project's own answer is the better one.

## Process and verification reader

Read how the project is built and kept correct as a design of its own: the gate, the tests as a body, the records and specs, the recurring audits.
Measure the tests by module and by kind, and how often a feature change had to edit tests that were not about its behaviour.
Ask what the recurring audits keep finding, and what check or structure would remove that class instead of catching its instances.
Ask whether the records are the cheapest way to hold intent: what fraction state what a type or test already enforces, and how much prose one ordinary change edits.

## Decision-history analyst

Skipped where the project keeps no decision records.
A decision replaced once was a mistake corrected.
A mechanism whose rule has been replaced several times, or that needs a new record for each case, usually has an unresolved premise underneath.
Build the graph of which record replaced which, read what replaced records said in history where their stubs are thin,
and for each unstable mechanism write down the rules tried, what forced each change, and what stayed constant across all of them: that constant is the candidate premise.
Allow for a process that forced a new record for every amendment; count changes of rule, not restatements.
For each unstable mechanism propose a frame in which its question does not arise.
Also list the stable core, and any record whose stated reason has since gone.
