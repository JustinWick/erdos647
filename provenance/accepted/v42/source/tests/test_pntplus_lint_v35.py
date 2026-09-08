"""v35 source-closure/lint enforcement. Small fixtures are not Lean proof evidence."""
from __future__ import annotations
import contextlib
import importlib.util
import io
import json
from pathlib import Path
import shutil
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('v35_check', ROOT/'scripts/check.py')
check = importlib.util.module_from_spec(spec)
spec.loader.exec_module(check)
from pntplus_closure import code_only, inspect_closure, source_imports


class Lexer(unittest.TestCase):
    def test_nested_comments(self):
        src = 'theorem a : True := by trivial /- sorry /- admit -/ -/\n'
        out = code_only(src)
        self.assertNotIn('sorry', out)
        self.assertEqual(len(src), len(out))
        self.assertEqual(src.count('\n'), out.count('\n'))
    def test_strings_do_not_create_imports(self):
        self.assertEqual(source_imports(code_only('def t := "\\nimport Bad"\nimport Mathlib')), ['Mathlib'])
    def test_escaped_quotes(self):
        self.assertNotIn('sorry', code_only('def t := "escaped \\\" sorry"'))
    def test_unterminated_comment(self):
        with self.assertRaises(ValueError): code_only('/- unclosed')
    def test_unterminated_string(self):
        with self.assertRaises(ValueError): code_only('"unclosed')
    def test_module_import_syntax(self):
        self.assertEqual(source_imports(code_only('public import A B\nmeta import all C\n')), ['A','B','C'])
    def test_invalid_import_syntax_is_not_ignored(self):
        with self.assertRaises(ValueError): source_imports('import ../Bad')


