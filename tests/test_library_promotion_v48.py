"""v48 package ownership/preservation tests; not substitutes for Lean proof gates."""
from __future__ import annotations
import ast
from copy import deepcopy
import hashlib
import json
from pathlib import Path
import re
import sys
import tempfile
import unittest

ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'scripts'))
import check
from promotion_history import accepted_source_bytes, predecessor_gate, assert_endpoint_evidence
OLD=ROOT/'provenance/accepted/v47/source'
MOVES=json.loads((ROOT/'scripts/elementary_promotion_v48.json').read_text())['moves']
OLD_GATES=json.loads((OLD/'scripts/gates.json').read_text())
NAMES={'FactorialBounds','FactorialEstimate','LogBudgetFactorial','PrimeReciprocalLower',
       'SmallPrimeDebitEstimate','EndpointLogBounds','CorrectedBudgetEstimate'}
ELEMENTARY_GATES=['factorial_bounds','factorial_estimate','log_budget_factorial',
                 'prime_reciprocal_lower','small_prime_debit_estimate','endpoint_log_bounds',
                 'corrected_budget_estimate']

def without_imports(text):
    return re.sub(r'^\s*import[^\n]*\n','',check.strip_comments(text),flags=re.M).strip()

def examples(text):
    return [' '.join(x.split()) for x in re.findall(r'^example\s*:(.*?)(?=^#check|^#print|\Z)',
                     check.strip_comments(text),re.M|re.S)]

class Promotion(unittest.TestCase):
    def test_exact_seven_selected_modules(self):
        self.assertEqual(len(MOVES),7)
        self.assertEqual({Path(m['old']).stem for m in MOVES},NAMES)
        for m in MOVES:
            self.assertEqual(m['old'],f"research/Erdos647Research/{Path(m['old']).name}")
            self.assertEqual(m['new'],f"Erdos647Sieve/Elementary/{Path(m['old']).name}")

    def test_current_proofs_match_accepted_transform_not_just_new_hashes(self):
        for m in MOVES:
            with self.subTest(module=m['old']):
                self.assertEqual(accepted_source_bytes(ROOT,m['old']),(OLD/m['old']).read_bytes())
                self.assertEqual(without_imports((ROOT/m['new']).read_text()),
                                 without_imports((OLD/m['old']).read_text()))

    def test_all_declarations_have_one_implementation(self):
        for m in MOVES:
            self.assertEqual(check.strip_comments((ROOT/m['old']).read_text()).strip(),
                             'import '+m['new'][:-5].replace('/','.'))
            self.assertNotRegex(check.strip_comments((ROOT/m['old']).read_text()),r'\b(theorem|lemma|def|abbrev)\b')

    def test_import_and_comment_changes_are_the_only_recorded_edits(self):
        stale={'New implementation source: compiler and transitive axiom audits are pending.\n',
               'New implementation source; compilation and transitive axiom audits are pending.\n',
               'New source: compilation and transitive axiom audit are pending.\n'}
        for m in MOVES:
            for e in m['edits']:
                if e['before'].startswith('import '):
                    name=e['before'].strip().split('.')[-1]
                    self.assertIn(name,NAMES)
                    self.assertEqual(e['after'],f'import Erdos647Sieve.Elementary.{name}\n')
                else:
                    self.assertIn(e['before'],stale)
                    self.assertEqual(e['after'],'')

    def test_altered_new_proof_fails_preservation(self):
        m=MOVES[0]
        with tempfile.TemporaryDirectory() as t:
            r=Path(t)
            for p in ['scripts/elementary_promotion_v48.json',m['old'],m['new'],
                      'provenance/accepted/v47/source/'+m['old']]:
                dst=r/p;dst.parent.mkdir(parents=True,exist_ok=True);dst.write_bytes((ROOT/p).read_bytes())
            with (r/m['new']).open('a') as out:out.write('\ntheorem changed : True := by trivial\n')
            with self.assertRaises(AssertionError):accepted_source_bytes(r,m['old'])

    def test_all_other_mathematical_files_are_byte_exact(self):
        moved={m['old'] for m in MOVES}
        files=[*OLD.joinpath('Erdos647Sieve').rglob('*.lean'),
               *OLD.joinpath('research/Erdos647Research').rglob('*.lean')]
        self.assertEqual(len(files),54)
        for p in files:
            rel=p.relative_to(OLD).as_posix()
            if rel not in moved:self.assertEqual((ROOT/rel).read_bytes(),p.read_bytes(),rel)
        self.assertEqual((ROOT/'Erdos647Sieve.lean').read_bytes(),(OLD/'Erdos647Sieve.lean').read_bytes())

    def test_all_30_original_audits_are_byte_exact(self):
        audits=[*OLD.joinpath('Audit').rglob('*.lean'),*OLD.joinpath('research/Audit').rglob('*.lean')]
        self.assertEqual(len(audits),30)
        for p in audits:self.assertEqual(p.read_bytes(),(ROOT/p.relative_to(OLD)).read_bytes())

    def test_toolchain_lockfiles_and_pnt_guard_unchanged(self):
        for p in ['lean-toolchain','lake-manifest.json','research/lean-toolchain',
                  'research/lake-manifest.json','scripts/pins.json','scripts/pntplus_closure.py']:
            self.assertEqual((ROOT/p).read_bytes(),(OLD/p).read_bytes(),p)

    def test_old_finite_facades_unchanged(self):
        for p in ['Erdos647Sieve.lean','Erdos647Sieve/Basic.lean','Erdos647Sieve/Finite.lean']:
            self.assertEqual((ROOT/p).read_bytes(),(OLD/p).read_bytes())
            self.assertNotIn('Elementary',check.strip_comments((ROOT/p).read_text()))

    def test_elementary_facade_is_opt_in_and_has_exact_seven_imports(self):
        self.assertEqual(set(check.imports((ROOT/'Erdos647Sieve/Elementary.lean').read_text())),
                         {'Erdos647Sieve.Elementary.'+n for n in NAMES})

    def test_no_pnt_research_or_endpoint_proof_in_core(self):
        check.source_boundary(ROOT,include_research=False)
        for p in (ROOT/'Erdos647Sieve').rglob('*.lean'):
            code=check.strip_comments(p.read_text())
            self.assertNotIn('PrimeNumberTheoremAnd.',code)
            self.assertNotIn('Erdos647Research.',code)
            self.assertNotIn('RS_prime.',code)
            self.assertNotRegex(code,r'theorem\s+(?:endpoint|positiveEndpoint)\b')

    def test_core_audit_module_closure_uses_only_root_sources(self):
        sources=check.gate_module_sources(ROOT,check.GATES['core'])
        for name,(p,obj) in sources.items():
            self.assertTrue(name.startswith(('Erdos647Sieve','Examples')))
            self.assertNotIn('research',p.relative_to(ROOT).parts)
            self.assertTrue(str(obj).startswith(str(ROOT/'.lake/build/lib/lean')))
        for name in NAMES:self.assertIn('Erdos647Sieve.Elementary.'+name,sources)

