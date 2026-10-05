#!/usr/bin/env python3
"""Integration checks with disposable repositories; no user's worktree is pruned."""
import fcntl
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

TOOL = Path(__file__).with_name('lifecycle.py')
spec = importlib.util.spec_from_file_location('lifecycle', TOOL)
lc = importlib.util.module_from_spec(spec)
spec.loader.exec_module(lc)


class LifecycleTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.repo = Path(self.tmp.name) / 'repo'
        self.repo.mkdir()
        self.git('init', '-q', '-b', 'main')
        self.git('config', 'user.name', 'Fixture')
        self.git('config', 'user.email', 'fixture@example.test')
        (self.repo / '.gitignore').write_text('target/\n')
        (self.repo / 'build.py').write_text("from pathlib import Path\np=Path('target/release'); p.mkdir(parents=True,exist_ok=True)\n(p/'plugin').write_text('plugin')\n(p/'renderer').write_text('renderer')\n")
        (self.repo / '.agent-lifecycle.json').write_text(json.dumps({
            'build': [sys.executable, 'build.py'],
            'artifacts': ['target/release/plugin', 'target/release/renderer']}))
        self.git('add', '.')
        self.git('commit', '-qm', 'fixture')
        self.repo, self.store = lc.identity(self.repo)

    def git(self, *args):
        return lc.git(self.repo, *args)

    def run_tool(self, *args, ok=True, env=None):
        result = subprocess.run([sys.executable, str(TOOL), '--repo', str(self.repo), *args],
                                text=True, capture_output=True, env=env)
        if ok:
            self.assertEqual(result.returncode, 0, result.stderr + result.stdout)
        else:
            self.assertNotEqual(result.returncode, 0)
        return result

    def cache(self):
        path = self.repo / 'target/release/deps/cache'
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text('cache')
        return path

    def test_publication_survives_removed_worktree_and_failed_replacement(self):
        wt = Path(self.tmp.name) / 'worktree'
        self.git('worktree', 'add', '-qb', 'feature', str(wt))
        self.repo = wt.resolve()
        self.run_tool('handoff')
        first = lc.publications(self.store)[0][0]
        self.assertEqual((first / 'target/release/renderer').read_text(), 'renderer')
        # A failure after one required file copied must not publish a partial pair.
        (self.repo / 'target/release/renderer').unlink()
        with lc.lock(self.store / 'catalog.lock'):
            with self.assertRaises(lc.Refused):
                lc.publish(self.repo, self.store, lc.config(self.repo), lc.source(self.repo))
        self.assertEqual(len(lc.publications(self.store)), 1)
        main = Path(self.tmp.name) / 'repo'
        lc.git(main, 'worktree', 'remove', str(wt))
        self.repo = main
        self.assertIn(str(first), self.run_tool('catalog').stdout)
        self.assertEqual(lc.valid_handoff(first)['branch'], 'feature')

    def test_busy_build_and_cargo_profile_lock_keep_caches(self):
        path = self.cache()
        with lc.lock(self.store / 'locks' / (lc.key(self.repo) + '.lock')):
            self.assertIn('busy', self.run_tool('finish', '--source-only', ok=False).stderr)
        with lc.lock(self.repo / 'target/release/.cargo-lock'):
            self.assertIn('busy', self.run_tool('finish', '--source-only', ok=False).stderr)
        self.assertTrue(path.exists())
        self.run_tool('finish', '--source-only')
        self.assertFalse(path.exists())
        self.assertTrue((self.repo / 'target/release/.cargo-lock').exists())

    def test_custom_output_and_symlink_refused_before_publication(self):
        cache = self.cache()
        for variable in ('CARGO_TARGET_DIR', 'CARGO_BUILD_TARGET_DIR', 'CARGO_BUILD_BUILD_DIR', 'CARGO_BUILD_TARGET'):
            env = dict(os.environ, **{variable: str(Path(self.tmp.name) / 'elsewhere')})
            self.run_tool('handoff', ok=False, env=env)
        self.assertEqual(lc.publications(self.store), [])
        self.assertTrue(cache.exists())
        custom = Path(self.tmp.name) / 'custom-cargo'
        custom.mkdir()
        (custom / 'config.toml').write_text('[build]\ntarget-dir = "elsewhere"\n')
        self.run_tool('handoff', ok=False, env=dict(os.environ, CARGO_HOME=str(custom)))
        self.assertEqual(lc.publications(self.store), [])
        outside = Path(self.tmp.name) / 'valuable'
        outside.mkdir()
        (outside / 'precious').write_text('keep')
        cache.unlink()
        cache.parent.rmdir()
        cache.parent.symlink_to(outside, target_is_directory=True)
        self.run_tool('finish', '--source-only', ok=False)
        self.assertTrue((outside / 'precious').exists())

    def test_dirty_source_and_failed_build_preserve_previous_handoff(self):
        self.run_tool('handoff')
        previous = lc.publications(self.store)
        (self.repo / 'uncommitted').write_text('work')
        self.run_tool('handoff', ok=False)
        (self.repo / 'uncommitted').unlink()
        (self.repo / 'build.py').write_text('raise SystemExit(1)\n')
        self.git('add', 'build.py')
        self.git('commit', '-qm', 'failing build')
        cache = self.cache()
        self.run_tool('handoff', ok=False)
        self.assertTrue(cache.exists())
        self.assertEqual(lc.publications(self.store), previous)

    def test_budget_evicts_superseded_but_protects_selected_and_unresolved(self):
        self.git('checkout', '-qb', 'feature')
        self.git('commit', '--allow-empty', '-qm', 'feature')
        self.run_tool('handoff')
        first = lc.publications(self.store)[0][0]
        self.run_tool('handoff')
        second = max(lc.publications(self.store), key=lambda x: x[1]['created'])[0]
        (self.repo / 'target/bundled').mkdir()
        selected = self.repo / 'target/bundled/.loaded'
        selected.write_text('worktree=' + str(first) + '\n')
        with patch.object(lc, 'resolved_heads', return_value=set()):
            lc.retention(self.repo, self.store, 0, 14, True)
        self.assertTrue(first.exists())
        self.assertTrue(second.exists())
        selected.unlink()
        with patch.object(lc, 'resolved_heads', return_value=set()):
            lc.retention(self.repo, self.store, 0, 14, True)
        self.assertFalse(first.exists())
        self.assertTrue(second.exists())

    def test_sweep_runs_the_shipped_reclaimer_only_for_configured_repos(self):
        # Intercept only the reclaimer call; git and everything else run for real.
        reclaimer = str(TOOL.with_name('reclaim-worktrees.sh'))
        real_run, calls = subprocess.run, []

        def run(args, *rest, **kwargs):
            if list(args[:2]) == ['bash', reclaimer]:
                calls.append(kwargs)
                return subprocess.CompletedProcess(args, 0)
            return real_run(args, *rest, **kwargs)

        with patch.object(lc.subprocess, 'run', side_effect=run):
            lc.sweep(self.repo, self.store, False, 5 << 30, 14)
            self.assertEqual(len(calls), 1)
            env = calls[0]['env']
            self.assertEqual((env['RECLAIM_FORCE'], env['RECLAIM_DRY_RUN']), ('1', '1'))
            self.assertNotIn('CLAUDE_PROJECT_DIR', env)
            self.assertEqual(Path(calls[0]['cwd']), self.repo)
            (self.repo / '.agent-lifecycle.json').unlink()
            lc.sweep(self.repo, self.store, True, 5 << 30, 14)
            self.assertEqual(len(calls), 1)

    def test_loader_holds_catalog_lock_through_child_and_checksums(self):
        self.run_tool('handoff')
        self.run_tool('load', '--', sys.executable, str(TOOL), '--repo', str(self.repo), 'catalog')
        first = lc.publications(self.store)[0][0]
        with lc.lock(self.store / 'catalog.lock'):
            self.run_tool('catalog', ok=False)
        (first / 'target/release/plugin').write_text('changed')
        self.assertIn('checksum', self.run_tool('catalog', ok=False).stderr)


if __name__ == '__main__':
    unittest.main()
