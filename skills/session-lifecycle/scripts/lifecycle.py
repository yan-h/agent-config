#!/usr/bin/env python3
"""Publish small build handoffs and retire completed Cargo caches; stdlib only."""
from __future__ import annotations

import argparse
import contextlib
import fcntl
import hashlib
import json
import os
import tomllib
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time
import uuid


class Refused(RuntimeError):
    pass


def command(args, cwd=None, timeout=30):
    result = subprocess.run(args, cwd=cwd, text=True, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, timeout=timeout)
    if result.returncode:
        raise Refused(result.stderr.strip() or 'command failed: ' + str(args))
    return result.stdout.strip()


def git(repo, *args):
    return command(['git', '-C', str(repo), *args])


def identity(repo):
    repo = Path(git(repo, 'rev-parse', '--show-toplevel')).resolve()
    common = Path(git(repo, 'rev-parse', '--path-format=absolute', '--git-common-dir')).resolve()
    store = common / 'agent-lifecycle'
    if store.is_symlink():
        raise Refused('symlink lifecycle store: ' + str(store))
    return repo, store


def read_json(path):
    return json.loads(path.read_text())


def write_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(mode='w', dir=path.parent, delete=False) as out:
        json.dump(value, out, indent=2)
        out.write('\n')
        name = out.name
    os.replace(name, path)


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


def inside(root, relative):
    rel = Path(relative)
    if rel.is_absolute() or '..' in rel.parts or not rel.parts:
        raise Refused('unsafe relative path: ' + str(relative))
    path = root / rel
    current = root
    for part in rel.parts:
        current /= part
        if current.is_symlink():
            raise Refused('symlink in lifecycle path: ' + str(current))
    return path


@contextlib.contextmanager
def lock(path):
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.is_symlink():
        raise Refused('refusing symlink lock: ' + str(path))
    with path.open('a+') as stream:
        try:
            fcntl.flock(stream, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            raise Refused('busy: ' + str(path)) from None
        yield stream


def key(repo):
    return hashlib.sha256(str(repo).encode()).hexdigest()[:24]


def source(repo):
    if git(repo, 'status', '--porcelain', '--untracked-files=all'):
        raise Refused('uncommitted/untracked work; preserve the checkout and finish after committing')
    branch = git(repo, 'symbolic-ref', '--quiet', '--short', 'HEAD')
    return {'commit': git(repo, 'rev-parse', 'HEAD'), 'branch': branch}


def config(repo):
    data = read_json(repo / '.agent-lifecycle.json')
    for name in data['artifacts']:
        inside(repo, name)
    if not data['artifacts'] or not data['build'] or not all(isinstance(x, str) for x in data['build']):
        raise Refused('project needs artifacts and an argv build command')
    return data


def valid_handoff(directory):
    if directory.is_symlink():
        raise Refused('symlink handoff: ' + str(directory))
    m = read_json(directory / 'handoff.json')
    for name, expected in m['files'].items():
        path = inside(directory, name)
        if not path.is_file() or digest(path) != expected:
            raise Refused('handoff checksum mismatch: ' + str(path))
    return m


def publications(store):
    root = store / 'builds'
    if not root.exists():
        return []
    items = []
    for path in sorted(root.iterdir()):
        if path.name.startswith('.'):
            continue
        m = valid_handoff(path)
        items.append((path, m))
    return items


def publish(repo, store, cfg, state):
    root = store / 'builds'
    root.mkdir(parents=True, exist_ok=True)
    stage = Path(tempfile.mkdtemp(prefix='.publishing-', dir=root))
    try:
        files = {}
        for name in cfg['artifacts']:
            src = inside(repo, name)
            if not src.is_file():
                raise Refused('required build output missing: ' + str(src))
            dest = inside(stage, name)
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dest)
            files[name] = digest(dest)
        if source(repo) != state:
            raise Refused('source changed during build/publication')
        manifest = dict(state, created=time.time(), commit_time=int(git(repo, 'show', '-s', '--format=%ct', 'HEAD')), worktree=str(repo), files=files)
        write_json(stage / 'handoff.json', manifest)
        valid_handoff(stage)
        destination = root / (state['commit'][:12] + '-' + uuid.uuid4().hex[:12])
        stage.rename(destination)
        return destination, manifest
    finally:
        if stage.exists():
            shutil.rmtree(stage)


