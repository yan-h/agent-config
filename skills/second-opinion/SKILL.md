---
name: second-opinion
description: Ask Claude Fable (or another Claude model) over the Claude API for a design answer, second opinion or code review, billed to API credits rather than the subscription. Use when the owner asks for a Fable, API or second opinion or review; it spends money, so never on a session's own initiative.
---

# A second opinion over the API

`ask-api` sends one question, with the context you choose, to the Claude API and prints the answer.
It bills the API key's credits, which Claude Code itself cannot spend, so the call costs the owner's subscription nothing.
Each call costs real money, so run it only when the owner asks for one, and send the context the question needs rather than everything nearby.

```sh
ask-api "Is keying this cache on the whole config sound?" -f src/cache.rs -f src/draw.rs
ask-api --review                          # branch vs its merge base with main, plus every changed file
ask-api --review --diff "HEAD~3" "focus on the persistence change"
git log -p -5 -- src/take.rs | ask-api "What has this file's churn been fixing?"
```

`--model` takes `fable` (the default), `opus`, `sonnet` or `haiku`, each meaning the newest active model of that line, or a full model ID to pin one.
`--effort` defaults to `high`.
The project's `AGENTS.md` (or `CLAUDE.md`) and the owner's global preferences go in the system prompt; `--no-instructions` leaves them out.

## Choosing the context

The model sees only what you send: the question, the files named with `-f`, the diff, and piped input.
It cannot open a caller, a test or the place a value is built.
Before asking, read enough yourself to name the files the answer turns on, and add them:
for a cache, where its key and its inputs are built; for a new branch, the test meant to reach it.
A `--review` already includes every changed file in full.

## The cost guard

Before sending, `ask-api` counts the input tokens and prints the worst case: the input plus `--max-tokens` of output at the model's price.
Over `--max-cost` (default $3), or for a model with no known price, it stops with exit code 2.
Do not pass `--yes` unless the owner has agreed to that call's cost; narrow the context or ask instead.
`--dry-run` prints the estimate and the included context without sending.

A model newer than the price table borrows the newest known price of its line, and the estimate says so.
Tell the owner when that note appears, because the table wants a row for the new model.

## After the answer

Treat the answer as a lead, not a verdict.
Check each finding against the code before reporting it, and report which held, which did not and why, and the cost line `ask-api` printed.
Exit codes: 3 means the model declined, 4 means the answer was cut off at `--max-tokens`.

## What the credits pay for

The owner's API credits cover the API, the Batch API, the Agent SDK, the Playground and Managed Agents, not Claude Code:
Claude Code started with the key as `ANTHROPIC_API_KEY` fails with "credit balance too low", so do not route a session through it.
The balance is prepaid, so running out makes calls fail rather than charge, as long as auto-reload stays off under the Console's Billing settings.

## Setup

Once per machine:

```sh
python3 -m venv ~/.local/share/ask-api/venv
~/.local/share/ask-api/venv/bin/pip install anthropic
security add-generic-password -a "$USER" -s anthropic-api-key -w
ln -s ~/projects/agent-config/skills/second-opinion/scripts/ask-api ~/.local/bin/ask-api
ln -s ~/projects/agent-config/skills/second-opinion ~/.claude/skills/second-opinion
```

Create a separate API key per machine in the Console, in a workspace with a spend limit.
For Claude Code, allow `Bash(ask-api:*)` in `~/.claude/settings.json`; reading the key from the Keychain is otherwise blocked as credential access.
Each sent call is appended to `~/.local/state/ask-api/log.jsonl` with its model, tokens and cost.
