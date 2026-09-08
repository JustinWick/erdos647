"""Registration, trust-boundary, and exact-algebra regressions for the gap branch.

These tests check the source interfaces and finite algebra examples. The new
universal mathematical claims are checked by the two registered Lean audits.
"""
from __future__ import annotations

from fractions import Fraction as F
import importlib.util
import json
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('gap_check', ROOT/'scripts/check.py')
check = importlib.util.module_from_spec(spec)
spec.loader.exec_module(check)
NS = 'Erdos647Sieve.Endpoint.'
MODULES = {
    'endpoint_prime_mass_gap': 'PrimeMassGap',
    'endpoint_mass_budget_bounds': 'MassBudgetBounds',
}


def source(module):
    return (ROOT/f'research/Erdos647Research/Endpoint/{module}.lean').read_text()


def audit(module):
    return (ROOT/f'research/Audit/Endpoint{module}.lean').read_text()


def theorem_header(module, name):
    return source(module).split('theorem '+name, 1)[1].split(':=', 1)[0]


class GapInterfaces(unittest.TestCase):
    def test_new_gates_target_the_new_owned_modules(self):
        for gate, mod in MODULES.items():
            self.assertEqual(check.GATES[gate]['package'], 'research')
            self.assertEqual(check.GATES[gate]['build'], ['+Erdos647Research.Endpoint.'+mod])
            self.assertIn('acceptance pending', check.GATES[gate]['historical_status'])

    def test_every_new_theorem_has_an_expanded_type_check_and_axiom_target(self):
        total = 0
        for gate, mod in MODULES.items():
            names = [NS+n for n in re.findall(r'^theorem (\w+)', source(mod), re.M)]
            file, targets = next(iter(check.GATES[gate]['audits'].items()))
            self.assertEqual(file, f'Audit/Endpoint{mod}.lean')
            self.assertEqual(names, targets)
            self.assertEqual(re.findall(r'^#print axioms (\S+)', audit(mod), re.M), names)
            self.assertEqual(re.findall(r'^#check (\S+)', audit(mod), re.M), names)
            extra = 1 if mod == 'PrimeMassGap' else 0
            self.assertEqual(len(re.findall(r'^example :', audit(mod), re.M)), len(names)+extra)
            self.assertIn('set_option warningAsError true', audit(mod))
            total += len(names)
        self.assertEqual(total, 12)

    def test_general_margin_is_fixed_before_the_eventual_quantifier(self):
        text = audit('PrimeMassGap')
        self.assertIn('∀ δ : ℝ, δ < Real.log ((25 : ℝ) / 2)', text)
        self.assertNotIn('δ : ℕ → ℝ', text)
        self.assertIn('δ * (windowLength X : ℝ)', text)

    def test_fixed_gap_has_no_extra_mathematical_assumptions(self):
        text = theorem_header('PrimeMassGap', 'eventually_primeMass_sub_correctedBudget_ge')
        self.assertIn('∀ᶠ X : ℕ in atTop', text)
        self.assertIn('(3 / 2 : ℝ) * (windowLength X : ℝ)', text)
        self.assertNotIn(' → ', text)
        self.assertNotIn('(h', text)
        self.assertIn('(correctedBudget (windowLength X) : ℝ)', text)

    def test_budget_stays_signed_and_nonnegativity_is_not_assumed(self):
        for mod in MODULES.values():
            code = check.strip_comments(source(mod))
            self.assertNotIn('Int.toNat', code)
            self.assertNotIn('Int.natAbs', code)
            self.assertNotIn('0 ≤ correctedBudget', code)
            self.assertNotIn('0 ≤ (correctedBudget', code)

    def test_gap_limit_compares_budget_main_term_not_budget_itself(self):
        text = theorem_header('PrimeMassGap', 'endpoint_primeMass_budgetMain_gap_tendsto')
        self.assertNotIn('correctedBudget', text)
        self.assertIn('Real.log (Real.log (windowLength X : ℝ))', text)
        self.assertIn('1 / Real.log 2', text)

    def test_budget_estimate_is_composed_with_the_actual_window(self):
        text = source('PrimeMassGap')
        self.assertIn('windowLength_tendsto_atTop.eventually\n'
                      '      (Elementary.correctedBudget_upper_eventually ε hε)', text)
        self.assertIn('endpointExponent_cancellation', text)
        self.assertIn('log_windowLength_sub_tendsto_zero.div_const', text)

    def test_scale_limit_uses_the_actual_parameters_and_exponent(self):
        text = theorem_header('MassBudgetBounds', 'endpoint_primeMass_div_window_logLog_tendsto')
        self.assertIn('primeMass (windowLength X) (primeCutoff X)', text)
        self.assertIn('((windowLength X : ℝ) * Real.log (Real.log (X : ℝ)))', text)
        self.assertIn('𝓝 (1 - endpointExponent)', text)
        self.assertNotIn(' → ', text)

    def test_budget_size_is_derived_from_gap_and_mass_bound(self):
        text = source('MassBudgetBounds').split(
            'theorem eventually_correctedBudget_le_window_mul_logLog', 1)[1].split('/--', 1)[0]
        self.assertIn('eventually_correctedBudget_le_primeMass', text)
        self.assertIn('eventually_primeMass_le_window_mul_logLog', text)
        self.assertNotIn('correctedBudget_upper_eventually', text)

    def test_combined_bound_keeps_all_amplification_inputs(self):
        text = theorem_header('MassBudgetBounds', 'eventually_endpoint_mass_budget_bounds')
        self.assertIn('1 ≤ windowLength X ∧ 0 < Real.log (Real.log (X : ℝ))', text)
        self.assertIn('0 ≤ primeMass', text)
        self.assertIn('(3 / 2 : ℝ)', text)
        self.assertIn('(correctedBudget (windowLength X) : ℝ)', text)

    def test_reuses_public_logarithmic_limit(self):
        self.assertIn('Real.tendsto_pow_log_div_mul_add_atTop 1 0 1', source('MassBudgetBounds'))
        self.assertIn('log_windowLength_div_logLog_tendsto', source('MassBudgetBounds'))

    def test_no_upstream_import_or_new_trust_shortcut(self):
        for mod in MODULES.values():
            code = check.strip_comments(source(mod))
            self.assertFalse(check.FORBIDDEN.search(code))
            self.assertNotIn('PrimeNumberTheoremAnd.', code)
            self.assertNotIn('RS_prime.', code)
            self.assertNotIn('set_option maxHeartbeats 0', code)
        check.source_boundary(ROOT)

    def test_no_parameter_redefinitions_or_final_endpoint_claim(self):
        for mod in MODULES.values():
            code = check.strip_comments(source(mod))
            self.assertNotRegex(code, r'\b(?:def|abbrev)\s+(?:windowLength|primeCutoff|momentT|endpointExponent)\b')
            self.assertNotRegex(code, r'theorem\s+(?:endpoint|positiveEndpoint)\b')
        status = json.loads((ROOT/'docs/endpoint-coefficient-status.json').read_text())
        self.assertIsNone(status['proved_coefficient'])
        self.assertIsNone(status['proved_endpoint_theorem'])
        self.assertFalse(status['historical_coefficient']['required'])
        self.assertFalse(status['coefficient_may_depend_on_X'])


