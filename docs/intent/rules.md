# Intent record: the rules

The owner's answers about this repository's own rules: the global files, the
authoring contract and the skills. One line per decision, as the `audit-shared`
skill's "Record the answers" section says. Nothing the owner did not answer is here.

## Growth

- **A word ceiling for every rule file, enforced by `scripts/check.py` and run on every pull request.** Yes. 2026-11-14, drift audit #103 (G1); tracked in #105.
- **This repository is pulled when a session starts on the Mac, as in cloud sessions.** Yes. 2026-11-14, #103 (G2); in #104.
- **Evidence in skills.** As in the always-loaded files: each rule keeps one reason clause, and counts and further anecdotes stay in the pull request. 2026-11-15, PR #116.

## What goes to the owner

- **Superseding a recorded decision when nothing the owner sees or hears changes.** The session decides and reports the record and the reason; it asks first only when he would see or hear the change. 2026-11-14, #103 (D1); in #104.
- **Whether behaviour and speed hold between a rework's migration steps.** Only at the end, unless he says otherwise; not asked. 2026-11-14, #103 (D2); in #104.
- **A listening or looking check as a gate on a merge.** It does not hold a merge unless he asked for it to. 2026-11-14, #103 (D3); in #104.
- **A command a session could run itself.** It is run, not handed to him. 2026-11-14, #103 (D4); in #104.
- **Filing an issue or adding a comment in his own repositories.** Needs no word from him, and is not severe in the stakes record. 2026-11-14, PR #101.
- **Editing, closing or reopening an issue in his own repositories.** Needs no word from him ("I basically always approve edits when they ask"; "Close and reopen can happen autonomously too"); a session leaves his own words in an issue unchanged. 2026-11-18, PR #126, superseding PR #101's lines on issue edits and closures.
- **Merges.** Still need his word; one agreement covers the set it describes. 2026-11-14, PR #101.
- **Design choices, what he sees or hears, and what to do next.** Stay questions. 2026-11-14, #103.

## Always-loaded files

- **Evidence in `global/AGENTS.md` and `global/claude/CLAUDE.md`.** Each rule keeps one reason clause; counts stay in the pull request that measured them. 2026-11-14, #103 (A1); in #104.
- **Zed in the stakes record's Use line.** Dropped. 2026-11-14, #103 (A2); in #104.
- **Five sentences stated elsewhere** (frequency and severity, the producer check, "keep existing behaviour is not a reason", two lifecycle details, overage and the `resumable` cache). Cut or folded in. 2026-11-14, #103 (A3); in #104.

## Review-and-merge chain

- **Who settles a review question that is the owner's.** Only his own words: chat, an issue or comment he wrote, a recorded decision, an intent record, the global preferences. An agent-written issue or PR description does not. 2026-11-14, #103 (B1); in #104.
- **"Autonomously", and a fix the stakes record pays for.** The fix is made, or the PR stays open. 2026-11-14, #103 (B2); in #104.
- **The unasked API call before a design reaches the owner.** Kept at November 2026's pace of spending; when the month's credits run out, sessions fall back to a subagent. 2026-11-14, #103 (B3).
- **Which model runs a change's design pass, when a fresh agent runs it.** Opus: an `ask-api -m opus` call while the credits last, an Opus subagent after; a rethink verdict, or a recommended rework or architecture choice, gets one Fable call to check it before it reaches the owner. Fable stays for architecture choices, reworks and designs going to the owner, which nothing has yet compared. 2026-11-20, PR #130.

## Audits

- **Fixes swept from a drift or maintainability audit.** They get the design pass, as performance fixes do. 2026-11-14, #103 (C1); in #104.
- **Proving that shorter audit text finds the same things by replaying a past audit.** Dropped as too expensive ("stop the expensive verifications"); the same brief also did not reproduce its own findings. The change that condenses them (#110) is gated instead on a line-by-line trace of the old text into the new and a read of existing transcripts for whether each method step ran; no further replays or pooled runs. 2026-11-14, #110 (1).
- **The audits' shared text.** Moved word for word into one place, with every difference between the copies listed; then cut by a list with word counts that he takes whole or strikes from. 2026-11-14, #110 (2).
- **The audit commands.** Today's five are kept, for now. 2026-11-14, #110 (3).
- **`audit-premises` and `audit-merges` in that change.** Premises comes under the shared text, and its length waits for a draft; the merge audit's wording is left alone. 2026-11-14, #110 (4).

## Rework skills

- **`propose-rework` rating guarantees up front, and either rework skill asking for tolerances.** Dropped; tolerances are taken only when he states them. `audit-premises` keeps its rating step until a run has tested it. 2026-11-14, #103 (E1); in #104.
- **Attack rounds in `audit-premises`.** One per form; further rounds belong to `propose-rework`. 2026-11-14, #103 (E2); in #104, and the round cap is tracked in #89.