@contextlib.contextmanager
def cargo_locks(repo):
    # These projects pin Cargo 1.92, whose profile lock uses flock. Keep the
    # lock inode/profile directory intact so a waiting Cargo sees the same lock.
    target = inside(repo, 'target')
    with contextlib.ExitStack() as stack:
        for profile in ('debug', 'release'):
            directory = inside(target, profile)
            if directory.exists():
                stack.enter_context(lock(directory / '.cargo-lock'))
        yield


def trim(repo, cfg):
    validate_layout(repo, cfg)
    # Only conventional Cargo intermediates, never target/bundled, top-level
    # release deliverables, arbitrary ignored files, or custom target roots.
    if any(os.environ.get(name) for name in ('CARGO_TARGET_DIR', 'CARGO_BUILD_TARGET_DIR', 'CARGO_BUILD_BUILD_DIR', 'CARGO_BUILD_TARGET')):
        raise Refused('custom Cargo output directories are not supported')
    victims = []
    for profile in ('debug', 'release'):
        directory = inside(repo, 'target/' + profile)
        names = [p.name for p in directory.iterdir() if p.name != '.cargo-lock'] if profile == 'debug' and directory.exists() else ('deps', 'build', 'incremental', '.fingerprint', 'examples')
        for name in names:
            victim = inside(repo, 'target/' + profile + '/' + name)
            if victim.exists():
                victims.append(victim)
    # gitignored is not enough: refuse a target containing tracked output.
    if git(repo, 'ls-files', '--', 'target'):
        raise Refused('target contains tracked files')
    with cargo_locks(repo):
        for victim in victims:
            if victim.is_dir():
                shutil.rmtree(victim)
            else:
                victim.unlink()
    return len(victims)


def complete(repo, store, handoff, state):
    write_json(store / 'completed' / (key(repo) + '.json'),
               dict(state, worktree=str(repo), handoff=str(handoff) if handoff else None,
                    completed=time.time()))


def validate_layout(repo, cfg):
    if any(os.environ.get(name) for name in ('CARGO_TARGET_DIR', 'CARGO_BUILD_TARGET_DIR', 'CARGO_BUILD_BUILD_DIR', 'CARGO_BUILD_TARGET')):
        raise Refused('custom Cargo output directories are not supported')
    forbidden = ('--target', '--profile', '--target-dir', '--build-dir', '--config')
    if any(arg.split('=', 1)[0] in forbidden for arg in cfg['build']):
        raise Refused('custom Cargo output/profile arguments are not supported')
    directories = [directory / '.cargo' for directory in [repo, *repo.parents]]
    directories.append(Path(os.environ.get('CARGO_HOME', Path.home() / '.cargo')))
    for directory in directories:
        for name in ('config', 'config.toml'):
            path = directory / name
            if path.is_file():
                build = tomllib.loads(path.read_text()).get('build', {})
                if any(field in build for field in ('target-dir', 'build-dir', 'target')):
                    raise Refused('custom Cargo output configuration: ' + str(path))
    inside(repo, 'target')


def handoff(repo, store, keep_cache=False):
    cfg = config(repo)
    validate_layout(repo, cfg)
    state = source(repo)
    result = subprocess.run(cfg['build'], cwd=repo)
    if result.returncode:
        raise Refused('build failed; no handoff published and no cache removed')
    with lock(store / 'catalog.lock'), cargo_locks(repo):
        path, _ = publish(repo, store, cfg, state)
    print('Preserved build: ' + str(path), flush=True)
    if not keep_cache:
        count = trim(repo, cfg)
        complete(repo, store, path, state)
        print(f'Reclaimed {count} compilation directories; source and loadable binaries retained.')
    return path


def finish(repo, store, source_only=False):
    state = source(repo)
    with lock(store / 'catalog.lock'):
        matching = [(p, m) for p, m in publications(store)
                    if m['worktree'] == str(repo) and m['commit'] == state['commit']
                    and m['branch'] == state['branch']]
        if not matching and not source_only:
            raise Refused('no handoff for this commit; run handoff, or use --source-only for work needing no build')
        path = max(matching, key=lambda x: x[1]['created'])[0] if matching else None
        if (repo / '.agent-lifecycle.json').exists():
            trim(repo, config(repo))
        complete(repo, store, path, state)
    print('Local completion recorded. Source retained for review; release through the worktree owner once resolved.')


