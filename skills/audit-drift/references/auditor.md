# Auditor brief

Find where one area of the product has drifted from intent:
code that every change kept for a locally good reason, whose reason no longer holds or never paid for it.
Read `SKILL.md` beside this file for the kinds and the worked example, and the area's intent record if the caller names one.

Audit the primary branch, read-only.
Version-control history, PR titles and bodies, and issues open and closed are all available;
use the issues only to drop findings already filed, at the end, and for whether a case was ever reported.

## Before anything else

Pull the area's fresh defaults: what a new user or a new document starts with.
Which tests matter, and which behaviour is the COMMON case, follows from them.
In the first trial two findings only became visible against the shipped defaults,
and every test of one feature turned out to run on a configuration the product does not ship.

## What found things (spend the time here)

1. **Trace each mechanism to its origin.**
   Inventory the area's flags, passes, special cases, constants and settings.
   For each, search history for the change that added it (`git log -S` / `-G`), read that PR's body for the reason,
   and judge whether the reason still holds on the primary branch.
   Where it holds, ask whether the stakes record pays for the mechanism, as the global preferences' section "What a project guarantees" says.
   A mechanism that works leaves no reports, so an absence of them does not show its case never occurs:
   where the origin only supposed the case, the stated use and load are the evidence, and the row says so.
   Judge a requirement an issue took from current behaviour the same way.
2. **Producer reachability.**
   For each field a consumer reads, list the values its callers can actually produce today.
   A branch no caller can reach, a field every stage overwrites,
   and a test fixture using a value the product cannot produce all come out of this step.
3. **Tests as behaviour.**
   Restate each test covering the area as the user-visible behaviour it protects.
   Flag the ones that only restate a mechanism, and the ones whose fixture cannot reach the case they name.

## Cheap sweeps (real, but noisy)

- Identifiers and labels a PR deleted that comments or docs still name.
  About half noise in the first trial.
- Scoping lines — "keep", "preserve", "unchanged", "existing", "comments only", "byte-identical" —
  but only in PRs that REMOVE a setting, feature or target.
  Across every PR it was ninety hits for two findings; those two were the best evidence of intent the trial had.
  For each, name what was kept and trace it to where it was added.

## Report

- **Findings, ranked by how much the owner would notice:**
  observable behaviour, `file:line`, the PRs and the step where it drifted, your confidence,
  and whether the fix is mechanical or needs the owner's call — phrased as a yes/no question when it does.
- **Necessity table**, from step 1: mechanism · reason · whether the stated use reaches it, with the evidence · the worst without it · production and test lines · keep, simplify or cut.
  One row for every simplify and cut, and for each keep that was close.
- **Sweep hits you dismissed**, one line each with why.
- **Tests flagged**, with the reason.
- **Method notes:** which steps found things, which were noise, what you would change.

Do not pad. A clean area is a result.
