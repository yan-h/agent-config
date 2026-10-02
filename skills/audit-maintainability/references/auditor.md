# Maintainability auditor brief

Find structure in one area that makes this project's actual changes more costly than they need to be.
Debt counts only when it taxes changes that happened or that the roadmap commits to;
with no roadmap, weigh it by how often the area changed over the last year.
Read the area's intent record and the project contract you were given.

Audit the primary branch, read-only.
Do not edit files, commit, or open a pull request.
Version-control history, PR titles and bodies, and open issues are all available;
use the issues only at the end, to drop findings already filed.

## Start from the history

You were given where change lands in this area: hotspots, coupled files, fix clusters, and the widest changes.
For each, read the commits and PRs behind it and ask why that change had to touch those places, or had to be fixed again.
The answer names the structure.

The most telling evidence is the file list of a change that added or removed one concept, such as one setting:
every file it had to touch is a hop that concept costs, and the hops it did not need are the finding.
Read those changes' `git show --stat` first.
A file that only lists submodules can rank as a hotspot on history from before it was split up; follow it into its directory.
Spend most of your time here; structure no change has paid for is the least valuable thing to find.

## What to look for on those paths

The shapes that cost most across a whole area:

1. **Ownership.**
   For each piece of state, who writes it and who derives from it.
   Several writers, derived values stored rather than computed, and caches no one clearly invalidates.
2. **Parallel mechanisms.**
   The area solving a problem the codebase already solves elsewhere — a second loader, event path, or settings layer.
   Search for similar names and shapes outside the area.
3. **Boundaries.**
   What callers must know about the inside: invariants each caller maintains, interfaces that expose representation,
   and the coupled files from the history that sit on opposite sides of one.
4. **Special cases.**
   Conditionals on a kind, mode or flag repeated across functions; the representation that would remove them.
5. **Tests that tax change.**
   Tests that break when the structure changes and behaviour does not, and slow tests every change in the area must wait for.
6. **Speculative generality.**
   Abstractions, options and extension points with one user and no planned second.

When a finding is really a reason that moved — a mechanism kept after its case went — mark it as drift and keep going.

## Evidence bar

Sample before counting.
A raw count of pattern matches — struct literals, call sites — misleads until a sample shows what the matches are.

Each finding names the commits or PRs that paid for it, or the roadmap item it would make costly,
and says what the next likely change in the area would cost now and after the fix.
If you cannot name either, it goes under seen and left.

## Report

- **Findings, ranked by net benefit:**
  the structure, `file:line`, the evidence, the fix, its rough upfront cost, what it removes,
  and whether it is mechanical, a rework candidate, or needs the owner's call — phrased as a yes/no question when it does.
- **Shared causes:** findings that one restructuring would dissolve together.
- **Drift:** items that belong to a drift audit, one line each.
- **Seen and left:** debt with no cost and no roadmap pull, one line each.
- **Method notes:** which steps found things and which were noise.

Do not pad. A clean area is a result.
