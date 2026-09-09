"""Historical regression checks through explicit source moves, not updated proof hashes."""
from pathlib import Path
import hashlib
import json

def accepted_source_bytes(root: Path, relative: str) -> bytes:
    entries = json.loads((root/'scripts/elementary_promotion_v48.json').read_text())['moves']
    entry = next((e for e in entries if e['old'] == relative), None)
    if entry is None:
        return (root/relative).read_bytes()
    original = (root/'provenance/accepted/v47/source'/relative).read_bytes()
    if hashlib.sha256(original).hexdigest() != entry['before_sha256']:
        raise AssertionError('Historical source mismatch: '+relative)
    expected = original.decode()
    for edit in entry['edits']:
        if expected.count(edit['before']) != 1:
            raise AssertionError('Non-unique promotion edit: '+relative)
        expected = expected.replace(edit['before'], edit['after'])
    actual = (root/entry['new']).read_bytes()
    if actual != expected.encode() or hashlib.sha256(actual).hexdigest()!=entry['after_sha256']:
        raise AssertionError('Promoted proof differs beyond recorded imports/comments: '+relative)
    if hashlib.sha256((root/relative).read_bytes()).hexdigest()!=entry['shim_sha256']:
        raise AssertionError('Compatibility import changed: '+relative)
    return original

def predecessor_gate(gate: dict, name: str) -> dict:
    out=json.loads(json.dumps(gate))
    if name == 'core':
        out['audits'].pop('Audit/Elementary.lean')
    return out

def assert_endpoint_evidence(testcase, root: Path, record: dict) -> None:
    from check import parse_axioms, ALLOW
    evidence=root/record['endpoint_acceptance_evidence']
    summary=json.loads((evidence.parent/'summary.json').read_text())
    testcase.assertEqual(summary['status'],'PASS_SELECTED_CHECKS')
    testcase.assertEqual(summary['source_sha256_before'],summary['source_sha256_after'])
    testcase.assertEqual(summary['gates']['endpoint_final']['status'],'PASS')
    testcase.assertTrue(summary['endpoint_proved'])
    testcase.assertEqual(record['proved_coefficient'],summary['endpoint_coefficient'])
    testcase.assertEqual(record['proved_endpoint_theorem'],summary['endpoint_acceptance']['theorem'])
    testcase.assertEqual(record['final_absorption_branch']['latest_run']['run_id'],summary['run_id'])
    commands=[c for c in summary['commands'] if c['label']=='endpoint_final_audit_0']
    testcase.assertEqual(len(commands),1)
    testcase.assertEqual(commands[0]['exit_code'],0)
    text=(evidence.parent/commands[0]['log']).read_text()
    for name in summary['gates']['endpoint_final']['axioms']:
        testcase.assertTrue(set(parse_axioms(text,name)) <= ALLOW)
    testcase.assertEqual((evidence.parent/'source/research/Erdos647Research/Endpoint/Main.lean').read_bytes(),
                         (root/'research/Erdos647Research/Endpoint/Main.lean').read_bytes())
    testcase.assertEqual(record['cleanup_v48']['status'],'acceptance_pending')
