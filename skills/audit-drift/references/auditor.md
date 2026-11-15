# Auditor brief

Find where one area of the product has drifted from intent:
code that every change kept for a locally good reason, whose reason no longer holds.
Read `SKILL.md` beside this file for the kinds and the worked example, and the area's intent record if the caller names one.

Audit the primary branch, read-only.
Version-control history, PR titles and bodies, and open issues are all available;
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
   Where it holds, ask whether it pays for the mechanism:
   how often the case occurs in the owner's use, what going without the mechanism costs when it does (lost data, wrong output, a warning, a log line),
   and the production and test lines that exist only for it.
   Take frequency from evidence, not from what could happen: the fresh defaults, the intent record, the platforms the owner runs,
   and whether the origin PR or any issue records the case happening, or only a review finding that supposed it.
   Where nothing shows the case occurring, say that.
   A rare case that loses data can still earn its mechanism; one that costs a warning does not.
   Price a requirement the same way: a must-keep an issue took from current behaviour is not the owner's decision.
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

Defaults at a range end found nothing in the first trial; skip it unless the area is mostly settings.

## Report

- **Findings, ranked by how much the owner would notice:**
  observable behaviour, `file:line`, the PRs and the step where it drifted, your confidence,
  and whether the fix is mechanical or needs the owner's call — phrased as a yes/no question when it does.
- **Necessity table**, from step 1: mechanism · reason · how often in the owner's use, with the evidence · cost without it · production and test lines · keep, simplify or cut.
  One row for every simplify and cut, and for each keep that was close.
- **Sweep hits you dismissed**, one line each with why.
- **Tests flagged**, with the reason.
- **Method notes:** which steps found things, which were noise, what you would change.

Do not pad. A clean area is a result.
