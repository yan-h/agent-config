---
name: api-second-opinion
description: Ask Claude Fable (or another Claude model) over the Claude API for a design answer, second opinion or full design review, billed to prepaid API credits rather than the subscription. When the owner asks for a Fable, API or second opinion or review, or unasked when Fable's one answer would be significantly more useful than a subagent's; never from a subagent.
---

# A second opinion over the API

`ask-api` sends one question, with the context you choose, to the Claude API and prints the answer.
It bills the API key's credits, which Claude Code itself cannot spend, so the call costs the owner's subscription nothing.
The credits are an allowance of about $100 a month that does not carry over: credit left at the month's end is lost, not saved.
Calls so far have cost $0.70 to $4.10, about $1.60 on average, so the allowance covers around two a day;
a Fable call's worst case is about $6.40 of output plus $1 per 100k tokens of input.
Send the context the question needs rather than everything nearby.
Only the session that owns the task calls it, not a subagent, so one session sees the task's whole spend.

```sh
ask-api "Is keying this cache on the whole config sound?" -f src/cache.rs -f src/draw.rs:120-180
ask-api --review                          # branch vs its merge base with main, plus every changed file
ask-api --review --diff "HEAD~3" "focus on the persistence change"
git log -p -5 -- src/take.rs | ask-api --stdin "What has this file's churn been fixing?"
```

`--model` takes `fable` (the default), `opus` or `sonnet`, each meaning the newest active model of that line, or a full model ID to pin one.
Use another model only when the owner asks: Fable is what the API adds, and in Claude Code a subagent runs Opus or Sonnet with tools, from quota rather than credits.
Stdin is read only with `--stdin`.
`--effort` defaults to `high`, and `xhigh` with `--review`; `--max-tokens` to 128000, the current models' most, since thinking counts against it and a lower cap can spend it all thinking and return no answer, still billed.
The project's `AGENTS.md` (or `CLAUDE.md`) and the owner's global preferences go in the system prompt; `--no-instructions` leaves them out.

## When to call it unasked

Call it without being asked whenever Fable's answer would be significantly more useful than a subagent's on the same task (in Claude, an Opus subagent's).
Underuse is the failure seen so far: of 77 review sessions in the week after unasked calls were allowed, 12 called it at all, and nearly all of those only after the owner mentioned Fable.
So weigh an unasked call against the subagent it would replace, not against keeping the money.

Fable is the stronger choice when the answer is judgement rather than search, the context it turns on can be named and sent, and a better judgement could change what happens next:

- the design pass on a change with real logic, shared or cached state, concurrency or persistence;
- choosing between architectures, or weighing a rework's cost against its gains;
- a correctness or performance diagnosis that has stalled once the evidence is gathered.

A subagent is the better choice when the work needs exploring, running or editing, when the answer turns on code you cannot name in advance, or when the question is routine enough that a stronger model would answer it the same way.

## Choosing the context

The model sees only what you send: the question, the files named with `-f`, the diff, and piped input.
It cannot open a caller, a test or the place a value is built.
Before asking, read enough yourself to name the files the answer turns on, and add them:
for a cache, where its key and its inputs are built; for a new branch, the test meant to reach it.
A `--review` already includes every changed file in full.
`-f path:START-END` sends only those lines; use it for the parts of a large file the answer turns on.

## Reviewing a design

When the owner asks for one, the call stands in for the `design-review` skill's whole review, at whatever depth that takes.
Unasked, it serves as that skill's design pass where the test above holds; the correctness review still runs beside it.
Every call sends that skill's `references/design-pass.md` in the system prompt, and `--review` asks for its report shape.

For a design not yet written as code, put the proposal first in a file, then numbered questions, then the code excerpts it rests on, and pass it with `--stdin` or `-f`.
Ask the model to check the proposal's claims against the excerpts and to say what would change its answer.

## The cost guard

Before sending, `ask-api` counts the input tokens and prints the worst case: the input plus `--max-tokens` of output at the model's price.
Over `--max-cost` (default $20), or for a model with no known price, it stops with exit code 2.
Do not pass `--yes` or raise `--max-cost` unless the owner has agreed to that call's cost; narrow the context or ask instead.
`--dry-run` prints the estimate and the included context without sending.

A model released after the price table's newest row for its line borrows that row's price, and the estimate says so.
Tell the owner when that note appears, because the table wants a row for the new model.
An older or unlisted model has no price, since it may cost more.

## After the answer

Treat the answer as a lead, not a verdict.
Check each finding against the code before reporting it, and report which held, which did not and why, and the cost line `ask-api` printed.
Report a call the owner did not ask for in the same way, with why you made it: they did not see it start, and a cloud session's log is lost with its machine.
Check first the code the model says it was not shown: its claims about what it saw are usually sound, and its open questions are where findings hide.
Exit codes: 3 means the model declined (there is no automatic fallback, because its second attempt would escape the cost guard; hand the question to a subagent or answer it yourself, if it is still worth answering), 4 means the answer was cut off at `--max-tokens`.

## What the credits pay for

The owner's API credits cover the API, the Batch API, the Agent SDK, the Playground and Managed Agents, not Claude Code:
Claude Code started with the key as `ANTHROPIC_API_KEY` fails with "credit balance too low", so do not route a session through it.
The balance is prepaid, so running out makes calls fail rather than charge, as long as auto-reload stays off under the Console's Billing settings.

## Setup

`scripts/install.sh` at the repository root creates the venv with the `anthropic` SDK and links `ask-api` into `~/.local/bin` (see the README).
Then, once per machine, store the key in the Keychain:

```sh
security add-generic-password -a "$USER" -s anthropic-api-key -w
```

Create a separate API key per machine or cloud environment in the Console, in a workspace with a spend limit.
For Claude Code, allow `Bash(ask-api:*)` in `~/.claude/settings.json`; reading the key from the Keychain is otherwise blocked as credential access.
An `ASK_API_KEY` in the environment takes precedence over the Keychain item, and is the only source where there is no Keychain, as in a cloud session.
`ask-api` never reads `ANTHROPIC_API_KEY`, which Claude Code itself would use.
Calls always go to `api.anthropic.com`, whatever `ANTHROPIC_BASE_URL` says, so a gateway never sees the key.
Each sent call is appended to `~/.local/state/ask-api/log.jsonl` with its model, tokens, cost and status, including calls that fail partway; a cloud session's log is lost with its machine.
