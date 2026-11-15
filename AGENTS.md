# Agent configuration authoring contract

This repository contains personal agent defaults and skills shared across
projects and host tools.

- Put shared global defaults in `global/AGENTS.md` and link each host's
  supported global instruction file to that source.
- Put host-specific global defaults in `global/<host>/` only when needed;
  do not duplicate shared guidance there. Claude's file is
  `global/claude/CLAUDE.md`: it imports the shared file with `@../AGENTS.md`
  and adds Claude-only sections below the import. Claude's status line is
  `global/claude/statusline.sh`, linked from `~/.claude/statusline.sh`.
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
- Make every sentence change what an agent does. State each rule once, in
  the broadest file it applies to, and refer to it elsewhere instead of
  restating it. A rule an agent might otherwise simplify away keeps one
  reason clause, in a skill as in the global files; its counts and further
  anecdotes stay in the pull request that measured them. Cut narration, hedges, restated rules, summaries of
  other skills, and history that no longer changes behaviour.
- Run `python3 scripts/check.py` before committing.
- Keep each Markdown file under `global/` and `skills/` within its word
  ceiling in `scripts/word-ceilings.txt`, so the rules grow only as far as
  the owner approves: they went from about 6,200 words to 27,300 in six
  weeks, mostly procedure written from one run. A change that needs more
  room cuts as many words as it adds, or raises the number in the same diff
  for the owner to approve; a new file needs a new line, and a ceiling a
  file has shrunk below is lowered to its size.

## Stakes record

- **Use:** Yan alone, on one Mac and in Claude Code cloud sessions. The
  skills are written for Claude Code and Codex; the global file is also
  linked for Gemini CLI and Antigravity.
- **Load:** several sessions and subagents at once on the one Mac, each in
  its own worktree, across a few projects.
- **Severe:** the session-lifecycle scripts or the worktree reclaimer
  deleting unmerged work or a build not yet loaded; a hook or installed
  setting that breaks every session; a skill that merges, or edits or
  closes an issue, without the owner's own word.
- **Cheap:** a sentence in a skill that misleads one session; an install
  that fails and says so.
- **Unprotected:** a session-start pull that hangs delays that session until
  the host's hook timeout; a failed pull is ignored (#108).
- **Unsupported case:** a script that already detects one refuses with a
  message and a nonzero exit.
  `install.sh --cloud` alone always exits 0, since a failing setup would
  stop a cloud session from starting.

Do not add example skills or placeholder resources. A new skill should begin
with a real repeated workflow and a description precise enough to route it.
