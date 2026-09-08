"""Interfaces, dependency boundaries, and exact finite algebra for the error layer.
These tests do not replace Lean theorem checking.
"""
from fractions import Fraction as F
import importlib.util
import json
from math import factorial
from pathlib import Path
import re
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts'))
import check

NS = 'Erdos647Sieve.Endpoint.'
MODULES = {
    'endpoint_amplification': 'Amplification',
    'endpoint_moment_tail': 'MomentTail',
    'endpoint_error_scales': 'ErrorScales',
    'endpoint_arithmetic_remainder': 'ArithmeticRemainder',
    'endpoint_counting_reduction': 'CountingReduction',
}


def code(mod):
    return (ROOT / 'research/Erdos647Research/Endpoint' / (mod + '.lean')).read_text()


def audit(mod):
    return (ROOT / 'research/Audit' / ('Endpoint' + mod + '.lean')).read_text()


def header(mod, name):
    return code(mod).split('theorem ' + name, 1)[1].split(' := by', 1)[0]


def assert_amplified_acceptance(testcase, record):
    branch = record['amplified_error_branch']
    testcase.assertIn(branch['status'], {'source_implemented_acceptance_pending', 'accepted'})
    if branch['status'] != 'accepted':
        testcase.assertIsNone(branch['acceptance_evidence'])
        return
    evidence = ROOT / branch['acceptance_evidence']
    testcase.assertTrue(evidence.is_file())
    summary = json.loads((evidence.parent / 'summary.json').read_text())
    testcase.assertEqual(summary['run_id'], branch['run_id'])
    testcase.assertEqual(summary['status'], 'PASS_SELECTED_CHECKS')
    testcase.assertEqual(summary['source_sha256_before'], summary['source_sha256_after'])
    commands = {c['label']: c for c in summary['commands']}
    for gate, module in MODULES.items():
        testcase.assertEqual(summary['gates'][gate]['status'], 'PASS')
        testcase.assertIn(gate, summary['selected_gates'])
        for suffix in ['_build', '_audit_0']:
            command = commands[gate + suffix]
            testcase.assertEqual(command['exit_code'], 0)
            text = (evidence.parent / command['log']).read_text()
            testcase.assertRegex(text, r'EXIT_CODE=0\s*$')
            testcase.assertFalse(check.lean_warnings(text))
        targets = check.GATES[gate]['audits']['Audit/Endpoint' + module + '.lean']
        for target in targets:
            testcase.assertEqual(check.parse_axioms(text, target), summary['gates'][gate]['axioms'][target])


