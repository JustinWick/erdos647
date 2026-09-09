"""Regression for unused names in explicitly quantified exact-type audit examples.

This checks a narrow source pattern and type-text preservation. It is not a Lean
parser, a complete linter, or a substitute for the normal Lean audit commands.
"""
from __future__ import annotations

import contextlib
import hashlib
import io
import json
from pathlib import Path
import re
import sys
import tempfile
import unittest
from unittest import mock
import zipfile

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts'))
import check
from promotion_history import assert_endpoint_evidence
from test_amplified_errors_v44 import assert_amplified_acceptance

FIXTURE = json.loads((ROOT / 'tests/fixtures/v44_error_audit_interfaces.json').read_text())
ENTRIES = FIXTURE['entries']


def example_types(text: str) -> list[str]:
    """Our audit files deliberately use `example : TYPE := PROOF`."""
    return re.findall(r'^example\s*:\s*(.*?)\s*:=', check.strip_comments(text), re.M | re.S)


def normalized_type(text: str) -> str:
    text = re.sub(r'\((h\w*)\s*:', '(_ :', text)
    return re.sub(r'\s+', ' ', text).strip()


def unused_hypothesis_names(text: str) -> list[tuple[int, str]]:
    """Detect unused h-prefixed binder names in this audit's forall type style."""
    findings = []
    for index, typ in enumerate(example_types(text), 1):
        for name in re.findall(r'\((h\w*)\s*:', typ):
            if len(re.findall(r'\b' + re.escape(name) + r'\b', typ)) == 1:
                findings.append((index, name))
    return findings


