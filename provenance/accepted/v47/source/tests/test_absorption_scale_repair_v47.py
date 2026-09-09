"""Single-site proof repair and reporting preservation, not a Lean proof check."""
import hashlib
import json
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts'))
import check

FIXTURE = json.loads((ROOT / 'tests/fixtures/v46_absorption_repair.json').read_text())


class AbsorptionScaleRepair(unittest.TestCase):
    def test_only_the_goal_conversion_changed_in_the_proof_file(self):
        text = (ROOT / FIXTURE['repair_path']).read_text()
        self.assertEqual(text.count(FIXTURE['replacement_fragment']), 1)
        restored = text.replace(FIXTURE['replacement_fragment'], FIXTURE['old_fragment'])
        self.assertEqual(hashlib.sha256(restored.encode()).hexdigest(),
                         FIXTURE['repair_source_before_sha256'])

    def test_every_existing_audit_and_dependency_contract_is_unchanged(self):
        for name, digest in FIXTURE['preserved_sha256'].items():
            with self.subTest(path=name):
                self.assertEqual(hashlib.sha256((ROOT/name).read_bytes()).hexdigest(), digest)

    def test_runner_change_is_only_the_archive_label(self):
        text = (ROOT/'scripts/check.py').read_text()
        version = json.loads((ROOT/'docs/endpoint-coefficient-status.json').read_text())['version']
        marker = "'erdos647_repo_" + version + "_results_'"
        self.assertEqual(text.count(marker), 1)
        restored = text.replace(marker, "'erdos647_repo_v46_results_'")
        self.assertEqual(hashlib.sha256(restored.encode()).hexdigest(),
                         FIXTURE['runner_before_sha256'])

    def test_repair_does_not_promote_endpoint_acceptance(self):
        status = json.loads((ROOT/'docs/endpoint-coefficient-status.json').read_text())
        self.assertIsNone(status['proved_coefficient'])
        self.assertIsNone(status['proved_endpoint_theorem'])
        self.assertFalse(status['final_absorption_branch']['latest_run']['new_final_layer_gates_accepted'])
        self.assertEqual(status['final_absorption_branch']['latest_run']['gates_passed'], 26)
        r = {'endpoint_proved': True, 'endpoint_coefficient': {'numerator': 1, 'denominator': 1000},
             'status': 'FAIL_OR_BLOCKED', 'gates': {'endpoint_absorption_scales': {'status':'FAIL'}}}
        check.record_endpoint_acceptance(r)
        self.assertFalse(r['endpoint_proved'])
        self.assertIsNone(r['endpoint_coefficient'])

    def test_named_and_expanded_scale_types_remain_separately_audited(self):
        text = (ROOT/'research/Audit/EndpointAbsorptionScales.lean').read_text()
        self.assertIn('example : Tendsto endpointScale atTop atTop', text)
        self.assertIn('Real.rpow (Real.log (X : ℝ)) endpointExponent /', text)
        self.assertIn('Real.log (Real.log (X : ℝ))) atTop atTop', text)
        self.assertIn('#print axioms Erdos647Sieve.Endpoint.endpointScale_tendsto_atTop', text)
        self.assertEqual(len(check.GATES), 29)