class ErrorInterfaces(unittest.TestCase):
    def test_all_25_theorems_have_exact_types_and_axiom_targets(self):
        total = 0
        for gate, mod in MODULES.items():
            names = [NS + n for n in re.findall(r'^theorem (\w+)', code(mod), re.M)]
            self.assertEqual(check.GATES[gate]['audits'], {'Audit/Endpoint' + mod + '.lean': names})
            self.assertEqual(re.findall(r'^#print axioms (\S+)', audit(mod), re.M), names)
            self.assertEqual(re.findall(r'^#check (\S+)', audit(mod), re.M), names)
            self.assertGreaterEqual(len(re.findall(r'^example :', audit(mod), re.M)), len(names))
            self.assertIn('set_option warningAsError true', audit(mod))
            total += len(names)
        self.assertEqual(total, 25)

    def test_all_31_expanded_statement_and_definition_checks_present(self):
        self.assertEqual(sum(len(re.findall(r'^example :', audit(m), re.M))
                             for m in MODULES.values()), 31)

    def test_weight_definitions_expand_to_the_actual_parameters(self):
        text = audit('Amplification')
        self.assertIn('endpointEta = fun X : ℕ => -Real.log (1 - momentT X)', text)
        self.assertIn('endpointMu = fun X : ℕ =>', text)
        self.assertIn('momentT X * primeMass (windowLength X) (primeCutoff X)', text)
        self.assertIn('(correctedBudget (windowLength X) : ℝ)', text)

    def test_no_parameter_redefinition_or_new_trust_shortcut(self):
        for mod in MODULES.values():
            text = check.strip_comments(code(mod))
            self.assertFalse(check.FORBIDDEN.search(text))
            self.assertNotRegex(text, r'\b(?:def|abbrev)\s+(?:momentT|primeCutoff|windowLength|endpointExponent)\b')
            self.assertNotIn('PrimeNumberTheoremAnd.', text)
            self.assertNotIn('RS_prime.', text)
            self.assertNotIn('Int.toNat', text)
            self.assertNotIn('Int.natAbs', text)
        check.source_boundary(ROOT)

    def test_nonnegative_budget_is_explicit_before_multiplication(self):
        for mod, name in [('Amplification', 'eventually_amplification_exponents_le'),
                          ('MomentTail', 'eventually_amplified_moment_tail_le'),
                          ('ArithmeticRemainder', 'eventually_amplified_arithmetic_remainder_le')]:
            self.assertIn('0 ≤ correctedBudget (windowLength X) →', header(mod, name))
        self.assertIn('(hB0 : 0 ≤ B)', header('Amplification', 'amplification_exponents_le'))

    def test_principal_coefficient_is_not_the_endpoint_coefficient(self):
        text = header('Amplification', 'eventually_principal_contribution_le')
        self.assertIn('(1499 / 1000000 : ℝ)', text)
        self.assertIn('(windowLength X : ℝ) / Real.log (Real.log (X : ℝ))', text)
        record = json.loads((ROOT / 'docs/endpoint-coefficient-status.json').read_text())
        self.assertIsNone(record['proved_coefficient'])
        self.assertIsNone(record['proved_endpoint_theorem'])
        self.assertFalse(record['historical_coefficient']['required'])
        self.assertFalse(record['coefficient_may_depend_on_X'])

    def test_tail_keeps_growing_mu_and_real_cast_factorial(self):
        text = audit('MomentTail')
        self.assertIn('(momentT X * primeMass (windowLength X) (primeCutoff X)) ^', text)
        self.assertIn('(Nat.factorial (truncationOrder X + 1) : ℝ)', text)
        self.assertIn('Elementary.factorial_pow_lower q', code('MomentTail'))
        self.assertNotIn('tendsto_factorial', code('MomentTail'))
        self.assertIn('Elementary.endpoint_tail_log_constant', code('MomentTail'))

    def test_arithmetic_remainder_keeps_full_multiplier(self):
        text = audit('ArithmeticRemainder')
        self.assertIn('Real.exp ((-Real.log (1 - momentT X)) *', text)
        self.assertIn('((windowLength X : ℝ) * primeCutoff X) ^ truncationOrder X', text)
        self.assertIn('Real.exp (Real.log (X : ℝ) / 2)', text)

    def test_cutoff_power_requires_positive_truncation(self):
        text = header('ErrorScales', 'primeCutoff_pow_truncation_eq')
        self.assertIn('(hJ : 0 < truncationOrder X)', text)
        self.assertIn('Real.rpow (X : ℝ) ((1 : ℝ) / 4)', text)

    def test_final_reduction_has_no_budget_sign_or_analytic_premise(self):
        text = header('CountingReduction', 'eventually_candidateCount_le_amplified_errors')
        self.assertIn('∀ᶠ X : ℕ in atTop', text)
        self.assertNotIn(' → ', text)
        self.assertNotIn('(h', text)
        self.assertNotIn('correctedBudget', text)
        self.assertIn('2 * Real.exp (Real.log (X : ℝ) / 2)', text)

    def test_final_reduction_really_handles_both_signs(self):
        text = code('CountingReduction')
        self.assertIn('candidateCount_le_window_of_negative_correctedBudget', text)
        self.assertIn('by_cases hB : 0 ≤ correctedBudget (windowLength X)', text)
        self.assertIn('finiteCounting X (windowLength X)', text)
        self.assertIn('amplified_momentBound_eq', text)

    def test_original_exponent_is_used_for_growth(self):
        text = code('ErrorScales')
        self.assertIn('windowLength_ratio_tendsto_one', text)
        self.assertIn('sub_pos.mpr endpointExponent_lt_one', text)
        self.assertIn('isLittleO_log_rpow_atTop', text)
        self.assertIn('window_mul_logLog_div_logX_tendsto_zero', text)

    def test_no_final_endpoint_declaration_is_promoted(self):
        for mod in MODULES.values():
            self.assertNotRegex(check.strip_comments(code(mod)), r'^theorem\s+(?:endpoint|positiveEndpoint)\b')
        record = json.loads((ROOT / 'docs/endpoint-coefficient-status.json').read_text())
        assert_amplified_acceptance(self, record)


