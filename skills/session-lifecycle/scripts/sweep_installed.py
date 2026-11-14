#!/usr/bin/env python3
"""Deterministic launchd entry point; no model or private app API involved."""
import json
import os
from pathlib import Path
import subprocess
import sys

config = Path.home() / '.config/agent-lifecycle/projects.json'
if not config.exists():
    raise SystemExit(0)
failed = False
for name in json.loads(config.read_text())['projects']:
    repo = Path(name)
    # A registration outlives a repository that was moved or deleted; that is
    # a stale entry to report, not a failed sweep every hour.
    if not (repo / '.git').exists():
        print('Registered project is not a git checkout any more: ' + str(repo), flush=True)
        continue
    # Registration is the opt-in. A repository without .agent-lifecycle.json
    # gets the worktree reclaimer alone; lifecycle.py's sweep needs no
    # configuration to run it.
    result = subprocess.run([sys.executable, str(Path(__file__).with_name('lifecycle.py')),
                             '--repo', str(repo), 'sweep', '--apply'],
                            env={k: v for k, v in os.environ.items()
                                 if k != 'CLAUDE_PROJECT_DIR' and not k.startswith('GIT_')})
    failed |= result.returncode != 0
raise SystemExit(1 if failed else 0)
