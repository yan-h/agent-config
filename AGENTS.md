# Agent configuration authoring contract

This repository contains personal agent defaults and skills shared across
projects and host tools.

- Put host-specific global defaults in `global/<host>/AGENTS.md`.
- Keep this root file focused on maintaining the repository; it is not the
  file installed as global user guidance.
- Keep credentials, session history, caches, and private information out of
  this public repository.

- Put one skill in each `skills/<name>/` directory, with `SKILL.md` as its
  required entrypoint.
- Keep the `name` short, lowercase, hyphenated, and identical to its folder.
- Write a concise `description` that says when the skill applies and avoids
  attracting unrelated work.
- Put behavior shared by Claude and Codex in `SKILL.md`. Keep optional host
  metadata supplemental; it must not become a second behavioral source of
  truth.
- Keep project-specific commands, paths, and policies in the project that
  owns them. If a shared workflow needs project details, tell the agent to
  read the local project contract rather than copying those details here.
- Add scripts or references only when they improve repeated execution or
  progressive disclosure.
- Run `python3 scripts/check.py` before committing.

Do not add example skills or placeholder resources. A new skill should begin
with a real repeated workflow and a description precise enough to route it.
