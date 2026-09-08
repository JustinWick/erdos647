"""Offline runner tests. Fake commands below test reporting, NEVER Lean proofs."""
from __future__ import annotations
import importlib.util
import contextlib
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest import mock
import zipfile

ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('repository_checks',ROOT/'scripts/check.py')
check=importlib.util.module_from_spec(spec);spec.loader.exec_module(check)


class Parsing(unittest.TestCase):
    def test_standard_axioms(self):
        self.assertEqual(check.parse_axioms("'T' depends on axioms:\n[propext, Classical.choice, Quot.sound]",'T'),sorted(check.ALLOW))
    def test_no_axioms(self):self.assertEqual(check.parse_axioms("'T' does not depend on any axioms",'T'),[])
    def test_multiline(self):self.assertEqual(check.parse_axioms("'T' depends on axioms:\n[\npropext\n]",'T'),['propext'])
    def test_missing(self):
        with self.assertRaises(ValueError):check.parse_axioms('everything passed','T')
    def test_duplicate(self):
        with self.assertRaises(ValueError):check.parse_axioms("'T' depends on axioms: []\n'T' depends on axioms: []",'T')
    def test_sorry(self):
        with self.assertRaises(ValueError):check.parse_axioms("'T' depends on axioms: [sorryAx]",'T')
    def test_custom(self):
        with self.assertRaises(ValueError):check.parse_axioms("'T' depends on axioms: [My.assumption]",'T')
    def test_native(self):
        with self.assertRaises(ValueError):check.parse_axioms("'T' depends on axioms: [Lean.ofReduceBool]",'T')
    def test_target_name_exact(self):
        with self.assertRaises(ValueError):check.parse_axioms("'Other.T' depends on axioms: []",'T')
    def test_comment_nesting(self):self.assertEqual(check.strip_comments('x /- y /- z -/ q -/ w'),'x  w')
    def test_line_comments(self):self.assertEqual(check.strip_comments('x -- sorry\ny'),'x \ny')
    def test_unclosed_comment(self):
        with self.assertRaises(ValueError):check.strip_comments('/- bad')
    def test_string_kept(self):self.assertIn('"x -- y"',check.strip_comments('"x -- y" -- gone'))
    def test_imports(self):self.assertEqual(check.imports('import A B\n/- import X -/\npublic import C'),['A','B','C'])
    def test_no_unsafe_local_source(self):check.source_boundary(ROOT)
    def test_candidate_is_checked_explicitly(self):
        text=(ROOT/'Audit/Finite.lean').read_text();self.assertIn('Candidate n ↔',text);self.assertIn('Iff.rfl',text)


class Layout(unittest.TestCase):
    def test_core_independent(self):
        lock=json.loads((ROOT/'lake-manifest.json').read_text());self.assertEqual(len(lock['packages']),9)
        self.assertNotIn('PrimeNumberTheoremAnd',{x['name'] for x in lock['packages']})
    def test_research_local_core(self):
        entries=json.loads((ROOT/'research/lake-manifest.json').read_text())['packages']
        self.assertEqual([(x['name'],x['dir']) for x in entries if x['type']=='path'],[('«erdos647-sieve»','..')])
    def test_same_mathlib_pins(self):
        self.assertEqual(check.PINS['dependencies']['.']['mathlib'],check.PINS['dependencies']['research']['mathlib'])
    def test_no_duplicate_math_source(self):
        a={p.name for p in (ROOT/'Erdos647Sieve').glob('*.lean')};b={p.name for p in (ROOT/'research/Erdos647Research').glob('*.lean')}
        self.assertFalse(a&b)
    def test_legacy_probe_archived(self):
        self.assertTrue((ROOT/'provenance/rejected/MertensProbe.lean.txt').is_file())
        self.assertFalse(any(p.name=='MertensProbe.lean' for p in check.source_files()))
    def test_no_absolute_local_dependency(self):
        for file in ['lake-manifest.json','research/lake-manifest.json']:
            for p in json.loads((ROOT/file).read_text())['packages']:
                if p['type']=='path':self.assertFalse(Path(p['dir']).is_absolute())
    def test_core_scope(self):self.assertEqual(check.selected_gates(check.parser().parse_args(['core'])),['core'])
    def test_all_scope_complete(self):self.assertEqual(set(check.selected_gates(check.parser().parse_args([]))),set(check.GATES))
    def test_research_no_core_gate(self):self.assertNotIn('core',check.selected_gates(check.parser().parse_args(['research'])))
    def test_selected_dependencies(self):
        selected=check.selected_gates(check.parser().parse_args(['--gate','corrected_budget_estimate']))
        self.assertLess(selected.index('prime_reciprocal_lower'),selected.index('small_prime_debit_estimate'))
        self.assertLess(selected.index('factorial_bounds'),selected.index('factorial_estimate'))
        self.assertEqual(selected[-1],'corrected_budget_estimate')
    def test_no_endpoint_success_gate(self):self.assertNotIn('endpoint',check.GATES)
    def test_no_source_mutation_commands(self):
        text=(ROOT/'scripts/check.py').read_text()
        self.assertNotIn('lake clean',text);self.assertNotIn('reset --hard',text);self.assertNotIn('rmtree(',text)
    def test_configured_lake_test(self):
        self.assertIn('testDriver := "audit"',(ROOT/'lakefile.lean').read_text())
        self.assertIn('testDriver := "audit"',(ROOT/'research/lakefile.lean').read_text())


