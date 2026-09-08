"""Read-only consistency review of the supplied v42 result bundle.
This does not execute Lean. Requires the extracted run directory as argument.
"""
from pathlib import Path
import hashlib, importlib.util, json, re, sys, zipfile

root=Path(sys.argv[1]).resolve()
source=root/'source'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
manifest=json.loads((root/'MANIFEST.json').read_text())
for name,digest in manifest.items():
    p=root/name
    assert p.is_file(),f'missing evidence: {name}'
    assert sha(p)==digest,f'evidence hash mismatch: {name}'
s=json.loads((root/'summary.json').read_text())
assert s['status']=='PASS_SELECTED_CHECKS'
assert s['scope']=='all'
assert s['source_sha256_before']==s['source_sha256_after']
assert not s['source_changes'] and not s['package_errors']
for name,digest in s['source_sha256_before'].items():
    assert sha(source/name)==digest, f'source mismatch: {name}'
sp=importlib.util.spec_from_file_location('bundle_checker',source/'scripts/check.py')
check=importlib.util.module_from_spec(sp);sp.loader.exec_module(check)
check.source_boundary(source)
assert s['selected_gates']==list(check.GATES)
assert list(s['gates'])==list(check.GATES)
commands={c['label']:c for c in s['commands']}
assert len(commands)==len(s['commands'])
for c in s['commands']:
    assert c['exit_code']==0,c
    assert re.search(r'\bEXIT_CODE=0\s*$',(root/c['log']).read_text()),c['log']
axioms={};examples={};audit_paths=[];diagnostics=[]
for gate,meta in check.GATES.items():
    result=s['gates'][gate]
    assert result['status']=='PASS',gate
    assert gate+'_build' in commands,gate
    for i,(filename,targets) in enumerate(meta['audits'].items()):
        c=commands[f'{gate}_audit_{i}']
        assert c['command'][-1]==filename
        assert '-DwarningAsError=true' in c['command']
        text=(root/c['log']).read_text()
        path=source/meta['package']/filename
        # meta['package'] is '.' or 'research'.
        declared=re.findall(r'^#print axioms (\S+)',path.read_text(),re.M)
        assert declared==targets,(path,declared,targets)
        audit_paths.append(path)
        examples[str(path.relative_to(source))]=len(re.findall(r'^example\b',path.read_text(),re.M))
        for name in targets:
            parsed=check.parse_axioms(text,name)
            assert parsed==result['axioms'][name],name
            if name in axioms: assert axioms[name]==parsed,name
            axioms[name]=parsed
for c in s['commands']:
    if c['label'].endswith('_build') or '_audit_' in c['label']:
        text=(root/c['log']).read_text()
        assert not check.lean_warnings(text),c['label']
        assert not re.search(r'(?:^|\n)(?:[^\n]*:\d+:\d+:\s*)?error:',text,re.I),c['label']
closure=json.loads((root/'dependency_closure/pntplus.json').read_text())
assert closure['status']=='SOURCE_CLOSURE_CLEAN' and not closure['errors']
assert s['toolchain']==(source/'lean-toolchain').read_text().strip()==check.PINS['toolchain']
for pkg,rows in s['dependencies'].items():
    mf=json.loads((source/pkg/'lake-manifest.json').read_text())
    for row in mf['packages']:
        if row['type']=='git':
            actual=rows[row['name']]
            assert actual==row['rev'],(pkg,row,actual)
math=list((source/'Erdos647Sieve').rglob('*.lean'))+[source/'Erdos647Sieve.lean']+list((source/'research/Erdos647Research').rglob('*.lean'))
new=[name for gate in ('endpoint_prime_mass_gap','endpoint_mass_budget_bounds') for name in s['gates'][gate]['axioms']]
tooling=(root/commands['tooling_tests']['log']).read_text()
test_count=int(re.search(r'Ran (\d+) tests',tooling)[1])
assert '\nOK\n' in tooling
report={
 'review_kind':'returned_source_log_and_axiom_consistency',
 'run_id':s['run_id'],'received_archive_role':'newest user upload, supersedes earlier diagnostic',
 'status':'ACCEPTED_AT_RECORDED_BUILD_TYPE_AXIOM_STANDARD',
 'gates_passed':len(check.GATES),'gates_total':len(check.GATES),
 'manifest_entries_verified':len(manifest),'source_hashes_verified':len(s['source_sha256_before']),
 'commands_verified':len(commands),'distinct_audited_declarations':len(axioms),
 'newly_accepted_declarations':len(new),'new_declarations':new,
 'audit_files':len(set(audit_paths)),'exact_type_and_definition_examples':sum(examples.values()),
 'new_type_and_definition_examples':sum(v for k,v in examples.items() if k.endswith(('EndpointPrimeMassGap.lean','EndpointMassBudgetBounds.lean'))),
 'mathematical_modules':len(math),'warnings_in_build_and_audit_logs':0,
 'source_changes_during_run':s['source_changes'],'tooling_tests_in_user_run':test_count,
 'toolchain':s['toolchain'],'compiler_version':s['compiler_version'],
 'cache_actions':s['cache_actions'],'dependency_revisions_verified_by_package':{k:len(v) for k,v in s['dependencies'].items()},
 'retained_pntplus_modules':closure['module_count'],
 'allowed_axioms':sorted(check.ALLOW),
 'fixed_gap':{'numerator':3,'denominator':2,'assumes_nonnegative_budget':False},
 'endpoint_proved':False,'endpoint_coefficient':None,
 'pr_readiness':'local acceptance condition satisfied for supplied gap-and-size snapshot; remote diff and CI not assessed',
}
(root.parent/'REVIEW.json').write_text(json.dumps(report,indent=2)+'\n')
(root.parent/'AUDITED_DECLARATIONS.json').write_text(json.dumps(axioms,indent=2)+'\n')
(root.parent/'CHECKED_MATH_SOURCE_SHA256.json').write_text(json.dumps({str(p.relative_to(source)):sha(p) for p in sorted(math)},indent=2)+'\n')
print(json.dumps(report,indent=2))