class GapGateWorkflow(unittest.TestCase):
    def test_gap_has_all_accepted_input_prerequisites(self):
        selected = check.selected_gates(check.parser().parse_args(['--gate', 'endpoint_prime_mass_gap']))
        self.assertEqual(selected[-1], 'endpoint_prime_mass_gap')
        for name in ['endpoint_prime_mass_parameters', 'corrected_budget_estimate',
                     'endpoint_log_bounds', 'clean_mertens', 'small_prime_debit_estimate']:
            self.assertIn(name, selected)
        self.assertNotIn('endpoint_mass_budget_bounds', selected)
        self.assertNotIn('endpoint_statement', selected)

    def test_size_gate_runs_the_gap_prerequisite(self):
        selected = check.selected_gates(check.parser().parse_args(['--gate', 'endpoint_mass_budget_bounds']))
        self.assertLess(selected.index('endpoint_prime_mass_gap'), selected.index('endpoint_mass_budget_bounds'))
        self.assertEqual(selected[-1], 'endpoint_mass_budget_bounds')

    def test_core_scope_stays_independent(self):
        selected = check.selected_gates(check.parser().parse_args(['core']))
        self.assertEqual(selected, ['core'])
        for p in (ROOT/'Erdos647Sieve').rglob('*.lean'):
            self.assertNotIn('Erdos647Research.', p.read_text())

    def test_all_scope_keeps_old_and_new_gates(self):
        selected = check.selected_gates(check.parser().parse_args([]))
        self.assertEqual(selected, list(check.GATES))
        self.assertIn('core', selected)
        self.assertIn('endpoint_mass_budget_bounds', selected)

    def test_lake_configuration_and_diagnostic_collection_include_new_sources(self):
        cfg = (ROOT/'research/lakefile.lean').read_text()
        block = cfg.split('lean_lib Erdos647Endpoint where', 1)[1].split('script audit', 1)[0]
        self.assertIn('moreLeanArgs := #["-DwarningAsError=true"]', block)
        files = {p.relative_to(ROOT).as_posix() for p in check.source_files(ROOT)}
        for mod in MODULES.values():
            self.assertIn('`Erdos647Research.Endpoint.'+mod, block)
            self.assertIn(f'research/Erdos647Research/Endpoint/{mod}.lean', files)
            self.assertIn(f'research/Audit/Endpoint{mod}.lean', files)

    def test_gap_is_not_confused_with_final_saving_coefficient(self):
        record = json.loads((ROOT/'docs/endpoint-coefficient-status.json').read_text())
        target = record['mass_budget_branch']
        self.assertEqual(target['status'], 'source_implemented_acceptance_pending')
        self.assertEqual(target['fixed_gap_target'], {'numerator': 3, 'denominator': 2})
        self.assertIsNone(target['acceptance_evidence'])
        self.assertIsNone(record['proved_coefficient'])


