---
name: api-second-opinion
description: Ask Claude Fable over the Claude API, billed to prepaid credits rather than the subscription, for a design answer, second opinion or design review. When the owner asks for an API call or a second opinion; unasked wherever a Fable subagent would otherwise judge from context you can name and send, a change's design pass included, and before a design or plan goes to the owner for decision; never from a subagent.
---

# A second opinion over the API

`ask-api` sends one question, with the context you choose, to the Claude API and prints the answer.
It bills the API key's credits, which Claude Code itself cannot spend, so the call costs the owner's subscription nothing.
The credits are an allowance of about $200 a month that does not carry over.
Under Fable 5.2, questions average $1.48 and reviews of code $2.77, input costing $0.80 per 100k tokens.
Only the session that owns the task calls it, not a subagent, so one session sees the task's whole spend.

```sh
ask-api "Is keying this cache on the whole config sound?" -f src/cache.rs -f src/draw.rs:120-180
ask-api --review                          # branch vs its merge base with main, plus the changed files that fit
ask-api --review --diff "HEAD~3" "focus on the persistence change"
git log -p -5 -- src/take.rs | ask-api --stdin "What has this file's churn been fixing?"
```

`--model` takes `fable` (the default), `opus` or `sonnet`, each meaning the newest active model of that line, or a full model ID to pin one.
Use another model only when the owner asks: in Claude Code a subagent runs any of them with tools, from quota rather than credits.
`--max-tokens` defaults to 128000, the current models' most: thinking counts against it, and a lower cap can spend it all thinking and return no answer, still billed.
Run it in the background with a one-hour limit on the shell command (in Claude Code, `run_in_background` with `timeout: 3600000`):
reviews take about 10 minutes and up to 13, and a run the shell kills is billed for what it streamed while nothing reaches the log.
The project's `AGENTS.md` (or `CLAUDE.md`) and the owner's global preferences go in the system prompt; `--no-instructions` leaves them out.

## When to call it unasked

Call it without being asked in two cases where the answer is judgement rather than search and you can name and send the context it turns on.
First, before you put a design, a plan or an architectural recommendation to the owner for a decision, unless the choice is small or easily reversed:
the owner kept asking whether it was worth asking Fable.
Second, wherever you would otherwise brief a Fable subagent and one answer would serve about as well:
the design pass on a change, with `--review` and the files beyond the diff it turns on; choosing between architectures, or judging a rework's lasting costs against its gains;
a design written as a proposal, before its code; a correctness or performance diagnosis that has stalled once the evidence is gathered.

Keep the subagent when the work needs exploring, running or editing, or when the answer turns on code you cannot name in advance:
a correctness review hunts through callers, tests and definitions the diff does not show, which a subagent can open and an API call cannot.
Where an Opus subagent would serve, because Fable would answer the same way, use that rather than the API.

## Choosing the context

The model sees only what you send: the question, the files named with `-f`, the diff, and piped input.
Before asking, read enough yourself to name the files the answer turns on, and add them:
for a cache, where its key and its inputs are built; for a new branch, the test meant to reach it;
for a rule, list or sequence the change edits, the other sites that spell it, which you search for first.
A `--review` sends its diff with 10 lines of context and attaches changed files whole, smallest first, up to 150k characters; it names the files it left out.
`-f path:START-END` sends only those lines; use it for the parts of a large or left-out file the answer turns on.

## Reviewing a design

When the owner asks for a review over the API, the call stands in for the `design-review` skill's whole review, correctness included.
Unasked, it stands in only for that skill's design pass; the correctness review still runs beside it.
Every call sends that skill's `references/design-pass.md` in the system prompt, and `--review` asks for its report shape.

For a design not yet written as code, put the problem and its constraints first in a file, then the proposal, marked as yours rather than the owner's, then numbered questions, then the code excerpts it rests on, and pass it with `--stdin` or `-f`.
Ask the model to check the proposal's claims against the excerpts and to say what would change its answer.

## The cost guard

Before sending, `ask-api` prints the worst case, the input plus `--max-tokens` of output at the model's price, and stops with exit code 2 over `--max-input` (default 100k tokens), over `--max-cost` (default $20), or for a model with no known price.
Over the input limit, narrow the context if the answer turns on less of it; otherwise give the question to a subagent, which reads only what it needs, with the files to start from.
Do not pass `--yes` or raise either limit unless the owner has agreed to that call's cost; narrow the context or ask instead.
`--dry-run` prints the estimate and the included context without sending.
When the estimate says a price was assumed from an older model's row, tell the owner: the table wants a row for the new model.

## After the answer

Treat the answer as a lead, not a verdict.
Check each finding against the code before reporting it, and report which held, which did not and why, and the cost line `ask-api` printed.
Report a call the owner did not ask for in the same way, with why you made it: they did not see it start, and a cloud session's log is lost with its machine.
Check first the code the model says it was not shown: its claims about what it saw are usually sound, and its open questions are where findings hide.
Exit code 3 means the model declined; there is no automatic fallback, because its second attempt would escape the cost guard: hand the question to a subagent or answer it yourself, if it is still worth answering.
Exit code 4 means the answer was cut off at `--max-tokens`.

## What the credits pay for

The credits do not cover Claude Code: a session started with the key as `ANTHROPIC_API_KEY` fails with "credit balance too low", so do not route one through it.
The balance is prepaid, so running out makes calls fail rather than charge while auto-reload stays off in the Console's Billing settings;
once the credits have run out, give the question to a subagent, Fable where the call stood in for one.

## Setup

`scripts/install.sh` at the repository root creates the venv with the `anthropic` SDK and links `ask-api` into `~/.local/bin` (see the README).
Then, once per machine, store the key in the Keychain:

```sh
security add-generic-password -a "$USER" -s anthropic-api-key -w
```

Create a separate API key per machine or cloud environment in the Console, in a workspace with a spend limit.
For Claude Code, allow `Bash(ask-api:*)` in `~/.claude/settings.json`; reading the key from the Keychain is otherwise blocked as credential access.
An `ASK_API_KEY` in the environment takes precedence over the Keychain item, and is the only source where there is no Keychain, as in a cloud session.
`ask-api` never reads `ANTHROPIC_API_KEY`, and always calls `api.anthropic.com` whatever `ANTHROPIC_BASE_URL` says, so a gateway never sees the key.
Each sent call is appended to `~/.local/state/ask-api/log.jsonl` with its model, tokens, cost and status, including calls that fail partway.
