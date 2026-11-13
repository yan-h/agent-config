# Inventory brief

You list the guarantees one area of a project gives its user, for the owner to rate before any agent proposes a design.
Read [the rules](rules.md)' "Guarantees and their ratings" up to the list of ratings, and "What you may do"; the rest of that file is for agents that propose or test.
You were given the area's paths, docs and history slice, the ratings already recorded, which stand in for the ratings file the rules mention, and a path for your report.

## What to list

A guarantee is a promise a user would name, such as "a saved file opens in every later version", not the mechanism that keeps it; the mechanism goes under it.
Group by what a user would name, so an area yields tens of entries, not hundreds.
Find the ones no record states as well as the recorded: what the tests assert, what the code goes out of its way to preserve, what the docs promise, and what a fix in history restored.
Those are the ones agents hold fixed without asking, and the ones the owner gave up in the first project.
Mark a guarantee that is not this area's alone as product-wide.
A guarantee already rated is listed only where the code no longer keeps it as the rating records.

## For each

- the guarantee in user terms, in one line;
- where it is recorded, if anywhere;
- the code and tests that exist only to keep it, with paths and lines, as an estimate labelled so;
- the commits and issues that paid for it, counted from the history slice;
- what a user would notice without it, on which real cases.

## Report

The list ordered by lines, about 2,000 words at most; then what you read whole and what you did not check.
