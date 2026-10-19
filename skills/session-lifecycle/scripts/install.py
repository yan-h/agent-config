#!/usr/bin/env python3
"""Install the shared skill and an hourly deterministic macOS fallback."""
import argparse
import json
import os
from pathlib import Path
import plistlib
import subprocess
import sys

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--repo', type=Path, action='append', default=[],
                    help='a project to sweep; a rerun keeps the projects already registered')
parser.add_argument('--no-launch', action='store_true', help='write installation without loading launchd')
args = parser.parse_args()
# The job runs sweep_installed.py, and through it lifecycle.py, under this
# interpreter; on 3.9 that fails every hour into a log nobody reads.
if sys.version_info < (3, 11):
    parser.error(f'needs Python 3.11+, and {sys.executable} is {sys.version.split()[0]}; '
                 'run it with a newer python3 (brew install python)')
if sys.platform != 'darwin' and not args.no_launch:
    parser.error('automatic scheduling currently supports macOS only')
skill = Path(__file__).resolve().parent.parent
home = Path.home()
for catalog in (home / '.agents/skills', home / '.claude/skills'):
    catalog.mkdir(parents=True, exist_ok=True)
    link = catalog / 'session-lifecycle'
    if link.exists() and not link.is_symlink():
        parser.error('refusing to replace existing directory: ' + str(link))
    if link.is_symlink():
        link.unlink()
    link.symlink_to(skill, target_is_directory=True)
config = home / '.config/agent-lifecycle/projects.json'
config.parent.mkdir(parents=True, exist_ok=True)
projects = set(json.loads(config.read_text())['projects']) if config.exists() else set()
for repo in args.repo:
    common = subprocess.check_output(['git', '-C', str(repo), 'worktree', 'list', '--porcelain'], text=True)
    main = next(line[9:] for line in common.splitlines() if line.startswith('worktree '))
    projects.add(str(Path(main).resolve()))
if not projects:
    parser.error('no project is registered for the sweep yet; pass --repo for each one')
config.write_text(json.dumps({'projects': sorted(projects)}, indent=2) + '\n')
log = home / 'Library/Logs/agent-lifecycle.log'
log.parent.mkdir(parents=True, exist_ok=True)
plist = home / 'Library/LaunchAgents/com.yan.agent-lifecycle.plist'
plist.parent.mkdir(parents=True, exist_ok=True)
label = 'com.yan.agent-lifecycle'
data = {'Label': label,
        'ProgramArguments': [sys.executable, str(skill / 'scripts/sweep_installed.py')],
        'StartInterval': 3600, 'RunAtLoad': True,
        'EnvironmentVariables': {'PATH': os.environ['PATH']},
        'StandardOutPath': str(log), 'StandardErrorPath': str(log)}
with plist.open('wb') as out:
    plistlib.dump(data, out)
if not args.no_launch:
    subprocess.run(['launchctl', 'bootout', f'gui/{os.getuid()}/{label}'], capture_output=True)
    subprocess.run(['launchctl', 'bootstrap', f'gui/{os.getuid()}', str(plist)], check=True)
print('Installed skill from: ' + str(skill))
print('Hourly project sweep: ' + ', '.join(sorted(projects)))
print('Log: ' + str(log))
print('Keep this source checkout until reinstalling from another revision.')