class GuardFixtures(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name)
        for p in check.source_files():
            target=self.root/p.relative_to(ROOT);target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,target)
    def tearDown(self):self.tmp.cleanup()
    def test_spec_change(self):
        (self.root/'Erdos647Sieve/Specification.lean').write_text('-- changed')
        with self.assertRaises(ValueError):check.source_boundary(self.root)
    def test_core_cannot_import_pnt(self):
        (self.root/'Erdos647Sieve/Bad.lean').write_text('import PrimeNumberTheoremAnd.MediumPNT\n')
        with self.assertRaises(ValueError):check.source_boundary(self.root)
    def test_core_no_research_import(self):
        (self.root/'Erdos647Sieve/Bad.lean').write_text('import Erdos647Research.CleanMertens\n')
        with self.assertRaises(ValueError):check.source_boundary(self.root)
    def test_extra_axiom_source(self):
        (self.root/'Erdos647Sieve/Bad.lean').write_text('axiom bad : False\n')
        with self.assertRaises(ValueError):check.source_boundary(self.root)
    def test_unknown_research_file_not_silently_skipped(self):
        (self.root/'research/Erdos647Research/Unknown.lean').write_text('import Mathlib\n')
        with self.assertRaises(ValueError):check.source_boundary(self.root)
    def test_core_does_not_validate_research(self):
        (self.root/'research/Erdos647Research/Unknown.lean').write_text('axiom bad : False\n')
        check.source_boundary(self.root,include_research=False)
    def test_dependency_revision_drift(self):
        p=self.root/'lake-manifest.json';data=json.loads(p.read_text());data['packages'][0]['rev']='0'*40;p.write_text(json.dumps(data))
        with self.assertRaises(ValueError):check.source_boundary(self.root)
    def test_sorry_in_comment_not_rejected(self):
        p=self.root/'Erdos647Sieve/Bonferroni.lean';p.write_text(p.read_text()+'\n-- no sorry was inserted\n')
        check.source_boundary(self.root)
    def test_source_symlink_rejected(self):
        p=self.root/'Erdos647Sieve/Symlink.lean';p.symlink_to(self.root/'research/Erdos647Research/CleanMertens.lean')
        with self.assertRaises(ValueError):check.source_boundary(self.root)
    def test_diagnostics_exclude_caches_and_env(self):
        for name in ['.lake/deep/cache.lean','.tools/foo.py','results/prior/a.py','.env','research/.lake/fake.lean']:
            p=self.root/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_text('PRIVATE SENTINEL')
        names={p.relative_to(self.root).as_posix() for p in check.source_files(self.root)}
        self.assertNotIn('.env',names);self.assertFalse(any('.lake' in n or '.tools' in n or n.startswith('results/') for n in names))
    def test_lock_excludes_concurrent_run(self):
        with check.run_lock(self.root):
            with self.assertRaises(RuntimeError):
                with check.run_lock(self.root):pass
        with check.run_lock(self.root):pass


