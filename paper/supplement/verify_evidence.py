#!/usr/bin/env python3
"""Read-only verification of the supplied v48 source/log archive.

Checks archived hashes and recorded audit consistency. This is not a Lean run
or an independent kernel replay. No extraction, network access, or dependencies.
"""
from __future__ import annotations
import hashlib
import json
from pathlib import Path
import re
import sys
import zipfile

ARCHIVE = 'erdos647_repo_v48_results_20260909T014011Z_dd165b9f.zip'
EXPECTED_SHA256 = '7043421f1ec2ca5c85963e84a1a670096b23a2688fb16932a42b738c1343561e'
ALLOWED = {'propext', 'Classical.choice', 'Quot.sound'}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def verify(path: Path) -> dict:
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    require(digest == EXPECTED_SHA256, 'The archive does not match the manuscript fingerprint.')
    with zipfile.ZipFile(path) as z:
        names = z.namelist()
        require(len(names) == len(set(names)), 'Duplicate archive members.')
        summaries = [n for n in names if n.count('/') == 1 and n.endswith('/summary.json')]
        require(len(summaries) == 1, 'Expected exactly one top-level summary.')
        root = summaries[0].rsplit('/', 1)[0] + '/'
        summary = json.loads(z.read(root + 'summary.json'))
        manifest = json.loads(z.read(root + 'MANIFEST.json'))
        require(isinstance(manifest, dict), 'Unexpected manifest format.')
        for relative, expected in manifest.items():
            require(root + relative in names, f'Missing member: {relative}')
            got = hashlib.sha256(z.read(root + relative)).hexdigest()
            require(got == expected, f'Hash mismatch: {relative}')
        gates = summary['gates']
        require(len(gates) == 30, 'Expected the complete 30-gate v48 suite.')
        require(all(g['status'] == 'PASS' for g in gates.values()), 'A gate did not pass.')
        require(summary['scope'] == 'all', 'Not a repository-wide run.')
        require(summary['endpoint_proved'] is True, 'No successful final endpoint acceptance.')
        require(all(c['exit_code'] == 0 for c in summary['commands']), 'A recorded command failed.')
        require(not summary['source_changes'], 'Checked inputs changed during the run.')
        before = summary['source_sha256_before']
        after = summary['source_sha256_after']
        require(before == after, 'Before/after source snapshots differ.')
        for relative, expected in before.items():
            got = hashlib.sha256(z.read(root + 'source/' + relative)).hexdigest()
            require(got == expected, f'Source snapshot mismatch: {relative}')
        reports: dict[str, set[str]] = {}
        warnings = []
        for name in names:
            if not name.startswith(root + 'logs/') or not name.endswith('.log'):
                continue
            text = z.read(name).decode('utf-8')
            if re.search(r'(?im)^.*\b(?:warning|error):', text):
                warnings.append(name)
            if '_audit_' not in name:
                continue
            require('EXIT_CODE=0' in text, f'Unsuccessful audit log: {name}')
            for declaration, raw in re.findall(r"'([^']+)' depends on axioms:\s*\[([^\]]*)\]", text):
                axioms = {x.strip() for x in raw.split(',') if x.strip()}
                require(axioms <= ALLOWED, f'Unauthorized axiom: {declaration}: {axioms}')
                if declaration in reports:
                    require(reports[declaration] == axioms, f'Inconsistent reports: {declaration}')
                reports[declaration] = axioms
            for declaration in re.findall(r"'([^']+)' does not depend on any axioms", text):
                reports[declaration] = set()
        require(not warnings, f'Diagnostic warnings/errors: {warnings}')
        require(len(reports) == 235, f'Expected 235 distinct reports, found {len(reports)}.')
        for gate in gates.values():
            for declaration, axioms in gate.get('axioms', {}).items():
                require(declaration in reports, f'Missing raw axiom report: {declaration}')
                require(reports[declaration] == set(axioms), f'Summary/log disagreement: {declaration}')
        audit_sources = [n for n in names if n.endswith('.lean') and
                         (n.startswith(root + 'source/Audit/') or
                          n.startswith(root + 'source/research/Audit/'))]
        examples = sum(len(re.findall(r'(?m)^example\b', z.read(n).decode('utf-8')))
                       for n in audit_sources)
        require(len(audit_sources) == 32 and examples == 220, 'Audit-source count differs from manuscript.')
        return {'status': 'SOURCE_AND_LOG_REVIEW_PASSED',
                'run_id': summary['run_id'], 'archive_sha256': digest,
                'manifest_entries': len(manifest), 'stable_source_inputs': len(before),
                'passed_gates': len(gates), 'commands': len(summary['commands']),
                'distinct_axiom_reports': len(reports), 'audit_files': len(audit_sources),
                'exact_type_and_definition_examples': examples,
                'lean_execution_performed_by_this_script': False}


if __name__ == '__main__':
    path = Path(sys.argv[1]) if len(sys.argv) == 2 else Path(__file__).with_name(ARCHIVE)
    try:
        print(json.dumps(verify(path), indent=2))
    except (OSError, ValueError, KeyError, zipfile.BadZipFile) as error:
        print(f'REVIEW FAILED: {error}', file=sys.stderr)
        raise SystemExit(1)
