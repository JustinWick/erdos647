"""v33 packaging regressions. Test doubles exercise the runner, never Lean proofs."""
from __future__ import annotations
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import sys
import tempfile
import unittest
from unittest import mock
import zipfile

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('v33_repository_checks', ROOT/'scripts/check.py')
check = importlib.util.module_from_spec(spec)
spec.loader.exec_module(check)


class ManifestRegression(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        for p in check.source_files(ROOT):
            target = self.root/p.relative_to(ROOT)
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(p, target)

    def tearDown(self):
        self.tmp.cleanup()

    def change_name(self, scope, value, local=False):
        p = self.root/scope/'lake-manifest.json'
        data = json.loads(p.read_text())
        if local:
            next(e for e in data['packages'] if e['type']=='path')['name'] = value
        else:
            data['name'] = value
        p.write_text(json.dumps(data))

    def test_all_three_serialized_names_are_escaped(self):
        core = json.loads((self.root/'lake-manifest.json').read_text())
        research = json.loads((self.root/'research/lake-manifest.json').read_text())
        self.assertEqual(core['name'], '«erdos647-sieve»')
        self.assertEqual(research['name'], '«erdos647-research»')
        self.assertEqual(next(e for e in research['packages'] if e['type']=='path')['name'], core['name'])
        check.source_boundary(self.root)

    def test_rejects_original_core_manifest_bug(self):
        self.change_name('.', 'erdos647-sieve')
        with self.assertRaisesRegex(ValueError, 'escaped Lean identifier'):
            check.source_boundary(self.root)

    def test_rejects_original_research_manifest_bug(self):
        self.change_name('research', 'erdos647-research')
        with self.assertRaisesRegex(ValueError, 'escaped Lean identifier'):
            check.source_boundary(self.root)

    def test_rejects_original_local_dependency_bug(self):
        self.change_name('research', 'erdos647-sieve', local=True)
        with self.assertRaisesRegex(ValueError, 'single local core'):
            check.source_boundary(self.root)

    def test_missing_manifest_name_is_rejected(self):
        p = self.root/'lake-manifest.json'
        data = json.loads(p.read_text()); del data['name']
        p.write_text(json.dumps(data))
        with self.assertRaisesRegex(ValueError, 'manifest package name'):
            check.source_boundary(self.root)

    def test_schema_program_uses_real_lake_loader(self):
        text = (ROOT/'scripts/check_manifests.lean').read_text()
        self.assertIn('import Lake.Load.Manifest', text)
        self.assertIn('Lake.Manifest.load', text)
        self.assertNotIn('Mathlib', text)
        self.assertNotIn('Erdos647Sieve', text)

    def test_actual_parser_runs_before_dependency_preparation(self):
        events = []
        def fake_compiler(run):
            run.lean = 'fake-lean'; run.lake = 'fake-lake'
        def fake_command(run, label, cmd, cwd=None, allow_failure=False):
            events.append(label)
            if label == 'manifest_schema':
                self.assertEqual(cmd[:2], ['fake-lean', '--run'])
                self.assertEqual(Path(cmd[2]).name, 'check_manifests.lean')
                self.assertEqual(cmd[3:], [str(self.root/'lake-manifest.json')])
            return 0, ''
        def fake_prepare(run, scope):
            events.append('prepare')
        def fake_gate(run, name):
            run.record['gates'][name] = {'status': 'PASS', 'test_double': True}
        with mock.patch.object(check, 'ROOT', self.root), \
             mock.patch.object(check.Run, 'compiler', fake_compiler), \
             mock.patch.object(check.Run, 'command', fake_command), \
             mock.patch.object(check.Run, 'prepare', fake_prepare), \
             mock.patch.object(check.Run, 'gate', fake_gate), \
             mock.patch.object(check.Run, 'verify_dependency'), \
             mock.patch.object(check.Run, 'finish'), \
             contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(check.main(['core']), 0)
        self.assertLess(events.index('manifest_schema'), events.index('prepare'))

    def test_parser_failure_stops_before_prepare(self):
        seen = []
        def fake_compiler(run):
            run.lean = 'fake-lean'; run.lake = 'fake-lake'
        def fake_command(run, label, cmd, cwd=None, allow_failure=False):
            seen.append(label)
            if label == 'manifest_schema':
                raise RuntimeError('manifest_schema: invalid Lean Name')
            return 0, ''
        with mock.patch.object(check, 'ROOT', self.root), \
             mock.patch.object(check.Run, 'compiler', fake_compiler), \
             mock.patch.object(check.Run, 'command', fake_command), \
             mock.patch.object(check.Run, 'prepare') as prepare, \
             mock.patch.object(check.Run, 'finish'), \
             contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(check.main(['core']), 2)
        prepare.assert_not_called()
        self.assertIn('manifest_schema', seen)


class SourceChangeRegression(unittest.TestCase):
    def test_ci_only_edit_does_not_mask_local_gate_results(self):
        record = {}
        check.check_source_changes(record, {'.github/workflows/ci.yml': 'before'}, {'.github/workflows/ci.yml': 'after'})
        self.assertEqual(record['source_changes']['.github/workflows/ci.yml']['role'], 'ci_metadata')
        self.assertIn('.github/workflows/ci.yml', record['warnings'][0])

    def test_proof_edit_remains_fatal(self):
        record = {}
        with self.assertRaisesRegex(ValueError, 'Erdos647Sieve/FiniteCounting.lean'):
            check.check_source_changes(record, {'Erdos647Sieve/FiniteCounting.lean': 'a'},
                                       {'Erdos647Sieve/FiniteCounting.lean': 'b'})

    def test_manifest_edit_remains_fatal(self):
        record = {}
        with self.assertRaisesRegex(ValueError, 'lake-manifest.json'):
            check.check_source_changes(record, {'lake-manifest.json': 'a'}, {'lake-manifest.json': 'b'})

    def test_runner_edit_remains_fatal(self):
        record = {}
        with self.assertRaisesRegex(ValueError, 'scripts/check.py'):
            check.check_source_changes(record, {'scripts/check.py': 'a'}, {'scripts/check.py': 'b'})

    def test_added_proof_or_removed_audit_is_fatal(self):
        for before, after in [({}, {'Erdos647Sieve/New.lean': 'a'}),
                              ({'Audit/Finite.lean': 'a'}, {})]:
            with self.subTest(before=before, after=after):
                with self.assertRaises(ValueError):
                    check.check_source_changes({}, before, after)

    def test_ci_script_not_treated_as_yaml_metadata(self):
        with self.assertRaises(ValueError):
            check.check_source_changes({}, {'.github/check.py': 'a'}, {'.github/check.py': 'b'})

    def test_both_error_paths_survive(self):
        record = {'package_errors': {'.': 'cache failed'}}
        with self.assertRaises(ValueError):
            check.check_source_changes(record,
                {'scripts/check.py': 'a', '.github/workflows/ci.yml': 'a'},
                {'scripts/check.py': 'b', '.github/workflows/ci.yml': 'b'})
        self.assertEqual(record['package_errors']['.'], 'cache failed')
        self.assertEqual(len(record['source_changes']), 2)


class CacheAndReportRegression(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.stdout = contextlib.redirect_stdout(io.StringIO())
        self.stdout.__enter__()
        self.run = check.Run(self.root, check.parser().parse_args(['core']))
        self.run.lean = 'fake-lean'; self.run.lake = 'fake-lake'
        self.run.prefix = self.root/'fake-sysroot'
        for scope in ['.', 'research']:
            path = self.root/scope/'lake-manifest.json'
            path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT/scope/'lake-manifest.json', path)
        self.sentinel = self.root/'.lake/packages/mathlib/.lake/build/lib/lean/Mathlib.olean'
        self.calls = []

    def tearDown(self):
        self.stdout.__exit__(None, None, None)
        self.tmp.cleanup()

    def command(self, label, cmd, cwd=None, allow_failure=False):
        self.calls.append(label)
        if label.startswith('mathlib_cache'):
            self.sentinel.parent.mkdir(parents=True, exist_ok=True)
            self.sentinel.write_text('test fixture, NOT a compiled Lean artifact')
            return 0, ''
        if label.startswith('search_path'):
            return 0, json.dumps([str((cwd/'.lake/build/lib/lean').resolve()),
                                  str((self.run.prefix/'lib/lean').resolve())])
        return 0, ''

    def prepare(self, scope='.'):
        with mock.patch.object(self.run, 'checkout') as checkout, \
             mock.patch.object(self.run, 'command', self.command):
            self.run.prepare(scope)
            self.assertTrue(checkout.called)

    def test_missing_cache_resumes_without_tool_or_git_setup(self):
        self.prepare()
        self.assertEqual(self.calls, ['mathlib_cache_core', 'search_path_core'])
        self.assertFalse(self.run.args.setup)
        self.assertEqual(self.run.record['cache_actions']['.'], 'resume_missing_pinned_cache')

    def test_existing_cache_is_not_redownloaded_or_rewritten(self):
        self.sentinel.parent.mkdir(parents=True)
        self.sentinel.write_text('sentinel')
        before = self.sentinel.stat().st_mtime_ns
        self.prepare()
        self.assertEqual(self.calls, ['search_path_core'])
        self.assertEqual(self.sentinel.stat().st_mtime_ns, before)
        self.assertEqual(self.run.record['cache_actions']['.'], 'reuse_existing')

    def test_second_run_does_not_redownload(self):
        self.prepare()
        self.calls.clear()
        self.prepare()
        self.assertEqual(self.calls, ['search_path_core'])

    def test_missing_cache_does_not_skip_revision_checks(self):
        with mock.patch.object(self.run, 'checkout', side_effect=ValueError('Wrong installed revision')), \
             mock.patch.object(self.run, 'command') as command:
            with self.assertRaisesRegex(ValueError, 'Wrong installed revision'):
                self.run.prepare('.')
        command.assert_not_called()

    def test_cache_command_failure_does_not_create_success_marker(self):
        def fail(label, *args, **kwargs):
            if label.startswith('mathlib_cache'): raise RuntimeError('cache command failed')
            return 0, ''
        with mock.patch.object(self.run, 'checkout'), mock.patch.object(self.run, 'command', fail):
            with self.assertRaisesRegex(RuntimeError, 'cache command failed'):
                self.run.prepare('.')
        self.assertFalse((self.root/'.lake/packages/mathlib/.lake/erdos647-cache-ready.json').exists())

    def test_successful_command_without_cache_artifact_is_rejected(self):
        with mock.patch.object(self.run, 'checkout'), mock.patch.object(self.run, 'command', return_value=(0, '')):
            with self.assertRaisesRegex(RuntimeError, 'without Mathlib.olean'):
                self.run.prepare('.')
        self.assertFalse((self.root/'.lake/packages/mathlib/.lake/erdos647-cache-ready.json').exists())

    def test_shared_research_cache_is_reused(self):
        self.prepare()
        link = self.root/'research/.lake/packages/mathlib'
        link.parent.mkdir(parents=True, exist_ok=True)
        link.symlink_to(self.root/'.lake/packages/mathlib', target_is_directory=True)
        self.calls.clear()
        self.prepare('research')
        self.assertEqual(self.calls, ['search_path_research'])

    def test_reports_setup_failure_and_metadata_change_together(self):
        self.run.record.update(status='FAIL_OR_BLOCKED',
            package_errors={'.': 'cache_core rejected name'},
            gates={'core': {'status': 'BLOCKED', 'reason': 'cache_core rejected name'}},
            warnings=['CI metadata changed: .github/workflows/ci.yml'])
        self.run.finish()
        text = (self.run.dest/'SUMMARY.md').read_text()
        self.assertIn('cache_core rejected name', text)
        self.assertIn('.github/workflows/ci.yml', text)
        archive = Path((self.root/'results/latest_result.txt').read_text().strip())
        with zipfile.ZipFile(archive) as z:
            self.assertRegex(archive.name,
                r'^erdos647_repo_v[0-9]+_results_[0-9]{8}T[0-9]{6}Z_[0-9a-f]{8}\.zip$')
            self.assertEqual(archive.name, self.run.id + '.zip')
            data = json.loads(z.read(self.run.id+'/summary.json'))
            self.assertEqual(data['gates']['core']['status'], 'BLOCKED')


if __name__ == '__main__':
    unittest.main()
