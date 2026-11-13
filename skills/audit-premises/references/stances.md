# Stances

Each stance is one agent working across every area, beside the area readers.
Give it [the reader brief](reader.md) for the audit's question, rules and evidence bar, then its paragraph below as the task.
Each reports its candidates in the reader brief's form unless its paragraph asks for something else, in about 3,000 words at most.

## Clean-room designer

Design before looking.
First read only what states the goals and what a user does: the goals, the user's guide, the non-goals, the roadmap, and the headline measurements.
Do not open the source or the decision records yet.
Design the product from scratch for those goals, as two architectures that differ in kind, not degree.
Then read the design docs and the code, and for each place your designs differ from what exists, decide who is right:
does the existing design know something yours missed, citing the record or code that shows it, or is it carrying a premise that was reasonable once?
Withdraw what the code defeats, and say so.
Report the two designs as revised, a table of differences with who is right, and what you did not check.

## Budget designer

Design the same product, for the same user, in about a third of today's lines including tests:
not by denser style, but by choosing structures under which the lines are not needed.
Measure where the lines are, by concern and split into source and tests, with a real ledger.
For each large concern find what multiplies it — kinds times modes times displays, hand-written code a table could drive,
a second implementation kept for display, tests that restate the implementation, state kept alive across edits — and the structural choice behind each multiplier.
Report the ledger today and in your design, the multipliers ranked by lines, the overhauls they imply ranked by lines removed per capability lost, and what cannot shrink.

## Performance architect

Earlier performance work optimised inside the architecture. Ask whether a different architecture changes the cost class.
Read the measurements first and trust them over reasoning; where a claim needs a number nobody took, say so and name the probe that would take it.
Read the hot paths whole.
For each structural alternative give the arithmetic from measured figures, the contract or record it breaks, and what it costs in complexity.
Say plainly whether performance is a constraint for this user at all, and which roadmap items cost blocks.
Report where the time goes today, the architectures that would change the class, one runtime you would build from scratch, and what you judged not worth it.

## Prior-art researcher

The project owns pieces other projects have also had to build.
Where could it borrow a structure, an idea or a dependency instead, and where did comparable systems choose a structurally different answer that turned out simpler?
Use web search if you have it.
Nothing identifying goes in a query: no project or owner name, no repository address, no file contents.
For each borrowable thing: what it is, who does it, what it would replace here, what it loses, and how sure you are it applies.
Mark what you could not verify, and say where the project's own answer is the better one.

## Process and verification reader

Read how the project is built and kept correct as a design of its own: the gate, the tests as a body, the records and specs, the recurring audits.
Measure the tests by crate or package and by kind, and how often a feature change had to edit tests that were not about its behaviour.
Ask what the recurring audits keep finding, and what check or structure would remove that class instead of catching its instances.
Ask whether the records are the cheapest way to hold intent: what fraction state what a type or test already enforces, and how much prose one ordinary change edits.

## Decision-history analyst

A decision replaced once was a mistake corrected.
A mechanism whose rule has been replaced several times, or that needs a new record for each case, usually has an unresolved premise underneath.
Build the supersession graph, read what superseded records said in history where their stubs are thin, and for each unstable mechanism write down
the rules tried, what forced each change, and what stayed constant across all of them: that constant is the candidate premise.
Allow for a process that forced a new record for every amendment; count changes of rule, not restatements.
For each unstable mechanism propose a frame in which its question does not arise.
Also list the stable core, and any record whose stated reason has since gone.