class ErrorGateWorkflow(unittest.TestCase):
    def test_all_gates_includes_accepted_baseline_and_five_new_checks(self):
        selected = check.selected_gates(check.parser().parse_args([]))
        self.assertEqual(selected, list(check.GATES))
        self.assertGreaterEqual(len(selected), 26)
        self.assertTrue(set(MODULES).issubset(selected))

    def test_scale_checks_do_not_require_tail_or_pnt(self):
        selected = check.selected_gates(check.parser().parse_args(['--gate', 'endpoint_error_scales']))
        self.assertIn('endpoint_cutoff_parameters', selected)
        for name in ['endpoint_moment_tail', 'pntplus_inputs', 'endpoint_prime_mass_gap']:
            self.assertNotIn(name, selected)

    def test_tail_checks_do_not_require_arithmetic_remainder(self):
        selected = check.selected_gates(check.parser().parse_args(['--gate', 'endpoint_moment_tail']))
        self.assertIn('endpoint_amplification', selected)
        self.assertIn('factorial_bounds', selected)
        self.assertNotIn('endpoint_arithmetic_remainder', selected)

    def test_final_reduction_requires_both_error_routes(self):
        selected = check.selected_gates(check.parser().parse_args(['--gate', 'endpoint_counting_reduction']))
        for gate in MODULES:
            self.assertIn(gate, selected)
        self.assertEqual(selected[-1], 'endpoint_counting_reduction')

    def test_core_scope_remains_mathlib_only(self):
        self.assertEqual(check.selected_gates(check.parser().parse_args(['core'])), ['core'])
        self.assertNotIn('core', check.selected_gates(check.parser().parse_args(['research'])))
        for p in (ROOT / 'Erdos647Sieve').rglob('*.lean'):
            self.assertNotIn('Erdos647Research.', p.read_text())

    def test_lake_and_source_collection_include_new_files(self):
        cfg = (ROOT / 'research/lakefile.lean').read_text()
        files = {p.relative_to(ROOT).as_posix() for p in check.source_files(ROOT)}
        for mod in MODULES.values():
            self.assertIn('`Erdos647Research.Endpoint.' + mod, cfg)
            self.assertIn('research/Erdos647Research/Endpoint/' + mod + '.lean', files)
            self.assertIn('research/Audit/Endpoint' + mod + '.lean', files)

    def test_version_label_matches_current_status_record(self):
        record = json.loads((ROOT / 'docs/endpoint-coefficient-status.json').read_text())
        match = re.search(r"self\.id='erdos647_repo_(v[0-9]+)_results_'",
                          (ROOT / 'scripts/check.py').read_text())
        self.assertIsNotNone(match)
        self.assertEqual(match.group(1), record['version'])


class ExactErrorAlgebra(unittest.TestCase):
    def test_principal_and_amplification_bounds_in_rational_models(self):
        for H in [F(0), F(1), F(7, 3), F(100), F(10000)]:
            for L in [F(1, 500), F(1, 4), F(1), F(2), F(100)]:
                t = 1 / (1000 * L)
                for fraction in [F(0), F(1, 3), F(1)]:
                    B = fraction * H * L
                    for gap in [F(3, 2), F(2), F(10)]:
                        lam = B + gap * H
                        eta_upper = t + t*t
                        self.assertLessEqual(eta_upper * B, H / 500)
                        self.assertLessEqual(eta_upper * B - t*lam, -F(1499, 1000000) * H / L)
                        self.assertEqual(-t * (F(3, 2) * H) + t*t*H*L,
                                         -F(1499, 1000000) * H / L)

    def test_negative_budget_requires_a_different_argument(self):
        t = F(1, 1000)
        eta = t + t*t/2
        eta_upper = t + t*t
        B = F(-10)
        self.assertLessEqual(eta, eta_upper)
        self.assertGreater(eta*B, eta_upper*B)

    def test_uniform_tail_ratio_and_logarithmic_constant(self):
        log20_lower = 4 * F(693, 1000)
        self.assertGreaterEqual((log20_lower - 1)/50 - F(1, 500), F(1, 30))
        for h in range(0, 1001):
            H = F(h, 3)
            q = max(1, (h + 149)//150)
            self.assertGreaterEqual(F(q), H/50)
            mu = H/1000
            self.assertLessEqual(mu, F(q)/20)
            self.assertLessEqual(H/500 + (1-log20_lower)*q, -H/30)

    def test_exact_cutoff_exponent_for_positive_orders(self):
        for J in range(1, 1001):
            self.assertEqual(J*F(1, 4*J), F(1, 4))
        self.assertNotEqual(F(0), F(1, 4))

    def test_weighted_moment_decomposition(self):
        for X in [0, 1, 7, 100]:
            for q in range(1, 8):
                for mu in [F(0), F(1, 10), F(3)]:
                    for E, D in [(F(1, 3), F(2)), (F(7), F(9, 2))]:
                        principal_base = F(2, 7)
                        tail = mu**q / factorial(q)
                        self.assertEqual(E*(X*(principal_base+tail)+D),
                                         X*(E*principal_base) + X*(E*tail) + E*D)

    def test_complementary_ratio_cancellation(self):
        for P, R, H, L, J in [(F(2),F(3),F(1),F(4),F(5)),
                              (F(17,3),F(29,7),F(11,5),F(37),F(13,2))]:
            Q = P*R
            self.assertEqual((H/P)*(L/R), H*L/Q)
            self.assertEqual((J/H)*(F(2)/L)*(H*L/Q), J*2/Q)


if __name__ == '__main__':
    unittest.main()