class GatesAndFacades(unittest.TestCase):
    def test_all_29_predecessor_gate_contracts_preserved_except_added_core_audit(self):
        self.assertEqual(len(OLD_GATES),29)
        for name,gate in OLD_GATES.items():
            self.assertEqual(predecessor_gate(check.GATES[name],name),gate)
        self.assertEqual(set(check.GATES)-set(OLD_GATES),{'endpoint_public_results'})

    def test_default_30_gates_and_core_only_stay_separate(self):
        self.assertEqual(check.selected_gates(check.parser().parse_args([])),list(check.GATES))
        self.assertEqual(len(check.GATES),30)
        self.assertEqual(check.selected_gates(check.parser().parse_args(['core'])),['core'])
        self.assertNotIn('pntplus_inputs',check.selected_gates(check.parser().parse_args(['core'])))

    def test_root_audit_covers_all_20_elementary_targets(self):
        want=[n for g in ELEMENTARY_GATES for ns in OLD_GATES[g]['audits'].values() for n in ns]
        self.assertEqual(len(want),20)
        self.assertEqual(check.GATES['core']['audits']['Audit/Elementary.lean'],want)
        self.assertEqual(re.findall(r'^#print axioms (\S+)',(ROOT/'Audit/Elementary.lean').read_text(),re.M),want)

    def test_promoted_expanded_audit_statements_preserved_verbatim(self):
        new=examples((ROOT/'Audit/Elementary.lean').read_text())
        old=[]
        for g in ELEMENTARY_GATES:
            for a in OLD_GATES[g]['audits']:old.extend(examples((OLD/'research'/a).read_text()))
        self.assertEqual(new,old)

    def test_existing_seven_research_gates_recheck_compatibility_imports(self):
        for g in ELEMENTARY_GATES:self.assertEqual(check.GATES[g],OLD_GATES[g])

    def test_research_public_modules_import_existing_proofs_only(self):
        self.assertEqual(check.imports((ROOT/'research/Erdos647Research/Endpoint.lean').read_text()),
                         ['Erdos647Research.Endpoint.Main'])
        self.assertEqual(check.imports((ROOT/'research/Erdos647Research/Analytic.lean').read_text()),
                         ['Erdos647Research.SelectedPrimeReciprocals'])

    def test_public_endpoint_exact_statements_match_final_audit(self):
        self.assertEqual(examples((ROOT/'research/Audit/PublicResults.lean').read_text()),
                         examples((OLD/'research/Audit/EndpointFinal.lean').read_text()))

    def test_public_gate_selects_endpoint_and_analytic_prerequisites(self):
        selected=check.selected_gates(check.parser().parse_args(['--gate','endpoint_public_results']))
        self.assertIn('endpoint_final',selected)
        self.assertIn('selected_prime_reciprocals',selected)
        self.assertEqual(selected[-1],'endpoint_public_results')

    def test_public_examples_have_only_public_imports(self):
        self.assertEqual(check.imports((ROOT/'Examples/ElementaryUsage.lean').read_text()),
                         ['Erdos647Sieve.Elementary'])
        self.assertEqual(check.imports((ROOT/'research/Erdos647Research/Examples/EndpointUsage.lean').read_text()),
                         ['Erdos647Research.Endpoint'])

    def test_every_new_example_is_in_a_build_target(self):
        self.assertIn('`Examples.ElementaryUsage',(ROOT/'lakefile.lean').read_text())
        self.assertIn('+Erdos647Research.Examples.EndpointUsage',check.GATES['endpoint_public_results']['build'])
        self.assertIn('`Erdos647Research.Examples.EndpointUsage',(ROOT/'research/lakefile.lean').read_text())

    def test_warning_policy_on_every_new_library_and_audit(self):
        for p in ['lakefile.lean','research/lakefile.lean']:
            t=(ROOT/p).read_text()
            self.assertEqual(t.count('lean_lib '),t.count('moreLeanArgs := #["-DwarningAsError=true"]'))
        for p in ['Audit/Elementary.lean','research/Audit/PublicResults.lean']:
            self.assertIn('set_option warningAsError true',(ROOT/p).read_text())

    def test_current_source_boundary_passes_all_registered_modules(self):
        check.source_boundary(ROOT)

    def test_no_core_dependency_or_runtime_audit_weakening(self):
        old=ast.parse((OLD/'scripts/check.py').read_text())
        new=ast.parse((ROOT/'scripts/check.py').read_text())
        byname=lambda tree:{n.name:n for n in tree.body if isinstance(n,(ast.FunctionDef,ast.ClassDef))}
        a,b=byname(old),byname(new)
        self.assertEqual(set(a),set(b))
        for name in a:
            if name in {'gate_module_sources','source_boundary'}:continue
            node=deepcopy(b[name])
            if name=='Run':
                for c in ast.walk(node):
                    if isinstance(c,ast.Constant) and c.value=='erdos647_repo_v48_results_':
                        c.value='erdos647_repo_v47_results_'
            self.assertEqual(ast.dump(node,include_attributes=False),ast.dump(a[name],include_attributes=False),name)

    def test_core_lake_edit_is_only_new_example_root(self):
        expected=(OLD/'lakefile.lean').read_text().replace(
            '`Examples.BasicUsage, `Examples.MomentSpecialization]',
            '`Examples.BasicUsage, `Examples.MomentSpecialization, `Examples.ElementaryUsage]')
        self.assertEqual((ROOT/'lakefile.lean').read_text(),expected)

    def test_research_lake_original_libraries_unchanged(self):
        old=(OLD/'research/lakefile.lean').read_text().split('/-- All registered research proof gates,')[0]
        new=(ROOT/'research/lakefile.lean').read_text().split('/-- Public analytic/endpoint facades')[0]
        self.assertEqual(new,old)
        for name in ['PNTPlusCompat','Erdos647Analytic','Erdos647Elementary','Erdos647Endpoint']:
            self.assertIn('lean_lib '+name,new)

