"""Final-assembly interfaces, coefficient quantifiers, and fail-closed reporting.

Source/algebra/workflow tests are separate from the registered Lean proof gates.
"""
from __future__ import annotations

import contextlib
from copy import deepcopy
from fractions import Fraction as F
import hashlib
import io
import json
from pathlib import Path
import re
import sys
import tempfile
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts'))
import check
from promotion_history import accepted_source_bytes, predecessor_gate, assert_endpoint_evidence

FIXTURE = json.loads((ROOT / 'tests/fixtures/v45_accepted_sources.json').read_text())
MODULES = {'endpoint_absorption_scales': ('AbsorptionScales', 'EndpointAbsorptionScales'),
           'endpoint_error_absorption': ('ErrorAbsorption', 'EndpointErrorAbsorption'),
           'endpoint_final': ('Main', 'EndpointFinal')}
NS = 'Erdos647Sieve.Endpoint.'


def source(module):
    return (ROOT / 'research/Erdos647Research/Endpoint' / (module + '.lean')).read_text()


def audit(module):
    return (ROOT / 'research/Audit' / (module + '.lean')).read_text()


class FinalInterfaces(unittest.TestCase):
    def test_all_52_accepted_modules_and_27_audits_are_byte_exact(self):
        self.assertEqual(len(FIXTURE['source_sha256']), 79)
        for path, digest in FIXTURE['source_sha256'].items():
            with self.subTest(path=path):
                self.assertEqual(hashlib.sha256(accepted_source_bytes(ROOT, path)).hexdigest(), digest)

    def test_all_26_predecessor_gate_objects_are_preserved(self):
        self.assertEqual(len(FIXTURE['gates']), 26)
        for name, gate in FIXTURE['gates'].items():
            self.assertEqual(predecessor_gate(check.GATES[name], name), gate)

    def test_all_15_new_declarations_are_registered_and_audited(self):
        count = 0
        for gate, (module, audit_name) in MODULES.items():
            names = [('Erdos647Sieve.' if n == 'endpoint' else NS) + n
                     for n in re.findall(r'^theorem (\w+)', source(module), re.M)]
            self.assertEqual(check.GATES[gate]['audits'], {'Audit/' + audit_name + '.lean': names})
            self.assertEqual(re.findall(r'^#print axioms (\S+)', audit(audit_name), re.M), names)
            self.assertEqual(re.findall(r'^#check (\S+)', audit(audit_name), re.M), names)
            count += len(names)
        self.assertEqual(count, 15)

    def test_23_expanded_checks(self):
        self.assertEqual(sum(len(re.findall(r'^example\s*:', audit(a), re.M))
                             for _, a in MODULES.values()), 23)

    def test_all_29_gates_are_default_selected(self):
        selected = check.selected_gates(check.parser().parse_args([]))
        self.assertEqual(selected, list(check.GATES))
        self.assertEqual(len(selected), 30)

    def test_scale_check_is_independent_of_counting_pnt_and_budget(self):
        selected = check.selected_gates(check.parser().parse_args(['--gate','endpoint_absorption_scales']))
        for name in ['pntplus_inputs','endpoint_prime_mass_gap','endpoint_moment_tail','endpoint_counting_reduction']:
            self.assertNotIn(name, selected)

    def test_final_check_selects_counting_and_absorption(self):
        selected = check.selected_gates(check.parser().parse_args(['--gate','endpoint_final']))
        self.assertIn('endpoint_counting_reduction', selected)
        self.assertIn('endpoint_error_absorption', selected)
        self.assertEqual(selected[-1], 'endpoint_final')

    def test_no_admissions_or_warning_suppression(self):
        for module, a in MODULES.values():
            self.assertFalse(check.FORBIDDEN.search(check.strip_comments(source(module))))
            self.assertFalse(check.FORBIDDEN.search(check.strip_comments(audit(a))))
            self.assertIn('set_option warningAsError true', audit(a))
        check.source_boundary(ROOT)

    def test_no_parameter_or_endpoint_statement_redefinition(self):
        for module, _ in MODULES.values():
            self.assertNotRegex(check.strip_comments(source(module)),
                r'\b(?:def|abbrev)\s+(?:Candidate|EndpointBound|EndpointClaim|endpointExponent|windowLength|primeCutoff|truncationOrder|momentT|correctedBudget)\b')
            self.assertNotIn('RS_prime.', source(module))
            self.assertNotIn('PrimeNumberTheoremAnd.', source(module))

    def test_final_declarations_have_no_extra_mathematical_premise(self):
        text = source('Main')
        head = text.split('theorem endpointBound_of_lt_principal_rate',1)[1].split(':=',1)[0]
        self.assertEqual(' '.join(head.split()),
            '(c : ℝ) (hc : c < (1499 / 1000000 : ℝ)) : EndpointBound c')
        for name, typ in [('endpointBound_one_div_thousand','EndpointBound ((1 : ℝ) / 1000)'),
                          ('positiveEndpoint','PositiveEndpointClaim'),('endpoint','EndpointClaim')]:
            self.assertRegex(text, r'theorem '+name+r'\s*:\s*'+re.escape(typ)+r'\s*:=')

    def test_final_fixed_constant_is_outside_onset_and_X(self):
        text = audit('EndpointFinal')
        self.assertIn('∃ c : ℝ, 0 < c ∧ ∃ X0 : ℕ', text)
        self.assertIn('∀ X : ℕ, X0 ≤ X →', text)
        self.assertNotIn('∃ c : ℕ →', text)
        self.assertIn('Real.rpow (Real.log (X : ℝ)) endpointExponent', text)
        self.assertIn('Real.log (Real.log (X : ℝ))', text)
        self.assertIn('(candidateCount X : ℝ)', text)

    def test_no_linter_prone_unused_named_audit_hypotheses(self):
        for _, a in MODULES.values():
            for typ in re.findall(r'^example\s*:\s*(.*?)\s*:=',audit(a),re.M|re.S):
                for name in re.findall(r'\((h\w*)\s*:',typ):
                    self.assertGreater(len(re.findall(r'\b'+name+r'\b',typ)),1)

    def test_legacy_is_a_corollary_not_a_new_analytic_argument(self):
        text=source('Main')
        self.assertIn('legacyEndpointClaim_iff.mpr Endpoint.endpointBound_one_div_thousand',text)
        self.assertIn('endpointBound_of_lt_principal_rate ((1 : ℝ) / 1000) (by norm_num)',text)

    def test_absorption_includes_both_error_terms_and_factor_two(self):
        text=source('ErrorAbsorption')
        self.assertIn('2 * Real.exp (Real.log (X : ℝ) / 2)',text)
        self.assertIn('((squareRoot_ratio_tendsto_zero c).const_mul 2)',text)
        self.assertIn('momentTail_ratio_tendsto_zero c',text)
        self.assertIn('principal_ratio_tendsto_zero c hc',text)
        self.assertIn('eventually_candidateCount_le_amplified_errors',source('Main'))

    def test_majorant_definition_is_the_exact_accepted_expression(self):
        definition=source('ErrorAbsorption').split('def amplifiedErrorMajorant',1)[1].split('/--',1)[0]
        self.assertIn('(1499 / 1000000 : ℝ)',definition)
        self.assertIn('Real.exp (-(windowLength X : ℝ) / 30)',definition)
        self.assertIn('2 * Real.exp (Real.log (X : ℝ) / 2)',definition)
        self.assertNotIn('correctedBudget',definition)

    def test_static_acceptance_requires_real_final_evidence(self):
        r=json.loads((ROOT/'docs/endpoint-coefficient-status.json').read_text())
        self.assertRegex(r['version'], r'^v[0-9]+$')
        assert_endpoint_evidence(self, ROOT, r)
        self.assertEqual(r['amplified_error_branch']['status'],'accepted')
        self.assertEqual(r['final_absorption_branch']['status'],'accepted')
        self.assertEqual(r['final_absorption_branch']['implemented_explicit_coefficient'],{'numerator':1,'denominator':1000})
        self.assertFalse(r['historical_coefficient']['required'])

    def test_new_sources_audits_and_fixture_are_collected(self):
        paths={p.relative_to(ROOT).as_posix() for p in check.source_files(ROOT)}
        for m,a in MODULES.values():
            self.assertIn('research/Erdos647Research/Endpoint/'+m+'.lean',paths)
            self.assertIn('research/Audit/'+a+'.lean',paths)
        self.assertIn('tests/fixtures/v45_accepted_sources.json',paths)


