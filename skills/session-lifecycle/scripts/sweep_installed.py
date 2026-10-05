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
    # An installed runtime may precede the project integration PR. Only a
    # repository that opted in with .agent-lifecycle.json is swept.
    if not (repo / '.agent-lifecycle.json').is_file():
        print('Waiting for project lifecycle integration: ' + str(repo), flush=True)
        continue
    result = subprocess.run([sys.executable, str(Path(__file__).with_name('lifecycle.py')),
                             '--repo', str(repo), 'sweep', '--apply'],
                            env={k: v for k, v in os.environ.items()
                                 if k != 'CLAUDE_PROJECT_DIR' and not k.startswith('GIT_')})
    failed |= result.returncode != 0
raise SystemExit(1 if failed else 0)
