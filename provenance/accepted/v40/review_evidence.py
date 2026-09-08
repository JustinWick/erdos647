#!/usr/bin/env python3
"""Read-only consistency check of the preserved user-returned v40 diagnostic ZIP.

Does not execute source from the ZIP, invoke Lean, fetch dependencies or mutate the
repository. An internal hash manifest is an integrity check, not authentication.
"""
from __future__ import annotations
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import sys
from zipfile import ZipFile

NAME = 'erdos647_repo_v40_results_20260908T091111Z_0850cec9'
ALLOW = {'propext', 'Classical.choice', 'Quot.sound'}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def check(path: Path) -> dict:
    with ZipFile(path) as archive:
        require(archive.testzip() is None, 'ZIP CRC mismatch')
        info = archive.infolist()
        require(len({i.filename for i in info}) == len(info), 'Duplicate ZIP paths')
        for entry in info:
            parts = PurePosixPath(entry.filename)
            require(not parts.is_absolute() and '..' not in parts.parts,
                    'Unsafe ZIP path: ' + entry.filename)
        prefix = NAME + '/'
        require(all(i.filename.startswith(prefix) for i in info), 'Unexpected archive root')
        data = {i.filename[len(prefix):]: archive.read(i) for i in info if not i.is_dir()}
    load = lambda name: json.loads(data[name].decode('utf-8'))
    text = lambda name: data[name].decode('utf-8')
    digest = lambda name: hashlib.sha256(data[name]).hexdigest()
    s, manifest, registry = load('summary.json'), load('MANIFEST.json'), load('source/scripts/gates.json')
    require(s['run_id'] == NAME, 'Unexpected run identifier')
    require(s['toolchain'] == 'leanprover/lean4:v4.32.2', 'Toolchain mismatch')
    for name, expected in manifest.items():
        require(name in data and digest(name) == expected, 'Manifest mismatch: ' + name)
    before, after = s['source_sha256_before'], s['source_sha256_after']
    require(before == after and not s['source_changes'], 'Sources changed during run')
    for name, expected in after.items():
        require(digest('source/' + name) == expected, 'Source snapshot mismatch: ' + name)
    require(set(registry) == set(s['gates']) == set(s['selected_gates']), 'Gate selection mismatch')
    require(all(g['status'] == 'PASS' for g in s['gates'].values()), 'Non-passing gate')
    commands = {c['label']: c for c in s['commands']}
    require(len(commands) == len(s['commands']), 'Duplicate command label')
    for c in commands.values():
        require(c['exit_code'] == 0, 'Nonzero command: ' + c['label'])
        require(bool(re.search(r'EXIT_CODE=0\s*$', text(c['log']))), 'Missing successful exit marker')
        if '_build' in c['label'] or '_audit_' in c['label']:
            require(not re.search(r'(?m)^.*(?:warning:|error:)', text(c['log'])),
                    'Diagnostic in accepted build/audit: ' + c['label'])
    all_names, occurrences, examples, audits = set(), 0, 0, 0
    for key, gate in registry.items():
        checked = {}
        for idx, (audit, names) in enumerate(gate['audits'].items()):
            file = (PurePosixPath('source') / gate['package'] / audit).as_posix()
            source = text(file)
            targets = re.findall(r'^#print axioms\s+(\S+)\s*$', source, re.M)
            require(targets == names, 'Audit registry mismatch: ' + audit)
            examples += len(re.findall(r'^example\b', source, re.M)); audits += 1
            output = text(commands[f'{key}_audit_{idx}']['log'])
            for name in names:
                n = re.escape(name)
                empty = re.findall(rf"'{n}'\s+does not depend on any axioms", output)
                reports = re.findall(rf"'{n}'\s+depends on axioms:\s*\[([^\]]*)\]", output, re.S)
                require(len(empty) + len(reports) == 1, 'Missing/duplicate axiom report: ' + name)
                axioms = set() if empty else {a.strip() for a in reports[0].split(',') if a.strip()}
                require(axioms <= ALLOW, 'Rejected axiom: ' + name)
                checked[name] = sorted(axioms); all_names.add(name); occurrences += 1
        require(checked == s['gates'][key]['axioms'], 'Summary/raw-report mismatch: ' + key)
    ownership = 0
    for name in data:
        if name.startswith('module_resolution/') and name.endswith('.json'):
            entries = load(name); ownership += len(entries)
            require(all(e['correct_owner'] and e['object_exists'] and e['expected'] == e['resolved']
                        for e in entries), 'Module ownership mismatch: ' + name)
    closure = load('dependency_closure/pntplus.json')
    require(closure['status'] == 'SOURCE_CLOSURE_CLEAN', 'Rejected PNT+ source-scan record')
    require(closure['module_count'] == len(closure['modules']) == 14, 'PNT+ closure count mismatch')
    require(all(not m['forbidden_tokens'] for m in closure['modules'].values()), 'Forbidden source-scan finding')
    require(closure['compat_sha256'] == digest('source/research/Erdos647Research/Compat/PNTPlus.lean'),
            'PNT+ compatibility source mismatch')
    for pkg, deps in s['dependencies'].items():
        lock = load((PurePosixPath('source') / pkg / 'lake-manifest.json').as_posix())
        require({p['name']: p['rev'] for p in lock['packages'] if p['type'] == 'git'} == deps,
                'Dependency lock mismatch: ' + pkg)
    tooling = re.search(r'Ran (\d+) tests', text('logs/001_tooling_tests.log'))
    require(tooling is not None, 'Missing tooling test count')
    require(not s['endpoint_proved'], 'Unexpected endpoint acceptance claim')
    return {
        'status': 'CONSISTENT_RECORDED_EVIDENCE', 'run_id': NAME,
        'manifest_entries': len(manifest), 'source_snapshot_entries': len(after),
        'passing_gates': len(registry), 'successful_commands': len(commands),
        'distinct_audited_declarations': len(all_names), 'axiom_report_occurrences': occurrences,
        'exact_type_examples': examples, 'audit_files': audits,
        'module_resolution_records': ownership, 'tooling_tests': int(tooling[1]),
        'cache_actions': s['cache_actions'], 'endpoint_proved': False,
        'proof_execution_performed_by_this_script': False,
    }


if __name__ == '__main__':
    try:
        path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).with_name(NAME + '.zip')
        print(json.dumps(check(path), indent=2))
    except (ValueError, KeyError, OSError) as error:
        print('EVIDENCE_CHECK_FAILED: ' + str(error), file=sys.stderr)
        raise SystemExit(1)