@contextlib.contextmanager
def catalog_lock(store):
    inherited = os.environ.get('AGENT_LIFECYCLE_CATALOG_FD')
    if inherited:
        fd = int(inherited)
        expected = (store / 'catalog.lock').stat()
        actual = os.fstat(fd)
        if (expected.st_dev, expected.st_ino) != (actual.st_dev, actual.st_ino):
            raise Refused('invalid inherited catalog lock')
        yield
    else:
        with lock(store / 'catalog.lock'):
            yield


def catalog(repo, store):
    with catalog_lock(store):
        latest = {}
        for path, m in publications(store):
            if m['branch'] not in latest or m['created'] > latest[m['branch']][1]['created']:
                latest[m['branch']] = (path, m)
        for branch, (path, m) in sorted(latest.items()):
            if any(c in str(path) + branch for c in '\t\r\n'):
                raise Refused('catalog fields contain tab/newline')
            print('\t'.join((str(path), branch, m['commit'], str(int(m['created'])))))


def registered(repo):
    return [Path(line[9:]).resolve() for line in git(repo, 'worktree', 'list', '--porcelain').splitlines()
            if line.startswith('worktree ')]


def resolved_heads(repo):
    # Network failure means retain publications; a budget is not permission to
    # discard a build awaiting review. Query by commit rather than branch name.
    # The limit is a ceiling on PR history, kept equal to GH_PR_LIMIT in
    # reclaim-worktrees.sh; an older PR is invisible and its build is retained.
    text = command(['gh', 'pr', 'list', '--state', 'all', '--limit', '3000',
                    '--json', 'state,headRefOid'], cwd=repo, timeout=45)
    return {p['headRefOid'] for p in json.loads(text) if p['state'] in ('MERGED', 'CLOSED')}


