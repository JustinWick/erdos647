"""Regression checks for the explicit-power adapter and unchanged endpoint policy.

These check source interfaces and audit registration, not the analytic limit proofs.
"""
from pathlib import Path
from promotion_history import assert_endpoint_evidence
import json
import unittest

ROOT = Path(__file__).resolve().parents[1]
ENDPOINT = ROOT / 'research/Erdos647Research/Endpoint'


def declaration_body(module: str, name: str) -> str:
    text = (ENDPOINT / (module + '.lean')).read_text()
    return text.split('theorem ' + name, 1)[1].split('\n/--', 1)[0]


class ExplicitPowerAdapter(unittest.TestCase):
    def test_adapter_normalizes_before_applying_log_rules(self):
        body = declaration_body('WindowParameters', 'log_div_rpow_eq')
        self.assertIn('Real.log (u / Real.rpow v r) = Real.log u - r * Real.log v', body)
        self.assertIn('(hu : u ≠ 0) (hv : 0 < v)', body)
        self.assertLess(body.index('Real.rpow_eq_pow'), body.index('Real.log_div'))
        self.assertLess(body.index('Real.log_div'), body.index('Real.log_rpow'))

    def test_both_logarithmic_difference_proofs_reuse_adapter(self):
        for module, theorem in [
            ('WindowParameters', 'log_windowLength_sub_tendsto_zero'),
            ('CutoffParameters', 'loglog_primeCutoff_sub_tendsto'),
        ]:
            with self.subTest(module=module):
                body = declaration_body(module, theorem)
                self.assertIn('exact log_div_rpow_eq ', body)
                self.assertNotIn('rw [Real.log_div', body)

    def test_direct_cutoff_log_normalizes_explicit_power(self):
        body = declaration_body('CutoffParameters', 'log_primeCutoff (')
        self.assertIn('rw [Real.rpow_eq_pow, Real.log_rpow', body)

    def test_complementary_product_normalizes_before_addition_rule(self):
        body = declaration_body('CutoffParameters', 'log_primeCutoff_scale_ratio_tendsto')
        self.assertIn('simp only [Real.rpow_eq_pow]\n    rw [← Real.rpow_add hQ]', body)

    def test_shared_adapter_has_expanded_type_and_axiom_target(self):
        name = 'Erdos647Sieve.Endpoint.log_div_rpow_eq'
        gates = json.loads((ROOT / 'scripts/gates.json').read_text())
        target = gates['endpoint_window_parameters']['audits']['Audit/EndpointWindowParameters.lean']
        self.assertEqual(target.count(name), 1)
        audit = (ROOT / 'research/Audit/EndpointWindowParameters.lean').read_text()
        self.assertIn('∀ u v r : ℝ, u ≠ 0 → 0 < v →', audit)
        self.assertIn('Real.log (u / Real.rpow v r) = Real.log u - r * Real.log v', audit)
        self.assertEqual(audit.count('#print axioms ' + name), 1)

    def test_statement_acceptance_is_not_endpoint_acceptance(self):
        status = json.loads((ROOT / 'docs/endpoint-coefficient-status.json').read_text())
        self.assertEqual(status['statement_interface']['status'], 'accepted')
        self.assertFalse(status['statement_interface']['is_endpoint_bound_proof'])
        assert_endpoint_evidence(self, ROOT, status)
        self.assertEqual(status['final_absorption_branch']['status'], 'accepted')
        self.assertEqual(status['cleanup_v48']['status'], 'acceptance_pending')

    def test_no_new_mandatory_output_coefficient(self):
        status = json.loads((ROOT / 'docs/endpoint-coefficient-status.json').read_text())
        self.assertIsNone(status['working_candidate'])
        self.assertFalse(status['historical_coefficient']['required'])
        self.assertFalse(status['coefficient_may_depend_on_X'])
        self.assertTrue(status['parameter_policy']['keep_existing_definitions'])
        self.assertIn('1000', status['parameter_policy']['momentT'])
        self.assertEqual(len(status['proof_priorities']), 4)
        self.assertIn('1/1000', status['legacy_corollary_policy'])


if __name__ == '__main__':
    unittest.main()
