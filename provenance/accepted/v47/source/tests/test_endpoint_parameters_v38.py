"""Endpoint branch registration and exact discrete-regression checks.

These tests validate interfaces and integer examples, not the Lean limit proofs.
"""
from __future__ import annotations

from fractions import Fraction
import importlib.util
import json
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('endpoint_check', ROOT/'scripts/check.py')
check = importlib.util.module_from_spec(spec)
spec.loader.exec_module(check)

MODULES = {
    'endpoint_statement': 'Statement',
    'endpoint_window_parameters': 'WindowParameters',
    'endpoint_truncation_parameters': 'TruncationParameters',
    'endpoint_cutoff_parameters': 'CutoffParameters',
    'endpoint_prime_mass_parameters': 'PrimeMassParameters',
}
BASE_GATES = {
    'core', 'reciprocal_kernel', 'reciprocal_abel', 'pntplus_inputs',
    'analytic_inputs', 'clean_mertens', 'selected_prime_reciprocals',
    'endpoint_log_bounds', 'factorial_bounds', 'factorial_estimate',
    'log_budget_factorial', 'prime_reciprocal_lower',
    'small_prime_debit_estimate', 'corrected_budget_estimate',
}


class EndpointRegistration(unittest.TestCase):
    def test_baseline_and_new_gates_are_both_present(self):
        self.assertLessEqual(BASE_GATES | set(MODULES), set(check.GATES))

    def test_every_new_theorem_gets_an_exact_type_and_axiom_audit(self):
        total = 0
        for gate, module in MODULES.items():
            with self.subTest(module=module):
                src=(ROOT/f'research/Erdos647Research/Endpoint/{module}.lean').read_text()
                names=['Erdos647Sieve.Endpoint.'+name for name in re.findall(r'^theorem (\w+)',src,re.M)]
                self.assertTrue(names)
                self.assertEqual(check.GATES[gate]['build'],['+Erdos647Research.Endpoint.'+module])
                audit, targets = next(iter(check.GATES[gate]['audits'].items()))
                text=(ROOT/'research'/audit).read_text()
                self.assertEqual(names, targets)
                self.assertEqual(re.findall(r'^#print axioms (\S+)$',text,re.M),names)
                self.assertEqual(len(re.findall(r'^example : ',text,re.M)),len(names)+(2 if module=='Statement' else 0))
                if module=='Statement':self.assertEqual(len(re.findall(r'^example \(c : ℝ\)',text,re.M)),1)
                self.assertIn('set_option warningAsError true',text)
                total += len(names)
        self.assertEqual(total,43)

    def test_source_boundaries_include_the_nested_modules(self):
        check.source_boundary(ROOT)

    def test_parameters_do_not_depend_on_pnt(self):
        for module in ['Statement','WindowParameters','TruncationParameters','CutoffParameters']:
            paths=check.imports((ROOT/f'research/Erdos647Research/Endpoint/{module}.lean').read_text())
            self.assertTrue(all(p=='Erdos647Sieve.Specification' or
                p.startswith('Erdos647Research.Endpoint.') or p.startswith('Mathlib') for p in paths))

    def test_prime_mass_uses_the_project_analytic_interface(self):
        text=(ROOT/'research/Erdos647Research/Endpoint/PrimeMassParameters.lean').read_text()
        self.assertEqual(check.imports(text),[
            'Erdos647Research.Endpoint.CutoffParameters',
            'Erdos647Research.SelectedPrimeReciprocals'])
        self.assertNotIn('RS_prime.',text)
        self.assertIn('Analytic.selectedPrimeSum_difference_tendsto_zero',text)

    def test_window_selection_does_not_rebuild_unrelated_analytic_gates(self):
        actual=check.selected_gates(check.parser().parse_args(['--gate','endpoint_window_parameters']))
        self.assertEqual(actual,['endpoint_window_parameters'])

    def test_cutoff_selection_has_only_its_parameter_prerequisites(self):
        actual=check.selected_gates(check.parser().parse_args(['--gate','endpoint_cutoff_parameters']))
        self.assertEqual(actual,['endpoint_window_parameters','endpoint_truncation_parameters','endpoint_cutoff_parameters'])

    def test_prime_mass_selection_includes_both_proof_chains(self):
        actual=check.selected_gates(check.parser().parse_args(['--gate','endpoint_prime_mass_parameters']))
        self.assertEqual(actual[-1],'endpoint_prime_mass_parameters')
        for name in ['endpoint_cutoff_parameters','clean_mertens','pntplus_inputs','selected_prime_reciprocals']:
            self.assertIn(name,actual)
        self.assertNotIn('corrected_budget_estimate',actual)
        self.assertNotIn('factorial_bounds',actual)

    def test_all_mode_still_checks_every_gate(self):
        self.assertEqual(set(check.selected_gates(check.parser().parse_args([]))),set(check.GATES))

    def test_no_parameter_redefinition_or_endpoint_placeholder(self):
        for p in (ROOT/'research/Erdos647Research/Endpoint').glob('*.lean'):
            code=check.strip_comments(p.read_text())
            self.assertFalse(re.search(r'\b(?:def|abbrev)\s+(?:windowLength|truncationOrder|primeCutoff|momentT|endpointExponent)\b',code))
            self.assertFalse(check.FORBIDDEN.search(code))
        self.assertNotIn('endpoint',check.GATES)
        main = ROOT/'research/Erdos647Research/Endpoint/Main.lean'
        self.assertEqual(main.exists(), 'endpoint_final' in check.GATES)
        if main.exists():
            self.assertEqual(check.GATES['endpoint_final']['build'],
                             ['+Erdos647Research.Endpoint.Main'])
            self.assertIn('eventually_candidateCount_le_amplified_errors', main.read_text())
            final_audit = (ROOT/'research/Audit/EndpointFinal.lean').read_text()
            self.assertIn('example : EndpointClaim :=', final_audit)
            self.assertIn('#print axioms Erdos647Sieve.endpoint', final_audit)

    def test_new_library_enforces_warnings_as_errors(self):
        cfg=(ROOT/'research/lakefile.lean').read_text()
        block=cfg.split('lean_lib Erdos647Endpoint where',1)[1].split('script audit',1)[0]
        self.assertIn('moreLeanArgs := #["-DwarningAsError=true"]',block)
        for module in MODULES.values():self.assertIn('`Erdos647Research.Endpoint.'+module,block)

    def test_final_mass_audit_has_no_free_cutoff_assumptions(self):
        text=(ROOT/'research/Audit/EndpointPrimeMassParameters.lean').read_text()
        for line in text.splitlines():
            if line.startswith('example :'):
                self.assertIn('(Tendsto (fun X : ℕ =>',line)
                self.assertNotIn(' → ',line)
        self.assertIn('Real.log ((25 : ℝ) / 2)',text)

    def test_parameter_sources_are_collected_in_diagnostics(self):
        files={p.relative_to(ROOT).as_posix() for p in check.source_files(ROOT)}
        for module in MODULES.values():
            self.assertIn(f'research/Erdos647Research/Endpoint/{module}.lean',files)
            self.assertIn(f'research/Audit/Endpoint{module}.lean',files)