class Closure(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.upstream = self.root/'upstream'
        self.compat = self.root/'PNTPlus.lean'
        self.compat.write_text('import Mathlib\nimport PrimeNumberTheoremAnd.MediumPNT\n')
        self.put('MediumPNT', 'import Mathlib\nimport PrimeNumberTheoremAnd.Helper\ntheorem p : True := by trivial\n')
        self.put('Helper','import Architect\ntheorem helper : True := by trivial\n')
    def tearDown(self): self.tmp.cleanup()
    def put(self, module, source):
        path=self.upstream/'PrimeNumberTheoremAnd'/Path(*module.split('.')).with_suffix('.lean')
        path.parent.mkdir(parents=True,exist_ok=True);path.write_text(source);return path
    def scan(self): return inspect_closure(self.upstream,self.compat)
    def test_full_transitive_sources_are_scanned(self):
        result=self.scan();self.assertEqual(result['status'],'SOURCE_CLOSURE_CLEAN')
        self.assertEqual(result['module_count'],2)
        self.assertIn('PrimeNumberTheoremAnd.Helper',result['modules'])
    def test_unused_admission_is_rejected(self):
        self.put('Helper','theorem unused : False := by sorry\n')
        result=self.scan();self.assertEqual(result['status'],'REJECTED')
        self.assertIn('sorry at line 1',' '.join(result['errors']))
    def test_other_shortcuts_are_rejected(self):
        for text in ['theorem bad : False := by admit', 'axiom bad : False',
                     'theorem bad : True := by native_decide',
                     'theorem bad : True := sorryAx _',
                     'set_option debug.skipKernelTC true in\ntheorem bad : True := by trivial']:
            with self.subTest(text=text):
                self.put('Helper',text)
                self.assertEqual(self.scan()['status'],'REJECTED')
    def test_missing_source_cannot_pass(self):
        (self.upstream/'PrimeNumberTheoremAnd/Helper.lean').unlink()
        self.assertEqual(self.scan()['status'],'REJECTED')
    def test_summary_cannot_be_reintroduced(self):
        self.put('Helper','import PrimeNumberTheoremAnd.IEANTN.ZetaSummary\n')
        self.put('IEANTN.ZetaSummary','theorem a : True := by trivial\n')
        self.assertEqual(self.scan()['status'],'REJECTED')
    def test_unused_catalogue_outside_closure_is_not_claimed_clean(self):
        self.put('IEANTN.ZetaSummary','theorem unused : False := sorry\n')
        result=self.scan();self.assertEqual(result['status'],'SOURCE_CLOSURE_CLEAN')
        self.assertNotIn('PrimeNumberTheoremAnd.IEANTN.ZetaSummary',result['modules'])
        self.assertIn('not the full',result['scope'])
    def test_leancert_interface_cannot_enter_closure(self):
        self.put('Helper','import LeanCert.CertifiedBounds.Li2\n')
        self.assertEqual(self.scan()['status'],'REJECTED')
    def test_compat_must_use_the_declared_root(self):
        self.compat.write_text('import PrimeNumberTheoremAnd.IEANTN.ZetaSummary\n')
        self.assertEqual(self.scan()['status'],'REJECTED')
    def test_empty_closure_cannot_pass(self):
        self.compat.write_text('import Mathlib\n')
        self.assertEqual(self.scan()['status'],'REJECTED')
    def test_cycles_terminate(self):
        self.put('Helper','import PrimeNumberTheoremAnd.MediumPNT\n')
        self.assertEqual(self.scan()['module_count'],2)
    def test_source_hashes_match_real_bytes(self):
        row=self.scan()['modules']['PrimeNumberTheoremAnd.Helper']
        self.assertEqual(row['sha256'],check.sha(self.upstream/row['path']))
    def test_sources_and_timestamps_are_not_modified(self):
        paths=[p for p in self.root.rglob('*') if p.is_file()]
        before=[(p.read_bytes(),p.stat().st_mtime_ns) for p in paths]
        self.scan();self.scan()
        self.assertEqual(before,[(p.read_bytes(),p.stat().st_mtime_ns) for p in paths])
    def test_symlinked_source_is_rejected(self):
        p=self.upstream/'PrimeNumberTheoremAnd/Helper.lean'
        p.unlink();p.symlink_to(self.compat)
        with self.assertRaises(ValueError): self.scan()


class LintAndGates(unittest.TestCase):
    def test_pnt_guard_precedes_the_adapter(self):
        names=check.selected_gates(check.parser().parse_args(['--gate','clean_mertens']))
        self.assertLess(names.index('pntplus_inputs'),names.index('analytic_inputs'))
    def test_prior_public_exact_audits_are_unchanged(self):
        targets=check.GATES['core']['audits']['Audit/Finite.lean']
        self.assertEqual(targets,['Erdos647Sieve.finiteMoment','Erdos647Sieve.budgetDebit','Erdos647Sieve.finiteCounting'])
    def test_all_extracted_inputs_receive_axiom_checks(self):
        self.assertEqual(len(check.GATES['pntplus_inputs']['audits']['Audit/PNTPlus.lean']),8)
    def test_both_required_inputs_have_expanded_type_checks(self):
        t=(ROOT/'research/Audit/PNTPlus.lean').read_text()
        self.assertIn(':= RS_prime.pnt',t)
        self.assertIn('RS_prime.integrableOn_deriv_inv_div_log',t)
        self.assertEqual(t.count('example :'),2)
    def test_local_libraries_treat_warnings_as_errors(self):
        for file in ['lakefile.lean','research/lakefile.lean']:
            text=(ROOT/file).read_text()
            self.assertEqual(text.count('lean_lib '),text.count('moreLeanArgs := #["-DwarningAsError=true"]'))
    def test_no_linter_is_disabled(self):
        for directory in ['Erdos647Sieve','research/Erdos647Research']:
            for p in (ROOT/directory).rglob('*.lean'):
                self.assertNotRegex(code_only(p.read_text()),r'set_option\s+linter\.\S+\s+false')
    def test_replayed_warning_is_still_failure(self):
        self.assertEqual(check.lean_warnings('⚠ Replayed M\nwarning: M.lean:3:2: unused\n'),['warning: M.lean:3:2: unused'])
    def test_direct_warning_format(self):
        self.assertEqual(len(check.lean_warnings('M.lean:2:0: warning: deprecated')),1)
    def test_info_not_confused_with_warning(self):
        self.assertEqual(check.lean_warnings('info: M.lean:1:0: #check result'),[])
    def test_repeated_warnings_deduplicated(self):
        self.assertEqual(len(check.lean_warnings('warning: X\nwarning: X')),1)
    def test_lint_failure_prevents_axiom_command(self):
        with tempfile.TemporaryDirectory() as tmp:
            run=check.Run(Path(tmp),check.parser().parse_args(['core']))
            run.lake='test-only-lake'
            with mock.patch.object(run,'command',return_value=(0,'warning: A.lean:1:0: unused')) as command, \
                 mock.patch.object(run,'verify_gate_modules'), contextlib.redirect_stdout(io.StringIO()):
                run.gate('core')
            self.assertEqual(run.record['gates']['core']['status'],'FAIL')
            self.assertEqual(command.call_count,1)
    def test_pnt_source_failure_prevents_build(self):
        with tempfile.TemporaryDirectory() as tmp:
            run=check.Run(Path(tmp),check.parser().parse_args(['--gate','pntplus_inputs']))
            run.lake='test-only-lake'
            with mock.patch.object(run,'check_pntplus_sources',side_effect=ValueError('admission')), \
                 mock.patch.object(run,'command') as command, contextlib.redirect_stdout(io.StringIO()):
                run.gate('pntplus_inputs')
            self.assertEqual(run.record['gates']['pntplus_inputs']['status'],'FAIL')
            command.assert_not_called()
    def test_small_prime_indices_are_explicit_naturals(self):
        t=(ROOT/'research/Erdos647Research/SmallPrimeDebitEstimate.lean').read_text()
        self.assertIn('(f := fun p : ℕ =>',t)
        self.assertIn('(g := fun p : ℕ =>',t)
        self.assertIn('(fun (p : ℕ) hp =>',t)
    def test_linter_suppression_is_rejected_as_a_shortcut(self):
        for directive in ['set_option linter.unusedTactic false',
                          'set_option warningAsError false', 'set_option linter.unusedSimpArgs false']:
            with self.subTest(directive=directive):
                self.assertIsNotNone(check.FORBIDDEN.search(directive))

    def test_unsafe_axiom_stays_rejected(self):
        for ax in ['sorryAx','Lean.trustCompiler','Fake.PNT']:
            with self.subTest(ax=ax), self.assertRaises(ValueError):
                check.parse_axioms("'T' depends on axioms: ["+ax+"]",'T')


if __name__=='__main__': unittest.main()
