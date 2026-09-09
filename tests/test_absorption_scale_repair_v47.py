"""Single-site proof repair and reporting preservation, not a Lean proof check."""
import hashlib
import json
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts'))
import check
from promotion_history import assert_endpoint_evidence

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
            if name in {'scripts/gates.json', 'lakefile.lean', 'research/lakefile.lean'}:
                continue  # Explicit additive v48 layout changes checked in test_library_promotion_v48.
            with self.subTest(path=name):
                self.assertEqual(hashlib.sha256((ROOT/name).read_bytes()).hexdigest(), digest)

    def test_historical_v47_runner_repair_is_preserved_in_evidence(self):
        text=(ROOT/'provenance/accepted/v47/source/scripts/check.py').read_text()
        restored=text.replace("'erdos647_repo_v47_results_'", "'erdos647_repo_v46_results_'")
        self.assertEqual(hashlib.sha256(restored.encode()).hexdigest(), FIXTURE['runner_before_sha256'])

    def test_failed_current_run_cannot_reuse_historical_endpoint_acceptance(self):
        status=json.loads((ROOT/'docs/endpoint-coefficient-status.json').read_text())
        assert_endpoint_evidence(self, ROOT, status)
        r={'endpoint_proved': True, 'status': 'FAIL_OR_BLOCKED',
           'gates': {'endpoint_absorption_scales': {'status':'FAIL'}}}
        check.record_endpoint_acceptance(r)
        self.assertFalse(r['endpoint_proved'])
        self.assertIsNone(r['endpoint_coefficient'])

    def test_named_and_expanded_scale_types_remain_separately_audited(self):
        text = (ROOT/'research/Audit/EndpointAbsorptionScales.lean').read_text()
        self.assertIn('example : Tendsto endpointScale atTop atTop', text)
        self.assertIn('Real.rpow (Real.log (X : ℝ)) endpointExponent /', text)
        self.assertIn('Real.log (Real.log (X : ℝ))) atTop atTop', text)
        self.assertIn('#print axioms Erdos647Sieve.Endpoint.endpointScale_tendsto_atTop', text)
        self.assertEqual(len(check.GATES), 30)