class Reporting(unittest.TestCase):
    def setUp(self):
        self.output=io.StringIO();self.redirect=contextlib.redirect_stdout(self.output);self.redirect.__enter__()
        self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name)
        self.run=check.Run(self.root,check.parser().parse_args(['tooling']))
        self.path_audit = mock.patch.object(self.run, 'verify_gate_modules')
        self.path_audit.start()
    def tearDown(self):
        self.path_audit.stop();self.tmp.cleanup();self.redirect.__exit__(None,None,None)
    def test_nonzero_is_failure_even_with_pass_text(self):
        with self.assertRaises(RuntimeError):
            self.run.command('fake_failure',[sys.executable,'-c','print("PASS"); raise SystemExit(5)'])
        self.assertEqual(self.run.record['commands'][-1]['exit_code'],5)
    def test_success_output_captured(self):
        rc,text=self.run.command('fake_success',[sys.executable,'-c','print("runner-test")'])
        self.assertEqual(rc,0);self.assertIn('runner-test',text)
    def test_missing_executable(self):
        with self.assertRaises(RuntimeError):self.run.command('missing',['/no/such/executable'])
        self.assertEqual(self.run.record['commands'][-1]['exit_code'],127)
    def test_failure_archive_created(self):
        self.run.record['status']='FAIL_OR_BLOCKED';self.run.finish()
        report=Path((self.root/'results/latest_result.txt').read_text().strip())
        with zipfile.ZipFile(report) as z:
            name=self.run.id+'/summary.json';self.assertEqual(json.loads(z.read(name))['status'],'FAIL_OR_BLOCKED')
    def test_unique_ids(self):
        second=check.Run(self.root,check.parser().parse_args(['tooling']));self.assertNotEqual(second.id,self.run.id)
    def test_old_success_not_reused(self):
        self.run.record['status']='PASS_SELECTED_CHECKS';self.run.save()
        second=check.Run(self.root,check.parser().parse_args(['tooling']));self.assertEqual(second.record['status'],'RUNNING')
    def test_redaction(self):
        text=str(self.root)+' https://person:secret@github.com/x ghp_SOMEFAKETOKEN1234'
        result=check.redact(text,self.root);self.assertNotIn('secret',result);self.assertNotIn('SOMEFAKETOKEN',result)
    def test_ambient_lean_paths_removed(self):
        with mock.patch.dict(os.environ,{'LEAN_PATH':'bad','LAKE_PACKAGES_DIR':'bad','LEAN_SYSROOT':'bad'}):
            env=check.clean_env()
        for k in ['LEAN_PATH','LAKE_PACKAGES_DIR','LEAN_SYSROOT']:self.assertNotIn(k,env)
    def test_gate_rejects_success_text_after_failed_command(self):
        self.run.lean='lean';self.run.lake='lake'
        with mock.patch.object(self.run,'command',side_effect=RuntimeError('exit 1 with stale PASS')):
            self.run.gate('core')
        self.assertEqual(self.run.record['gates']['core']['status'],'FAIL')
    def test_gate_rejects_missing_axiom_output(self):
        self.run.lean='lean';self.run.lake='lake'
        with mock.patch.object(self.run,'command',return_value=(0,'')):
            self.run.gate('core')
        self.assertEqual(self.run.record['gates']['core']['status'],'FAIL')
    def test_gate_accepts_only_requested_reports(self):
        self.run.lean='lean';self.run.lake='lake'
        reports=['']
        for targets in check.GATES['core']['audits'].values():
            reports.append('\n'.join("'"+name+"' depends on axioms: [propext]" for name in targets))
        with mock.patch.object(self.run,'command',side_effect=[(0,r) for r in reports]):
            self.run.gate('core')
        self.assertEqual(self.run.record['gates']['core']['status'],'PASS')
        self.assertEqual(len(self.run.record['gates']['core']['axioms']),sum(map(len,check.GATES['core']['audits'].values())))
    def test_repeated_gates_still_run_audits(self):
        self.run.lean='lean';self.run.lake='lake'
        reports=['']+['\n'.join("'"+n+"' depends on axioms: []" for n in ts) for ts in check.GATES['core']['audits'].values()]
        with mock.patch.object(self.run,'command',side_effect=[(0,r) for r in reports*2]) as command:
            self.run.gate('core');self.run.gate('core')
        self.assertEqual(command.call_count,len(reports)*2)
    def test_thread_limit_survives_lake_test_environment(self):
        with mock.patch.dict(os.environ,{'LEAN_NUM_THREADS':'2'}):self.assertEqual(check.clean_env()['LEAN_NUM_THREADS'],'2')
    def test_environment_does_not_repin_latest(self):self.assertEqual(check.clean_env()['ELAN_TOOLCHAIN'],'leanprover/lean4:v4.32.2')
    def test_signal_child_exit_fails(self):
        with self.assertRaises(RuntimeError):self.run.command('exit_code',[sys.executable,'-c','raise SystemExit(130)'])


class GitIgnore(unittest.TestCase):
    def test_generated_files_ignored_required_files_retained(self):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d);shutil.copy2(ROOT/'.gitignore',root/'.gitignore')
            subprocess.run(['git','init','-q',str(root)],check=True)
            def ignored(path):return subprocess.run(['git','-C',str(root),'check-ignore','-q','--no-index',path]).returncode==0
            for p in ['.lake/build/Foo.olean','research/.lake/packages/mathlib/Mathlib.lean','.tools/elan/bin/lean',
                      'results/run/summary.json','scripts/__pycache__/x.pyc','.env','.env.production','private.pem']:
                self.assertTrue(ignored(p),p)
            for p in ['lake-manifest.json','research/lake-manifest.json','lean-toolchain','RUN.sh',
                      'Audit/Finite.lean','Erdos647Sieve/FiniteCounting.lean','.github/workflows/ci.yml',
                      'provenance/accepted/v30_finite_axioms.log']:
                self.assertFalse(ignored(p),p)


if __name__=='__main__':unittest.main()