def retention(repo, store, budget, age_days, apply):
    with lock(store / 'catalog.lock'):
        items = publications(store)
        loaded = registered(repo)[0] / 'target/bundled/.loaded'
        selected = ''
        if loaded.is_file():
            selected = next((line.split('=', 1)[1] for line in loaded.read_text().splitlines()
                             if line.startswith('worktree=')), '')
        sizes = {p: sum(f.stat().st_size for f in p.rglob('*') if f.is_file()) for p, _ in items}
        total = sum(sizes.values())
        cutoff = time.time() - age_days * 86400
        if not items or (total <= budget and all(m['created'] >= cutoff for _, m in items)):
            return
        resolved = resolved_heads(repo)
        latest = {}
        for path, m in items:
            if m['branch'] not in latest or m['created'] > latest[m['branch']][1]['created']:
                latest[m['branch']] = (path, m)
        # Explicitly pinned comparisons survive both age and budget eviction.
        for path, m in sorted(items, key=lambda item: item[1]['created']):
            if str(path) == selected or (path / 'PIN').exists():
                continue
            superseded = latest[m['branch']][0] != path
            in_main = subprocess.run(['git', '-C', str(repo), 'merge-base', '--is-ancestor', m['commit'], 'main'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0
            if not superseded and m['commit'] not in resolved and not in_main:
                continue
            if total <= budget and m['created'] >= cutoff:
                continue
            print(('remove' if apply else 'would remove') + ' old resolved handoff ' + str(path))
            if apply:
                shutil.rmtree(path)
            total -= sizes[path]
        if total > budget:
            print(f'Protected handoffs exceed budget: {total} bytes retained, budget {budget}.')


def sweep(repo, store, apply, budget, age_days):
    paths = registered(repo)
    records = store / 'completed'
    if records.exists():
        for file in sorted(records.glob('*.json')):
            m = read_json(file)
            path = Path(m['worktree']).resolve()
            if path not in paths:
                continue
            try:
                with lock(store / 'locks' / (key(path) + '.lock')):
                    if source(path) != {'branch': m['branch'], 'commit': m['commit']}:
                        print('keep changed checkout: ' + str(path))
                        continue
                    if m['handoff']:
                        valid_handoff(Path(m['handoff']))
                    if apply and (path / '.agent-lifecycle.json').exists():
                        trim(path, config(path))
                    print('owner release pending: ' + str(path))
            except (Refused, OSError, ValueError) as err:
                print('keep ' + str(path) + ': ' + str(err))
    # The reclaimer ships beside this file, so the sweep and the rules it
    # applies always move together, and a configured repository needs no file
    # of its own for the sweep to reach it. It may remove resolved Claude
    # worktrees, but never Codex-managed worktrees.
    reclaimer = Path(__file__).with_name('reclaim-worktrees.sh')
    if (repo / '.agent-lifecycle.json').is_file() and reclaimer.is_file():
        env = dict(os.environ, RECLAIM_FORCE='1', RECLAIM_GH_TIMEOUT_S='30')
        env.pop('CLAUDE_PROJECT_DIR', None)
        env.pop('RECLAIM_DRY_RUN', None)
        if not apply:
            env['RECLAIM_DRY_RUN'] = '1'
        subprocess.run(['bash', str(reclaimer)], cwd=repo, env=env, input='', text=True, check=True)
    retention(repo, store, budget, age_days, apply)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', default='.')
    sub = parser.add_subparsers(dest='action', required=True)
    p = sub.add_parser('handoff', help='build, publish, then discard compilation caches')
    p.add_argument('--keep-cache', action='store_true')
    p = sub.add_parser('finish', help='finish a handoff or a source-only task')
    p.add_argument('--source-only', action='store_true')
    sub.add_parser('catalog', help='verified latest handoff per branch, TSV')
    p = sub.add_parser('run', help='hold the lifecycle lock across builds, tests, or seeding')
    p.add_argument('command', nargs=argparse.REMAINDER)
    p = sub.add_parser('load', help='hold the catalog lock throughout a loader invocation')
    p.add_argument('command', nargs=argparse.REMAINDER)
    p = sub.add_parser('prune-cache', help='reclaimer helper: safely prune an eligible debug/doc cache')
    p.add_argument('path', choices=('target/debug', 'target/doc'))
    p = sub.add_parser('sweep', help='reclaim completed work; dry run unless --apply')
    p.add_argument('--apply', action='store_true')
    p.add_argument('--budget-gib', type=float, default=5)
    p.add_argument('--age-days', type=int, default=14)
    args = parser.parse_args()
    repo, store = identity(args.repo)
    if args.action == 'load':
        cmd = args.command[1:] if args.command[:1] == ['--'] else args.command
        if not cmd:
            raise Refused('load requires a command')
        with lock(store / 'catalog.lock') as stream:
            env = dict(os.environ, AGENT_LIFECYCLE_CATALOG_FD=str(stream.fileno()))
            return subprocess.call(cmd, cwd=repo, env=env, pass_fds=(stream.fileno(),))
    elif args.action == 'catalog':
        catalog(repo, store)
    elif args.action == 'sweep':
        sweep(repo, store, args.apply, int(args.budget_gib * 1024**3), args.age_days)
    else:
        with lock(store / 'locks' / (key(repo) + '.lock')):
            if args.action in ('run', 'handoff'):
                (store / 'completed' / (key(repo) + '.json')).unlink(missing_ok=True)
            if args.action == 'run':
                cmd = args.command
                if cmd and cmd[0] == '--':
                    cmd = cmd[1:]
                if not cmd:
                    raise Refused('run requires a command')
                return subprocess.call(cmd, cwd=repo, env=dict(os.environ, AGENT_LIFECYCLE_ACTIVE=str(repo)))
            elif args.action == 'prune-cache':
                victim = inside(repo, args.path)
                if git(repo, 'ls-files', '--', args.path):
                    raise Refused('cache contains tracked files')
                with cargo_locks(repo):
                    if victim.exists():
                        for child in victim.iterdir():
                            if child.name == '.cargo-lock':
                                continue
                            if child.is_dir() and not child.is_symlink():
                                shutil.rmtree(child)
                            else:
                                child.unlink()
            elif args.action == 'handoff':
                handoff(repo, store, args.keep_cache)
            else:
                finish(repo, store, args.source_only)
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (Refused, OSError, ValueError, KeyError, subprocess.SubprocessError) as error:
        print('lifecycle: ' + str(error), file=sys.stderr)
        raise SystemExit(1)