class ExactAbsorptionAlgebra(unittest.TestCase):
    def test_principal_slack_needs_no_numerical_log_approximation(self):
        self.assertLess(F(1,1000),F(1499,1000000))
        self.assertEqual(F(1499,1000000)-F(1,1000),F(499,1000000))

    def test_normalized_exponents(self):
        for U in [F(3,2),F(99,7),F(100000,3)]:
            H=F(U.numerator//U.denominator)
            for L,Q in [(F(1,2),F(7)),(F(20),F(9000)),(F(301,7),F(999999))]:
                S=U/L
                for c in [F(-1),F(0),F(1,1000),F(1498999,10**9)]:
                    k=F(1499,1000000)
                    self.assertEqual((c-k*H/U)*S,-k*H/L+c*S)
                    self.assertEqual((c*S/H-F(1,30))*H,-H/30+c*S)
                    self.assertEqual((c*S/Q-F(1,2))*Q,-Q/2+c*S)
                    self.assertEqual((U/H)/L,S/H)

    def test_strict_upper_coefficient_is_not_silently_closed(self):
        k=F(1499,1000000)
        for U,H in [(F(3,2),F(1)),(F(101,2),F(50))]:
            self.assertGreater(k-k*H/U,0)
        self.assertIn('(hc : c < (1499 / 1000000 : ℝ))',source('Main'))


def passing_fixture():
    final='endpoint_final'
    names=next(iter(check.GATES[final]['audits'].values()))
    return {'run_id':'MOCK_CURRENT_RUN_NOT_PROOF_EVIDENCE','status':'PASS_SELECTED_CHECKS',
        'selected_gates':list(check.GATES),'checks_role':'BUILD_TYPE_AXIOM',
        'source_sha256_before':{'Example.lean':'same'},'source_sha256_after':{'Example.lean':'same'},
        'source_changes':{},'gates':{g:{'status':'PASS','build_warnings':[],
            'axioms':{n:sorted(check.ALLOW) for n in names} if g==final else {}} for g in check.GATES},
        'commands':[{'label':final+'_build','exit_code':0},{'label':final+'_audit_0','exit_code':0}]}


class EndpointReporting(unittest.TestCase):
    def assert_rejected(self, record):
        record['endpoint_proved']=True
        record['endpoint_coefficient']={'numerator':99,'denominator':1}
        check.record_endpoint_acceptance(record)
        self.assertFalse(record['endpoint_proved'])
        self.assertIsNone(record['endpoint_coefficient'])
        self.assertIsNone(record['endpoint_acceptance'])

    def test_current_full_acceptance_records_the_explicit_constant(self):
        record=passing_fixture();check.record_endpoint_acceptance(record)
        self.assertTrue(record['endpoint_proved'])
        self.assertEqual(record['endpoint_coefficient'],{'numerator':1,'denominator':1000})
        self.assertFalse(record['endpoint_acceptance']['is_resolution_of_erdos647'])
        self.assertEqual(record['endpoint_acceptance']['run_id'],record['run_id'])

    def test_old_v45_success_does_not_claim_the_final_endpoint(self):
        record=json.loads((ROOT/'provenance/accepted/v45/summary.json').read_text())
        self.assert_rejected(record)

    def test_failed_overall_run_rejected(self):
        r=passing_fixture();r['status']='FAIL_OR_BLOCKED';self.assert_rejected(r)

    def test_tooling_only_run_rejected(self):
        r=passing_fixture();r['checks_role']='TOOLING_ONLY';self.assert_rejected(r)

    def test_unrequested_final_gate_rejected(self):
        r=passing_fixture();r['selected_gates'].remove('endpoint_final');self.assert_rejected(r)

    def test_failed_or_blocked_final_gate_rejected(self):
        for status in ['FAIL','BLOCKED','RUNNING','NOT_REQUESTED']:
            r=passing_fixture();r['gates']['endpoint_final']['status']=status;self.assert_rejected(r)

    def test_critical_source_change_rejected(self):
        r=passing_fixture();r['source_sha256_after']['Example.lean']='changed';self.assert_rejected(r)

    def test_missing_source_snapshot_rejected(self):
        r=passing_fixture();del r['source_sha256_after'];self.assert_rejected(r)

    def test_foreign_axiom_rejected(self):
        r=passing_fixture();next(iter(r['gates']['endpoint_final']['axioms'].values())).append('sorryAx');self.assert_rejected(r)

    def test_missing_or_extra_theorem_report_rejected(self):
        r=passing_fixture();r['gates']['endpoint_final']['axioms'].pop('Erdos647Sieve.endpoint');self.assert_rejected(r)
        r=passing_fixture();r['gates']['endpoint_final']['axioms']['Fake.theorem']=[];self.assert_rejected(r)

    def test_failed_prerequisite_rejected(self):
        r=passing_fixture();r['gates']['endpoint_error_absorption']['status']='FAIL';self.assert_rejected(r)

    def test_nonzero_final_audit_even_with_clean_reports_rejected(self):
        r=passing_fixture();r['commands'][-1]['exit_code']=1;self.assert_rejected(r)

    def test_duplicate_or_missing_command_rejected(self):
        r=passing_fixture();r['commands'].append(deepcopy(r['commands'][-1]));self.assert_rejected(r)
        r=passing_fixture();r['commands'].pop();self.assert_rejected(r)

    def test_build_warning_rejected(self):
        r=passing_fixture();r['gates']['endpoint_final']['build_warnings']=['warning'];self.assert_rejected(r)

    def test_finished_tooling_archive_labels_stay_consistent(self):
        with tempfile.TemporaryDirectory() as temp,contextlib.redirect_stdout(io.StringIO()):
            root=Path(temp);r=check.Run(root,check.parser().parse_args(['tooling']))
            r.record['status']='PASS_SELECTED_CHECKS';r.finish()
            version = json.loads((ROOT/'docs/endpoint-coefficient-status.json').read_text())['version']
            self.assertTrue(r.dest.name.startswith('erdos647_repo_' + version + '_results_'))
            zpath=r.dest.with_suffix('.zip')
            self.assertEqual((root/'results/latest_result.txt').read_text().strip(),str(zpath))
            with zipfile.ZipFile(zpath) as z:
                report=json.loads(z.read(r.id+'/summary.json'))
                self.assertFalse(report['endpoint_proved'])
                self.assertIsNone(report['endpoint_coefficient'])
                text=z.read(r.id+'/SUMMARY.md').decode()
                self.assertIn('No final endpoint acceptance',text)