class ExactRounding(unittest.TestCase):
    def test_all_small_windows(self):
        for H in range(10001):
            q=(H+99)//100
            ceiling=-((-H)//100)
            self.assertEqual(q,ceiling)
            J=2*q
            self.assertEqual(J%2,0)
            self.assertLessEqual(Fraction(H,50),J)
            self.assertLess(J,Fraction(H,50)+2)
            if H:self.assertGreater(J,0)

    def test_zero_multiples_and_both_sides_of_boundaries(self):
        for power in [0,1,2,8,32,128,512,2048]:
            for offset in [-1,0,1,99,100,101]:
                H=max(0,100*(10**power)+offset)
                q=(H+99)//100
                self.assertEqual(q,-((-H)//100))
                self.assertTrue(Fraction(H,50)<=2*q<Fraction(H,50)+2)
        self.assertEqual((0+99)//100,0)

    def test_unrounded_J_would_fail_the_checks(self):
        H=1
        self.assertNotEqual(Fraction(2*((H+99)//100)),Fraction(H,50))
        self.assertEqual(2*((H+99)//100),2)


class FixedCoefficientPolicy(unittest.TestCase):
    def test_statement_gate_is_independent(self):
        actual=check.selected_gates(check.parser().parse_args(['--gate','endpoint_statement']))
        self.assertEqual(actual,['endpoint_statement'])

    def test_positive_coefficient_precedes_onset_and_interval_length(self):
        audit=(ROOT/'research/Audit/EndpointStatement.lean').read_text()
        self.assertIn('∃ c : ℝ, 0 < c ∧ ∃ X0 : ℕ, 3 ≤ X0 ∧ ∀ X : ℕ',audit)
        self.assertNotIn('c : ℕ → ℝ',audit)
        self.assertIn('Real.log 2 / (1 + Real.log 2)',audit)
        self.assertIn('/ Real.log (Real.log (X : ℝ))',audit)

    def test_legacy_goal_is_preserved_not_required(self):
        source=(ROOT/'research/Erdos647Research/Endpoint/Statement.lean').read_text()
        self.assertIn('EndpointClaim ↔ EndpointBound ((1 : ℝ) / 1000)',source)
        self.assertIn('c ≤ d',source)
        self.assertIn('EndpointBound c',source)
        self.assertNotRegex(source,r'theorem\s+endpoint\s*:')
        self.assertNotRegex(source,r'theorem\s+positiveEndpoint\s*:')

    def test_no_unproved_coefficient_is_marked_accepted(self):
        status=json.loads((ROOT/'docs/endpoint-coefficient-status.json').read_text())
        self.assertFalse(status['historical_coefficient']['required'])
        self.assertFalse(status['coefficient_may_depend_on_X'])
        if status['proved_coefficient'] is not None:
            self.assertGreater(status['proved_coefficient']['numerator'],0)
            self.assertGreater(status['proved_coefficient']['denominator'],0)
            self.assertTrue(status['proved_endpoint_theorem'])
            self.assertTrue(status['endpoint_acceptance_evidence'])
        else:
            self.assertIsNone(status['proved_endpoint_theorem'])
            self.assertIsNone(status['endpoint_acceptance_evidence'])

    def test_no_corrupt_math_escapes_in_branch_documents(self):
        for rel in ['docs/endpoint-parameter-branch.md','docs/changes/v38.md',
                    'docs/proof-status.md','docs/pull-requests/endpoint-parameters.md']:
            raw=(ROOT/rel).read_bytes()
            self.assertFalse(any(b<32 and b not in (9,10) for b in raw),rel)

    def test_weakening_keeps_scale_and_coefficient_order(self):
        source=check.strip_comments((ROOT/'research/Erdos647Research/Endpoint/Statement.lean').read_text())
        self.assertIn('endpointRHSWith d X ≤ endpointRHSWith c X',source)
        self.assertIn('(hcd : c ≤ d)',source)
        self.assertIn('def endpointScale (X : ℕ)',source)
        self.assertIn('def EndpointBound (c : ℝ)',source)
        self.assertNotRegex(source,r'def\s+endpointExponent')


if __name__ == '__main__':
    unittest.main()