class ExactGapAlgebra(unittest.TestCase):
    def test_critical_exponent_cancellation_in_rational_models(self):
        for d in [F(1,10), F(1,2), F(7,10), F(1), F(5)]:
            a = d/(1+d)
            self.assertEqual(a/d, 1-a)

    def test_full_constant_cancellation(self):
        for d in [F(1,2), F(7,10), F(1)]:
            a = d/(1+d)
            for L in [F(-3), F(1), F(7), F(10**12)]:
                for LH in [F(-1), F(1), F(31,10)]:
                    for LLH in [F(-5), F(0), F(8)]:
                        for mass_over_H in [F(-3), F(0), F(97,7)]:
                            k = F(5,2)
                            K = k + 1/d - 2
                            r_mass = mass_over_H - ((1-a)*L-LLH+k)
                            r_window = LH-a*L
                            budget_main = LH/d-LLH+2-1/d
                            self.assertEqual(r_mass-r_window/d+K, mass_over_H-budget_main)

    def test_epsilon_gap_with_signed_budgets(self):
        negative_budget_cases = 0
        for K in [F(7,4), F(2), F(5)]:
            for delta in [F(-2), F(0), F(1), F(3,2)]:
                if delta >= K: continue
                eps = (K-delta)/2
                self.assertGreater(eps, 0)
                self.assertLess(delta+eps, K)
                for H in [F(1), F(7), F(10000)]:
                    for main in [F(-10), F(-1), F(0), F(100)]:
                        for excess in [eps/10, eps, F(10)]:
                            lam = H*(main+delta+eps+excess)
                            for slack in [F(0), eps/3, F(100)]:
                                budget = H*(main+eps-slack)
                                self.assertLessEqual(budget/H, main+eps)
                                self.assertGreater(lam/H-main, delta+eps)
                                self.assertGreater(lam-budget, delta*H)
                                negative_budget_cases += budget < 0
        self.assertGreater(negative_budget_cases, 0)

    def test_normalized_mass_reassembly(self):
        for H in [F(1), F(10), F(1000)]:
            for L in [F(1,3), F(1), F(10**9)]:
                for lam in [F(0), F(7), F(10000)]:
                    a, g, k = F(2,5), F(7,3), F(5,2)
                    residual = lam/H-((1-a)*L-g+k)
                    rebuilt = residual/L+(1-a)-g/L+k/L
                    self.assertEqual(rebuilt, lam/(H*L))

    def test_window_log_ratio_product_cancellation(self):
        for logH in [F(1,3), F(1), F(100)]:
            for L in [F(1,2), F(1), F(1000)]:
                for loglogH in [F(-2), F(0), F(7)]:
                    self.assertEqual((loglogH/logH)*(logH/L), loglogH/L)

    def test_mass_bound_and_positive_gap_imply_budget_bound(self):
        for H in [F(1), F(7), F(1000)]:
            for L in [F(1), F(3), F(100)]:
                for fraction in [F(0), F(1,4), F(1)]:
                    lam = fraction*H*L
                    for extra in [F(0), F(1), F(10000)]:
                        budget = lam-F(3,2)*H-extra
                        self.assertLessEqual(budget, lam)
                        self.assertLessEqual(budget, H*L)


if __name__ == '__main__':
    unittest.main()
