# Agent Config

This repository is the source of truth for personal agent configuration and
skills shared across projects and agent hosts. Project-specific instructions
and skills stay in the project that owns them.

## Layout

- `global/AGENTS.md` — shared personal defaults for coding agents across projects.
- `global/codex/AGENTS.md` — symlink to the shared defaults, preserving existing installs.
- `global/claude/CLAUDE.md` — imports the shared defaults, then adds Claude-only sections.
- `global/claude/statusline.sh` — Claude Code status line: location, model, effort, running
  agents, context, and the 5h/7d quota meters, which it also logs to `~/.claude/quota-probe.jsonl`.
- `skills/` — reusable skills shared by agent hosts.
- `scripts/` — repository maintenance helpers.
- Root `AGENTS.md` — instructions for maintaining this repository.

Each immediate child of `skills/` is one skill:

```text
skills/
  skill-name/
    SKILL.md
    agents/       optional host metadata
    scripts/      optional deterministic helpers
    references/   optional instructions loaded on demand
    assets/       optional output resources
```

The shared contract belongs in `SKILL.md`. Host-specific metadata may be
added alongside it, but do not maintain separate Claude and Codex copies of
the same instructions.

## Install shared global instructions

Clone this repository to a stable local directory:

```sh
git clone https://github.com/yan-h/agent-config.git ~/projects/agent-config
```

Back up any existing instruction files and merge their contents into the shared
source before replacing them. Link the shared file into each host you use,
and Claude's file, which imports it, into Claude:

```sh
mkdir -p ~/.codex ~/.claude ~/.gemini ~/.config/zed
ln -s ~/projects/agent-config/global/AGENTS.md ~/.codex/AGENTS.md
ln -s ~/projects/agent-config/global/claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -s ~/projects/agent-config/global/AGENTS.md ~/.gemini/GEMINI.md
ln -s ~/projects/agent-config/global/AGENTS.md ~/.config/zed/AGENTS.md
```

For Claude's status line, link the script and point `statusLine` in
`~/.claude/settings.json` at the link:

```sh
ln -s ~/projects/agent-config/global/claude/statusline.sh ~/.claude/statusline.sh
```

```json
"statusLine": { "type": "command", "command": "~/.claude/statusline.sh", "refreshInterval": 2 }
```

It needs `jq`; the optional `ant` CLI refreshes its context-window table.
`QUOTA_PROBE=0` turns off the quota log.

Use the actual checkout path if it differs from the example.
The import resolves relative to the linked file's real location, so it follows the checkout.
An older `~/.claude/CLAUDE.md` link straight to `global/AGENTS.md` still loads the shared
defaults but misses the Claude-only sections; re-link it with `ln -sfn`.
The Gemini path is also used by Antigravity.
An existing Codex link to `global/codex/AGENTS.md` still resolves to the shared source.
Start a new agent session to load the instructions.
These paths configure local coding agents, not ordinary web chats or cloud jobs.
Claude Cowork skips user instruction symlinks outside its working directory.

There is no universal global instruction path across agent hosts.
When adding another agent, connect its supported global rules mechanism to
`global/AGENTS.md`; do not assume it reads another host's configuration.
If a host requires settings-backed text instead of a file, keep the shared
source authoritative and refresh that setting when the source changes.

Edits through any link change the versioned file; commit and push them to
save them on GitHub. Other machines receive updates when you pull this repository.
Keep credentials, session history, caches, and private information out of
this public repository.

## Included skills

- `audit-merges` — inspect a combined merge range for defects that emerge
  only when otherwise-correct branches interact. Owner-invoked: a session
  never starts one for itself, and a host that can enforce that should.

## Add a skill

Add `skills/<skill-name>/SKILL.md`, then run:

```sh
python3 scripts/check.py
```

The checker validates every skill's required frontmatter, directory name,
and non-empty instructions.

## Make skills discoverable

For a personal installation, link each skill directory from this checkout
into both user catalogs:

```text
~/.claude/skills/<skill-name> -> <checkout>/skills/<skill-name>
~/.agents/skills/<skill-name> -> <checkout>/skills/<skill-name>
```

Link individual skills rather than the whole catalog so each host can also
keep tool-specific skills in its native directory.

For a repository-pinned installation, vendor this repository into the
consumer as `.shared-skills` using a Git subtree or submodule, then expose
the selected skills with internal relative links:

```text
.claude/skills/<skill-name> -> ../../.shared-skills/skills/<skill-name>
.agents/skills              -> ../.claude/skills
```

Internal relative links survive clones and worktrees. Do not check in links
to a sibling checkout outside the consumer repository.

## Scope rule

A skill belongs here when its behavior is shared. Exact package names,
build commands, artifact locations, and repository history normally belong
in the consuming project's `AGENTS.md`, `CLAUDE.md`, or local skill.