class AcceptedEvidence(unittest.TestCase):
    def test_historical_v47_manifest_is_intact(self):
        directory=ROOT/'provenance/accepted/v47'
        manifest=json.loads((directory/'MANIFEST.json').read_text())
        self.assertEqual(len(manifest),272)
        for p,h in manifest.items():self.assertEqual(check.sha(directory/p),h,p)

    def test_endpoint_status_matches_actual_final_reports(self):
        assert_endpoint_evidence(self,ROOT,json.loads((ROOT/'docs/endpoint-coefficient-status.json').read_text()))

    def test_current_cleanup_does_not_claim_a_new_30_gate_pass(self):
        r=json.loads((ROOT/'docs/endpoint-coefficient-status.json').read_text())
        self.assertEqual(r['cleanup_v48']['status'],'acceptance_pending')
        self.assertEqual(r['cleanup_v48']['total_gates'],30)
        self.assertEqual(r['final_absorption_branch']['latest_run']['gates_passed'],29)

    def test_coefficient_range_remains_strict_with_fixed_positive_example(self):
        r=json.loads((ROOT/'docs/endpoint-coefficient-status.json').read_text())
        self.assertEqual(r['proved_coefficient'],{'numerator':1,'denominator':1000})
        bound=r['final_absorption_branch']['proved_positive_coefficient_range']
        self.assertEqual(bound,{'lower_exclusive':0,'upper_exclusive':{'numerator':1499,'denominator':1000000}})
        self.assertFalse(r['coefficient_may_depend_on_X'])

    def test_all_new_proof_paths_and_map_in_diagnostics(self):
        paths={p.relative_to(ROOT).as_posix() for p in check.source_files(ROOT)}
        for m in MOVES:self.assertIn(m['new'],paths)
        for p in ['Audit/Elementary.lean','research/Audit/PublicResults.lean',
                  'Examples/ElementaryUsage.lean','scripts/elementary_promotion_v48.json']:
            self.assertIn(p,paths)

    def test_gitignore_and_entrypoints_preserved(self):
        for p in ['.gitignore',
                  '.gitattributes','RUN.sh','TEST_ALL.sh']:
            self.assertEqual((ROOT/p).read_bytes(),(OLD/p).read_bytes(),p)

if __name__=='__main__':unittest.main()
