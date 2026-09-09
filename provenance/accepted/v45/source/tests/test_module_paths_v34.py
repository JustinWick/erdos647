"""v34 module ownership and narrow overlay-rename regressions.

Filesystem/command doubles are test fixtures, never accepted Lean artifacts.
"""
from __future__ import annotations
import contextlib
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import shutil
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('v34_checks', ROOT / 'scripts/check.py')
check = importlib.util.module_from_spec(spec)
spec.loader.exec_module(check)


def digest(b):
    return hashlib.sha256(b).hexdigest()


class ModuleResolution(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.core = self.root/'core'
        self.research = self.root/'research'
        self.upstream = self.root/'pnt'
        for d in [self.core, self.research, self.upstream]:
            d.mkdir()

    def tearDown(self):
        self.tmp.cleanup()

    def obj(self, folder, module):
        p = folder.joinpath(*module.split('.')).with_suffix('.olean')
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text('TEST FIXTURE ONLY; not a Lean object')
        return p

    def test_reproduces_v33_first_root_collision(self):
        self.obj(self.core, 'Erdos647Sieve.FiniteCounting')
        self.obj(self.research, 'Erdos647Sieve.ReciprocalKernel')
        resolved = check.resolve_module_object('Erdos647Sieve.ReciprocalKernel',
                                               [self.core, self.research])
        self.assertEqual(resolved, self.core/'Erdos647Sieve/ReciprocalKernel.olean')
        self.assertFalse(resolved.exists())

    def test_separate_roots_work_with_core_first(self):
        a = self.obj(self.core, 'Erdos647Sieve.FiniteCounting')
        b = self.obj(self.research, 'Erdos647Research.ReciprocalKernel')
        for module, path in [('Erdos647Sieve.FiniteCounting', a),
                             ('Erdos647Research.ReciprocalKernel', b)]:
            self.assertEqual(check.resolve_module_object(module, [self.core, self.research]), path)

    def test_separate_roots_do_not_require_path_reordering(self):
        a = self.obj(self.core, 'Erdos647Sieve.FiniteCounting')
        b = self.obj(self.research, 'Erdos647Research.CleanMertens')
        for paths in [[self.core, self.research], [self.research, self.core]]:
            self.assertEqual(check.resolve_module_object('Erdos647Sieve.FiniteCounting', paths), a)
            self.assertEqual(check.resolve_module_object('Erdos647Research.CleanMertens', paths), b)

    def test_compat_root_cannot_shadow_upstream(self):
        a = self.obj(self.upstream, 'PrimeNumberTheoremAnd.IEANTN.RosserSchoenfeld.RosserSchoenfeldPrime')
        b = self.obj(self.research, 'Erdos647Research.Compat.PNTPlus')
        paths = [self.core, self.upstream, self.research]
        self.assertEqual(check.resolve_module_object('Erdos647Research.Compat.PNTPlus', paths), b)
        self.assertEqual(check.resolve_module_object('PrimeNumberTheoremAnd.IEANTN.RosserSchoenfeld.RosserSchoenfeldPrime', paths), a)

    def test_root_olean_also_selects_owner(self):
        self.obj(self.core, 'Erdos647Sieve')
        self.obj(self.research, 'Erdos647Sieve.SomeOtherModule')
        self.assertEqual(check.resolve_module_object('Erdos647Sieve.SomeOtherModule',
            [self.core, self.research]), self.core/'Erdos647Sieve/SomeOtherModule.olean')

    def test_unknown_root(self):
        self.assertIsNone(check.resolve_module_object('NoSuch.Root', [self.core, self.research]))

    def test_reject_path_traversal(self):
        for module in ['../secret', 'A..B', 'A/B', '']:
            with self.subTest(module=module), self.assertRaises(ValueError):
                check.resolve_module_object(module, [self.core])


class Relocation(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.old = 'research/Erdos647Sieve/Example.lean'
        self.new = 'research/Erdos647Research/Example.lean'
        self.original = b'import Mathlib\nnamespace Erdos647Sieve\nend Erdos647Sieve\n'
        self.replacement = self.original
        self.entry = {'old':self.old, 'new':self.new,
                      'old_sha256':digest(self.original), 'new_sha256':digest(self.replacement)}
        self.write(self.old, self.original)
        self.write(self.new, self.replacement)
        self.write('scripts/module_moves_v34.json', json.dumps({'moves':[self.entry]}).encode())

    def tearDown(self):
        self.tmp.cleanup()

    def write(self, path, content):
        p = self.root/path
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_bytes(content)
        return p

    def test_archives_only_recorded_original(self):
        out = check.retire_v33_module_paths(self.root)
        self.assertEqual(len(out), 1)
        self.assertFalse((self.root/self.old).exists())
        self.assertEqual((self.root/out[0]['archive']).read_bytes(), self.original)
        self.assertEqual((self.root/self.new).read_bytes(), self.replacement)

    def test_repeat_does_not_touch_new_source_or_archive(self):
        out = check.retire_v33_module_paths(self.root)
        new = self.root/self.new
        archive = self.root/out[0]['archive']
        times = (new.stat().st_mtime_ns, archive.stat().st_mtime_ns)
        self.assertEqual(check.retire_v33_module_paths(self.root), [])
        self.assertEqual(times, (new.stat().st_mtime_ns, archive.stat().st_mtime_ns))

    def test_future_edits_to_new_module_are_not_frozen_by_migration(self):
        check.retire_v33_module_paths(self.root)
        self.write(self.new, self.replacement + b'-- legitimate later development\n')
        self.assertEqual(check.retire_v33_module_paths(self.root), [])

    def test_edited_old_source_is_not_removed(self):
        self.write(self.old, self.original+b'-- local edit\n')
        with self.assertRaisesRegex(ValueError, 'Edited obsolete module'):
            check.retire_v33_module_paths(self.root)
        self.assertTrue((self.root/self.old).exists())

    def test_missing_new_source_preserves_old(self):
        (self.root/self.new).unlink()
        with self.assertRaisesRegex(ValueError, 'Replacement module'):
            check.retire_v33_module_paths(self.root)
        self.assertTrue((self.root/self.old).exists())

    def test_existing_correct_archive_is_idempotent(self):
        archive = 'provenance/refactors/v34/retired/'+self.old
        p = self.write(archive, self.original)
        timestamp = p.stat().st_mtime_ns
        check.retire_v33_module_paths(self.root)
        self.assertEqual(p.stat().st_mtime_ns, timestamp)

    def test_conflicting_archive_blocks_before_moving(self):
        self.write('provenance/refactors/v34/retired/'+self.old, b'conflict')
        with self.assertRaisesRegex(ValueError, 'Conflicting module provenance'):
            check.retire_v33_module_paths(self.root)
        self.assertTrue((self.root/self.old).exists())

    def test_symlinked_original_is_rejected(self):
        old = self.root/self.old
        old.unlink();old.symlink_to(self.root/self.new)
        with self.assertRaisesRegex(ValueError, 'Symlink'):
            check.retire_v33_module_paths(self.root)

    def test_symlinked_archive_parent_is_rejected(self):
        (self.root/'provenance').symlink_to(self.root/'research', target_is_directory=True)
        with self.assertRaisesRegex(ValueError, 'Symlink'):
            check.retire_v33_module_paths(self.root)

    def test_nonresearch_file_cannot_be_retired(self):
        entry = {**self.entry, 'old':'lakefile.lean'}
        self.write('scripts/module_moves_v34.json', json.dumps({'moves':[entry]}).encode())
        with self.assertRaisesRegex(ValueError, 'outside the v34'):
            check.retire_v33_module_paths(self.root)

    def test_unlisted_sources_and_caches_are_preserved(self):
        files = [self.write('research/Erdos647Sieve/Custom.lean', b'local code'),
                 self.write('.lake/build/cache', b'cache'),
                 self.write('research/.lake/build/cache', b'cache2'),
                 self.write('.tools/lean', b'tool'), self.write('results/old.zip', b'old')]
        before = [(p.read_bytes(), p.stat().st_mtime_ns) for p in files]
        check.retire_v33_module_paths(self.root)
        self.assertEqual(before, [(p.read_bytes(), p.stat().st_mtime_ns) for p in files])

    def test_all_conflicts_are_preflighted(self):
        other = {**self.entry, 'old':'research/Erdos647Sieve/Other.lean',
                 'new':'research/Erdos647Research/Other.lean'}
        self.write(other['old'], b'edited')
        self.write(other['new'], self.replacement)
        self.write('scripts/module_moves_v34.json', json.dumps({'moves':[self.entry, other]}).encode())
        with self.assertRaises(ValueError):
            check.retire_v33_module_paths(self.root)
        self.assertTrue((self.root/self.old).exists())


class PackageBoundaries(unittest.TestCase):
    def test_research_build_targets_have_distinct_module_root(self):
        for gate in check.GATES.values():
            if gate['package']=='research':
                self.assertTrue(all(s.startswith('+Erdos647Research.') for s in gate['build']))

    def test_old_source_roots_are_absent(self):
        for prefix in ['Erdos647Sieve','PrimeNumberTheoremAnd']:
            self.assertEqual(list((ROOT/'research'/prefix).rglob('*.lean')), [])

    def test_all_audit_theorem_names_stay_in_original_namespace(self):
        for gate in check.GATES.values():
            for names in gate['audits'].values():
                for name in names:
                    self.assertFalse(name.startswith('Erdos647Research.'))

    def test_only_compat_imports_upstream(self):
        direct = []
        for p in (ROOT/'research/Erdos647Research').rglob('*.lean'):
            if any(n.startswith('PrimeNumberTheoremAnd.') for n in check.imports(p.read_text())):
                direct.append(p.relative_to(ROOT).as_posix())
        self.assertEqual(direct, ['research/Erdos647Research/Compat/PNTPlus.lean'])

    def test_compat_module_uses_only_the_completed_pnt_entrypoint(self):
        p = ROOT/'research/Erdos647Research/Compat/PNTPlus.lean'
        self.assertEqual(check.imports(p.read_text()),
            ['Mathlib', 'PrimeNumberTheoremAnd.MediumPNT'])

    def test_numerical_and_theorem_audits_not_demoted(self):
        check.source_boundary(ROOT)
        self.assertEqual(len([name for name in check.GATES if not name.startswith('endpoint_') or name == 'endpoint_log_bounds']), 14)
        self.assertEqual(set(check.ALLOW), {'propext','Classical.choice','Quot.sound'})


class RuntimePathGuard(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        for p in check.source_files(ROOT):
            q = self.root/p.relative_to(ROOT)
            q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
        self.run = check.Run(self.root, check.parser().parse_args(['--gate','reciprocal_kernel']))
        self.paths = [self.root/'.lake/build/lib/lean', self.root/'research/.lake/build/lib/lean']
        self.run.record['search_paths']={'research':[str(p) for p in self.paths]}
        p = self.paths[1]/'Erdos647Research/ReciprocalKernel.olean'
        p.parent.mkdir(parents=True);p.write_text('PATH TEST ONLY; not Lean output')

    def tearDown(self):
        self.tmp.cleanup()

    def test_expected_module_owner_is_recorded(self):
        self.run.verify_gate_modules('reciprocal_kernel')
        rows=json.loads((self.run.dest/'module_resolution/reciprocal_kernel.json').read_text())
        self.assertEqual(len(rows),1)
        self.assertTrue(rows[0]['correct_owner'])
        self.assertTrue(rows[0]['object_exists'])

    def test_wrong_existing_owner_is_rejected(self):
        p=self.paths[0]/'Erdos647Research/ReciprocalKernel.olean'
        p.parent.mkdir(parents=True);p.write_text('wrong owner fixture')
        with self.assertRaisesRegex(ValueError,'ownership check failed'):
            self.run.verify_gate_modules('reciprocal_kernel')

    def test_correct_owner_but_missing_object_is_rejected(self):
        (self.paths[1]/'Erdos647Research/ReciprocalKernel.olean').unlink()
        with self.assertRaisesRegex(ValueError,'ownership check failed'):
            self.run.verify_gate_modules('reciprocal_kernel')

    def test_absent_search_path_cannot_be_reported_as_pass(self):
        self.run.record['search_paths']={}
        with self.assertRaisesRegex(ValueError,'No verified Lean search path'):
            self.run.verify_gate_modules('reciprocal_kernel')

    def test_path_guard_failure_prevents_axiom_command(self):
        self.run.lake='test-only-lake'
        with mock.patch.object(self.run,'command',return_value=(0,'')) as command, \
             mock.patch.object(self.run,'verify_gate_modules',side_effect=ValueError('wrong owner')), \
             contextlib.redirect_stdout(io.StringIO()):
            self.run.gate('reciprocal_kernel')
        self.assertEqual(command.call_count,1)
        self.assertEqual(self.run.record['gates']['reciprocal_kernel']['status'],'FAIL')


if __name__=='__main__':
    unittest.main()