class BinderPatternRegression(unittest.TestCase):
    def test_original_pattern_is_detected(self):
        text = 'example : ∀ (t : ℝ) (ht0 : 0 ≤ t) (ht : t ≤ 1 / 2), t ≤ 1 := T\n'
        self.assertEqual(unused_hypothesis_names(text), [(1, 'ht0'), (1, 'ht')])

    def test_anonymous_hypotheses_are_retained_and_not_flagged(self):
        old = 'example : ∀ (t : ℝ) (ht0 : 0 ≤ t), t ≤ t := T\n'
        new = 'example : ∀ (t : ℝ) (_ : 0 ≤ t), t ≤ t := T\n'
        self.assertEqual(normalized_type(example_types(old)[0]),
                         normalized_type(example_types(new)[0]))
        self.assertEqual(unused_hypothesis_names(new), [])

    def test_used_dependent_proof_name_is_not_flagged(self):
        text = 'example : ∀ (h : P), dependentConclusion h := T\n'
        self.assertEqual(unused_hypothesis_names(text), [])

    def test_comments_do_not_count_as_references(self):
        text = 'example : ∀ (h : P), Q /- h is mentioned only in a comment -/ := T\n'
        self.assertEqual(unused_hypothesis_names(text), [(1, 'h')])

    def test_all_five_error_audits_avoid_the_failing_pattern(self):
        for name in ENTRIES:
            with self.subTest(file=name):
                self.assertEqual(unused_hypothesis_names((ROOT / name).read_text()), [])

    def test_all_31_expanded_types_preserved_modulo_unused_names(self):
        count = 0
        for name, expected in ENTRIES.items():
            types = example_types((ROOT / name).read_text())
            with self.subTest(file=name):
                actual = [hashlib.sha256(normalized_type(t).encode()).hexdigest() for t in types]
                self.assertEqual(actual, expected['type_sha256'])
            count += len(types)
        self.assertEqual(count, 31)

    def test_all_25_named_and_axiom_targets_preserved(self):
        count = 0
        for name, expected in ENTRIES.items():
            text = (ROOT / name).read_text()
            with self.subTest(file=name):
                self.assertEqual(re.findall(r'^#check (\S+)', text, re.M), expected['checks'])
                self.assertEqual(re.findall(r'^#print axioms (\S+)', text, re.M), expected['axioms'])
            count += len(expected['axioms'])
        self.assertEqual(count, 25)

    def test_no_linter_or_warning_suppression(self):
        for name in ENTRIES:
            text = check.strip_comments((ROOT / name).read_text())
            self.assertIn('set_option warningAsError true', text)
            self.assertIn('set_option autoImplicit false', text)
            self.assertNotRegex(text, r'set_option\s+linter\..*\s+false')
            self.assertFalse(check.FORBIDDEN.search(text))

    def test_four_files_and_twenty_two_names_in_record(self):
        self.assertEqual(sum(e['anonymized_hypothesis_binders'] for e in ENTRIES.values()), 22)
        self.assertEqual(sum(e['anonymized_hypothesis_binders'] > 0 for e in ENTRIES.values()), 4)

    def test_deleting_a_hypothesis_is_not_a_permitted_rename(self):
        before = '∀ (t : ℝ) (h : 0 ≤ t), t ≤ t'
        self.assertNotEqual(normalized_type(before), normalized_type('∀ (t : ℝ), t ≤ t'))

    def test_changing_a_numerical_bound_is_not_a_permitted_rename(self):
        before = '∀ (t : ℝ) (h : t ≤ 1 / 2), t ≤ t'
        after = '∀ (t : ℝ) (_ : t ≤ 1 / 3), t ≤ t'
        self.assertNotEqual(normalized_type(before), normalized_type(after))

    def test_failing_audit_cannot_be_promoted_by_printed_clean_axioms(self):
        # Simulate the exact v44 failure shape: build succeeds; audit prints every
        # allowed report but exits 1. This is a runner test, never proof evidence.
        gate = 'endpoint_amplification'
        targets = next(iter(check.GATES[gate]['audits'].values()))
        reports = '\n'.join("'" + target + "' depends on axioms: [propext, Classical.choice, Quot.sound]"
                            for target in targets)
        with tempfile.TemporaryDirectory() as directory, contextlib.redirect_stdout(io.StringIO()):
            root = Path(directory)
            run = check.Run(root, check.parser().parse_args(['tooling']))
            run.lake = 'unused-fixture-lake'
            original_command = run.command

            def fixture_command(label, command, cwd=None, allow_failure=False):
                if label.endswith('_build'):
                    return 0, 'simulated successful module build'
                return original_command(label, [sys.executable, '-c',
                    'print(' + repr(reports) + '); raise SystemExit(1)'], root)

            with mock.patch.object(run, 'verify_gate_modules'), \
                    mock.patch.object(run, 'command', side_effect=fixture_command):
                run.gate(gate)
            self.assertEqual(run.record['gates'][gate]['status'], 'FAIL')
            self.assertEqual(run.record['gates'][gate]['axioms'], {})
            self.assertEqual(run.record['commands'][-1]['exit_code'], 1)

    def test_fixture_is_collected_for_reproducible_source_tests(self):
        names = {p.relative_to(ROOT).as_posix() for p in check.source_files(ROOT)}
        self.assertIn('tests/fixtures/v44_error_audit_interfaces.json', names)
        self.assertIn('tests/test_audit_binders_v45.py', names)

    def test_endpoint_acceptance_is_backed_by_its_own_final_audit(self):
        record = json.loads((ROOT / 'docs/endpoint-coefficient-status.json').read_text())
        assert_amplified_acceptance(self, record)
        assert_endpoint_evidence(self, ROOT, record)
        self.assertEqual(record['final_absorption_branch']['status'], 'accepted')

    def test_actual_archive_names_and_latest_pointer_match(self):
        version = json.loads((ROOT / 'docs/endpoint-coefficient-status.json').read_text())['version']
        with tempfile.TemporaryDirectory() as directory, contextlib.redirect_stdout(io.StringIO()):
            root = Path(directory)
            for name in ENTRIES:
                target = root / name
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes((ROOT / name).read_bytes())
            run = check.Run(root, check.parser().parse_args(['tooling']))
            run.record['status'] = 'TOOLING_FIXTURE_NOT_LEAN'
            run.finish()
            archive = run.dest.with_suffix('.zip')
            self.assertTrue(archive.name.startswith('erdos647_repo_' + version + '_results_'))
            self.assertEqual(Path((root / 'results/latest_result.txt').read_text().strip()), archive)
            with zipfile.ZipFile(archive) as z:
                self.assertTrue(all(n.startswith(run.id + '/') for n in z.namelist()))
                summary = json.loads(z.read(run.id + '/summary.json'))
                self.assertEqual(summary['run_id'], run.id)
                for name in ENTRIES:
                    self.assertEqual(z.read(run.id + '/source/' + name), (ROOT / name).read_bytes())
