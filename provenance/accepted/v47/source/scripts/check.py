#!/usr/bin/env python3
"""Incremental, fail-closed repository checks.

The v34 overlay retires exactly the recorded obsolete module paths once, preserving
originals in provenance. Ordinary checks never synchronize or rewrite proof bodies.

Lake owns build invalidation. This runner always reruns the selected exact-type and
axiom audits; a cached build is not silently reported as a fresh audit. Python 3.10+.
"""
from __future__ import annotations

import argparse
from contextlib import contextmanager
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import signal
import subprocess
import sys
import time
import uuid
import zipfile

# Local helper; never resolves from an installed third-party Python package.
sys.path.insert(0, str(Path(__file__).resolve().parent))
from pntplus_closure import inspect_closure

ROOT = Path(__file__).resolve().parents[1]
PINS = json.loads((ROOT / 'scripts/pins.json').read_text())
GATES = json.loads((ROOT / 'scripts/gates.json').read_text())
ALLOW = frozenset(PINS['allowed_axioms'])
FORBIDDEN = re.compile(r'\b(?:sorry|admit|axiom|native_decide)\b|debug\.skipKernelTC|'
                       r'\b(?:Lean\.)?ofReduce(?:Bool|Nat)\b|\bdecide\s*\+native\b|'
                       r'\bset_option\s+(?:warningAsError|linter(?:\.[A-Za-z0-9_]+)*)\s+false\b')
IGNORED = {'.git', '.lake', '.tools', '.audit', 'results', '__pycache__', '.venv'}
SOURCE_ROOTS = ('Erdos647Sieve', 'Examples', 'Audit', 'scripts', 'tests', 'research', 'docs', '.github')
TOP_FILES = ('Erdos647Sieve.lean', 'lakefile.lean', 'lake-manifest.json', 'lean-toolchain',
             'RUN.sh', 'TEST_ALL.sh', '.gitignore', '.gitattributes', 'README.md', 'LICENSE', 'NOTICE', 'CONTRIBUTING.md', 'AGENTS.md')


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def atomic_json(path: Path, data: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(path.name + '.tmp')
    tmp.write_text(json.dumps(data, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    tmp.replace(path)


def strip_comments(text: str) -> str:
    """Remove nested Lean comments. String contents are preserved for a conservative scan."""
    out, i, depth = [], 0, 0
    while i < len(text):
        if text.startswith('/-', i): depth += 1; i += 2
        elif depth and text.startswith('-/', i): depth -= 1; i += 2
        elif depth: i += 1
        elif text.startswith('--', i):
            j = text.find('\n', i); i = len(text) if j < 0 else j
        elif text[i] == '"':
            out.append(text[i]); i += 1
            while i < len(text):
                c = text[i]; out.append(c); i += 1
                if c == '\\' and i < len(text): out.append(text[i]); i += 1
                elif c == '"': break
        else: out.append(text[i]); i += 1
    if depth: raise ValueError('Unterminated Lean block comment')
    return ''.join(out)


def imports(text: str) -> list[str]:
    return [n for line in re.findall(r'^\s*(?:public\s+)?import\s+([^\n]+)', strip_comments(text), re.M)
            for n in line.split()]


def parse_axioms(text: str, name: str) -> list[str]:
    escaped = re.escape(name)
    empty = list(re.finditer(rf"'{escaped}'\s+does not depend on any axioms", text))
    reports = list(re.finditer(rf"'{escaped}'\s+depends on axioms:\s*\[([^\]]*)\]", text, re.S))
    if len(empty) + len(reports) != 1:
        raise ValueError('Missing or duplicate axiom report: ' + name)
    axioms = set() if empty else {a.strip() for a in reports[0][1].split(',') if a.strip()}
    if axioms - ALLOW:
        raise ValueError(f'{name}: rejected axioms {sorted(axioms - ALLOW)}')
    return sorted(axioms)


def source_files(root: Path = ROOT) -> list[Path]:
    """Only source/configuration; never follow .lake links or collect credentials."""
    files = [root / n for n in TOP_FILES if (root / n).is_file()]
    for name in SOURCE_ROOTS:
        start = root / name
        if not start.is_dir(): continue
        for directory, dirs, names in os.walk(start, followlinks=False):
            dirs[:] = sorted(d for d in dirs if d not in IGNORED and not (Path(directory)/d).is_symlink())
            for n in sorted(names):
                p = Path(directory) / n
                if not p.is_symlink() and p.suffix in {'.lean', '.py', '.sh', '.toml', '.json', '.md', '.yml', '.yaml'}:
                    files.append(p)
                elif n == 'lean-toolchain' and not p.is_symlink(): files.append(p)
    return sorted(set(files))


def snapshots(root: Path = ROOT) -> dict[str, str]:
    return {p.relative_to(root).as_posix(): sha(p) for p in source_files(root)}


def changed_sources(before: dict[str, str], after: dict[str, str]) -> dict[str, dict]:
    """List changed inputs. CI scheduling metadata does not affect a local proof run."""
    changes = {}
    for name in sorted(before.keys() | after.keys()):
        if before.get(name) != after.get(name):
            workflow = name.startswith('.github/') and Path(name).suffix in {'.yml', '.yaml'}
            changes[name] = {'before': before.get(name), 'after': after.get(name),
                             'role': 'ci_metadata' if workflow else 'checked_input'}
    return changes


def check_source_changes(record: dict, before: dict[str, str], after: dict[str, str]) -> None:
    changes = changed_sources(before, after)
    record['source_sha256_after'] = after
    record['source_changes'] = changes
    critical = [name for name, entry in changes.items() if entry['role'] == 'checked_input']
    metadata = [name for name, entry in changes.items() if entry['role'] == 'ci_metadata']
    if metadata:
        record.setdefault('warnings', []).append(
            'CI metadata changed during the local run (recorded separately): ' + ', '.join(metadata))
    if critical:
        raise ValueError('Checked source/configuration changed during checks: ' + ', '.join(critical))


def retire_v33_module_paths(root: Path) -> list[dict]:
    """One-time overlay rename, not a source-sync/backup framework.

    ZIP extraction cannot remove old paths. Only the 13 exact predecessor files
    recorded in the move manifest may be retired; originals stay in provenance.
    A fresh checkout with no obsolete files is a no-op, including after later
    edits to the new source paths. All conflicts are checked before any move.
    """
    manifest = root / 'scripts/module_moves_v34.json'
    moves = json.loads(manifest.read_text())['moves']
    pending = []
    def local(name: str) -> Path:
        rel = Path(name)
        if rel.is_absolute() or '..' in rel.parts:
            raise ValueError('Invalid module relocation path: ' + name)
        target = root / rel
        cursor = root
        for part in rel.parts:
            cursor = cursor / part
            if cursor.is_symlink():
                raise ValueError('Symlink in module relocation path: ' + name)
        return target
    for entry in moves:
        old_name, new_name = Path(entry['old']), Path(entry['new'])
        ordinary = (old_name.parent == Path('research/Erdos647Sieve')
                    and old_name.suffix == '.lean'
                    and new_name == Path('research/Erdos647Research') / old_name.name)
        shim = (old_name == Path('research/PrimeNumberTheoremAnd/RosserSchoenfeldPrime.lean')
                and new_name == Path('research/Erdos647Research/Compat/PNTPlus.lean'))
        if not (ordinary or shim):
            raise ValueError('Move is outside the v34 module relocation: ' + entry['old'])
        old = local(entry['old'])
        if not old.exists():
            continue
        new = local(entry['new'])
        archive_name = 'provenance/refactors/v34/retired/' + entry['old']
        archive = local(archive_name)
        if not old.is_file() or sha(old) != entry['old_sha256']:
            raise ValueError('Edited obsolete module; preserved without moving: ' + entry['old'])
        if not new.is_file() or sha(new) != entry['new_sha256']:
            raise ValueError('Replacement module does not match relocation: ' + entry['new'])
        if archive.exists() and (not archive.is_file() or sha(archive) != entry['old_sha256']):
            raise ValueError('Conflicting module provenance; nothing moved: ' + archive_name)
        pending.append((entry, old, archive, archive_name))
    recorded = []
    for entry, old, archive, archive_name in pending:
        archive.parent.mkdir(parents=True, exist_ok=True)
        if archive.exists():
            old.unlink()  # Only after verifying the identical archived original above.
        else:
            old.rename(archive)
        recorded.append({**entry, 'archive': archive_name})
    return recorded


def resolve_module_object(module: str, search_paths: list[Path]) -> Path | None:
    """Mirror Lean 4.32.2 SearchPath.findWithExt, including first-root selection.

    A later exact file must NOT mask a collision with an earlier package root.
    Reference: lean4/v4.32.2/src/Lean/Util/Path.lean, lines 53-66.
    """
    parts = module.split('.')
    if not parts or any(not part or not re.fullmatch(r'[A-Za-z_][A-Za-z0-9_]*', part)
                        for part in parts):
        raise ValueError('Unsupported module identifier for path audit: ' + module)
    for path in search_paths:
        path = Path(path)
        if (path / parts[0]).is_dir() or (path / (parts[0] + '.olean')).exists():
            return path.joinpath(*parts).with_suffix('.olean')
    return None


def gate_module_sources(root: Path, gate: dict) -> dict[str, tuple[Path, Path]]:
    """Actual project imports and their owners; no traversal of upstream source."""
    pending = []
    package = root / gate['package']
    for file in gate['audits']:
        pending.extend(imports((package / file).read_text()))
    if gate['package'] == '.':
        pending.extend('Examples.' + p.stem for p in (root / 'Examples').glob('*.lean'))
    found = {}
    while pending:
        name = pending.pop()
        if name in found or name == 'Mathlib' or name.startswith('Mathlib.'):
            continue
        first = name.split('.')[0]
        if first in {'Erdos647Sieve', 'Examples'}:
            owner = root
        elif first == 'Erdos647Research' and gate['package'] == 'research':
            owner = root / 'research'
        elif first == 'PrimeNumberTheoremAnd' and gate['package'] == 'research':
            owner = root / 'research/.lake/packages/PrimeNumberTheoremAnd'
        else:
            raise ValueError('Unregistered module owner: ' + name)
        rel = Path(*name.split('.')).with_suffix('.lean')
        src = owner / rel
        if not src.is_file():
            raise ValueError('Missing owned source module: ' + name)
        expected = owner / '.lake/build/lib/lean' / rel.with_suffix('.olean')
        found[name] = (src, expected)
        if first != 'PrimeNumberTheoremAnd':
            pending.extend(imports(src.read_text()))
    return found


def source_boundary(root: Path = ROOT, include_research: bool = True) -> None:
    if sha(root/'Erdos647Sieve/Specification.lean') != PINS['specification_sha256']:
        raise ValueError('Protected Specification.lean changed; review its exact statements explicitly.')
    scopes = ['.'] + (['research'] if include_research else [])
    for scope in scopes:
        package = root / scope
        if (package/'lean-toolchain').read_text().strip() != PINS['toolchain']:
            raise ValueError(f'{scope}: compiler pin differs from scripts/pins.json')
        lock = json.loads((package/'lake-manifest.json').read_text())
        # Manifest names are serialized Lean Names, not arbitrary display strings.
        # In particular, a hyphenated component must retain its «...» escaping.
        declared = re.search(r'^\s*package\s+(\S+)', strip_comments((package/'lakefile.lean').read_text()), re.M)
        if declared is None or lock.get('name') != declared[1]:
            raise ValueError(f'{scope}: manifest package name must match the escaped Lean identifier in lakefile.lean')
        config = strip_comments((package/'lakefile.lean').read_text())
        for block in re.split(r'(?m)^lean_lib\s+', config)[1:]:
            if 'moreLeanArgs := #["-DwarningAsError=true"]' not in block.split('script audit', 1)[0]:
                raise ValueError('Project library must promote warnings to errors: ' + block.split()[0])
        entries = lock['packages']
        if len({p['name'] for p in entries}) != len(entries): raise ValueError('Duplicate dependency name')
        actual = {p['name']:p['rev'] for p in entries if p['type']=='git'}
        if actual != PINS['dependencies'][scope]: raise ValueError(f'{scope}: dependency lock differs from pins')
        local = [p for p in entries if p['type']=='path']
        if scope=='.' and local: raise ValueError('Core may not depend on a local research package')
        if scope=='research' and (len(local)!=1 or local[0]['name']!='«erdos647-sieve»' or local[0]['dir']!='..'):
            raise ValueError('Research must use the single local core dependency')
    # The public package cannot acquire accidental PNT+ or research imports.
    for base in ('Erdos647Sieve','Examples','Audit','Erdos647Sieve.lean'):
        paths = [root/base] if base.endswith('.lean') else (root/base).rglob('*.lean')
        for p in paths:
            if p.is_symlink(): raise ValueError('Symlinked public proof: '+str(p))
            text=p.read_text()
            if FORBIDDEN.search(strip_comments(text)): raise ValueError('Forbidden proof shortcut: '+str(p))
            for name in imports(text):
                if name=='Mathlib' or name.startswith('Mathlib.'): continue
                if name=='Erdos647Sieve' or name.startswith('Erdos647Sieve.'):
                    if (root/(name.replace('.','/')+'.lean')).is_file(): continue
                raise ValueError('Public import crosses the package boundary: '+name)
    if include_research:
        # Lean resolves a module's FIRST component before looking for its leaf.
        # Splitting Erdos647Sieve.* across Lake packages is therefore not safe.
        for oldroot in ('Erdos647Sieve', 'PrimeNumberTheoremAnd'):
            if any((root/'research'/oldroot).rglob('*.lean')):
                raise ValueError('Research source uses a dependency-owned module root: ' + oldroot)
        if (root/'Erdos647Research').exists() or (root/'Erdos647Research.lean').exists():
            raise ValueError('Core may not own the research module root')
        for p in (root/'research').rglob('*.lean'):
            if '.lake' in p.parts or 'docs' in p.parts or p.name == 'lakefile.lean': continue
            if p.is_symlink(): raise ValueError('Symlinked research proof: '+str(p))
            if p.relative_to(root/'research').parts[0] not in {'Erdos647Research', 'Audit'}:
                raise ValueError('Unregistered research module root: ' + str(p))
            if FORBIDDEN.search(strip_comments(p.read_text())): raise ValueError('Forbidden proof shortcut: '+str(p))
            for name in imports(p.read_text()):
                if name=='Mathlib' or name.startswith('Mathlib.'): continue
                if name.startswith('PrimeNumberTheoremAnd.'):
                    if p.relative_to(root).as_posix() == 'research/Erdos647Research/Compat/PNTPlus.lean': continue
                    raise ValueError('PNT+ import escaped analytic compatibility boundary: '+str(p))
                path=name.replace('.','/')+'.lean'
                if (root/path).is_file() or (root/'research'/path).is_file(): continue
                raise ValueError('Unresolved project import: '+name)
        registered={g['build'][0].lstrip('+') for g in GATES.values() if g['package']=='research'}
        registered.add('Erdos647Research.Compat.PNTPlus')
        owned={'.'.join(p.relative_to(root/'research').with_suffix('').parts)
               for p in (root/'research/Erdos647Research').rglob('*.lean')}
        if owned != registered:
            raise ValueError('Research source/audit registry mismatch; register new modules in gates.json')
    for gate in GATES.values():
        if gate['package']=='research' and not include_research: continue
        for path, targets in gate['audits'].items():
            text=(root/gate['package']/path).read_text()
            printed=re.findall(r'^#print axioms\s+(\S+)\s*$',text,re.M)
            if printed != targets: raise ValueError('Audit file/target registry mismatch: '+path)


def lean_warnings(text: str) -> list[str]:
    """Cached warning replay is still a lint failure, never a new clean PASS."""
    clean = re.sub(r'\x1b\[[0-9;]*m', '', text)
    return list(dict.fromkeys(line for line in clean.splitlines()
        if re.match(r'^\s*warning:', line) or re.search(r'\.lean:\d+:\d+:\s*warning:', line)))


def clean_env() -> dict[str, str]:
    env = os.environ.copy()
    # lake test inherits a workspace environment: reconstruct it for each package.
    for key in list(env):
        if (key.startswith('LEAN_') and key != 'LEAN_NUM_THREADS') or key.startswith('LAKE_') or key in {'LAKE', 'LEAN'}:
            env.pop(key, None)
    env.update(PYTHONDONTWRITEBYTECODE='1', NO_COLOR='1', ELAN_TOOLCHAIN=PINS['toolchain'])
    return env


def redact(text: str, root: Path = ROOT) -> str:
    for path, label in sorted([(str(root),'<REPO>'),(str(Path.home()),'<HOME>')], key=lambda x:-len(x[0])):
        if len(path)>3: text=text.replace(path,label)
    text=re.sub(r'(https?://)[^\s/@]+:[^\s/@]+@',r'\1<REDACTED>@',text)
    text=re.sub(r'\b(?:gh[pousr]_[A-Za-z0-9_]+|github_pat_[A-Za-z0-9_]+)\b','<REDACTED>',text)
    return text


@contextmanager
def run_lock(root: Path):
    """A process-held lock is released on crash; there is no stale lock-file protocol."""
    import fcntl
    folder=root/'.tools'; folder.mkdir(exist_ok=True)
    if folder.is_symlink(): raise ValueError('Refusing symlinked .tools directory')
    with (folder/'run.lock').open('a') as f:
        try: fcntl.flock(f,fcntl.LOCK_EX|fcntl.LOCK_NB)
        except BlockingIOError as exc: raise RuntimeError('Another repository check is running') from exc
        try: yield
        finally: fcntl.flock(f,fcntl.LOCK_UN)


class Run:
    def __init__(self, root: Path, args: argparse.Namespace):
        self.root=root; self.args=args; self.env=clean_env(); self.commands=0
        if args.jobs: self.env['LEAN_NUM_THREADS']=str(args.jobs)
        self.id='erdos647_repo_v47_results_'+datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')+'_'+uuid.uuid4().hex[:8]
        self.dest=root/'results'/self.id
        if (root/'results').is_symlink(): raise ValueError('Refusing symlinked results directory')
        self.dest.mkdir(parents=True,exist_ok=False)
        self.record={'schema':1,'run_id':self.id,'started_utc':datetime.now(timezone.utc).isoformat(),
            'status':'RUNNING','scope':args.scope,'setup_requested':args.setup,'gates':{},'commands':[],
            'toolchain':PINS['toolchain'],'incremental_builds':'Lake traces; audits rerun on every selected invocation',
            'endpoint_proved':False,'historical_reports_are_current_results':False}
        self.lean=None; self.lake=None; self.save()

    def save(self): atomic_json(self.dest/'summary.json',self.record)

    def command(self, label: str, cmd: list[str], cwd: Path | None = None, allow_failure=False) -> tuple[int,str]:
        self.commands+=1; out=self.dest/'logs'/f'{self.commands:03d}_{label}.log';out.parent.mkdir(exist_ok=True)
        item={'label':label,'command':cmd,'cwd':str(cwd or self.root),'log':str(out.relative_to(self.dest)),
              'exit_code':None};self.record['commands'].append(item);self.save()
        chunks=[];rc=None
        with out.open('w',encoding='utf-8') as stream:
            stream.write('$ '+shlex.join(cmd)+'\n');stream.flush()
            try:
                p=subprocess.Popen(cmd,cwd=cwd or self.root,env=self.env,stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT,text=True,encoding='utf-8',errors='replace',start_new_session=True)
                assert p.stdout is not None
                try:
                    for line in p.stdout:
                        sys.stdout.write(line);sys.stdout.flush();stream.write(line);stream.flush();chunks.append(line)
                    rc=p.wait()
                finally:
                    p.stdout.close()
                    if p.poll() is None:
                        os.killpg(p.pid,signal.SIGTERM)
                        try:p.wait(timeout=10)
                        except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);p.wait()
            except OSError as exc:
                rc=127;stream.write(str(exc)+'\n');chunks.append(str(exc))
            finally:
                stream.write(f'\nEXIT_CODE={rc if rc is not None else 130}\n')
                item['exit_code']=rc if rc is not None else 130;self.save()
        if rc and not allow_failure:raise RuntimeError(f'{label}: exit {rc}; see {out.relative_to(self.dest)}')
        return int(rc or 0),''.join(chunks)

    def compiler(self):
        tcname=PINS['toolchain'].replace('/','--').replace(':','---')
        homes=[self.root/'.tools/elan']
        if os.environ.get('ELAN_HOME'): homes.append(Path(os.environ['ELAN_HOME']).expanduser())
        homes.append(Path.home()/'.elan')
        candidates=[h/'toolchains'/tcname/'bin' for h in homes]
        native=shutil.which('lean',path=self.env['PATH'])
        if native:
            elan=shutil.which('elan',path=self.env['PATH'])
            is_shim=bool(elan and os.path.samefile(native,elan))
            parent=Path(native).resolve().parent
            # Avoid invoking a missing-toolchain Elan shim in reuse-only mode.
            if not is_shim and not (parent.name=='bin' and parent.parent.name=='elan') and '.elan/bin' not in str(parent):
                candidates.append(parent)
        for folder in dict.fromkeys(candidates):
            if all((folder/x).is_file() for x in ('lean','lake')):
                rc,version=self.command('compiler_probe',[str(folder/'lean'),'--version'],allow_failure=True)
                if not rc and re.search(r'\bversion\s+'+re.escape(PINS['lean_version'])+r'(?=[,\s)]|$)',version,re.I):
                    self.lean=str(folder/'lean');self.lake=str(folder/'lake');break
        if self.lean is None:
            if not self.args.setup:
                raise RuntimeError('Pinned Lean is missing. Setup is available through RUN.sh --setup (alias --upgrade).')
            for binary in ('git','curl','sh','tar'):
                if not shutil.which(binary): raise RuntimeError('Missing system prerequisite: '+binary)
            home=self.root/'.tools/elan';home.parent.mkdir(parents=True,exist_ok=True)
            self.env['ELAN_HOME']=str(home)
            elan=home/'bin/elan'
            if not elan.is_file():
                installer=home.parent/'elan-init.sh'
                self.command('download_elan',['curl','--fail','--show-error','--location','--proto','=https',
                    '--tlsv1.2','--connect-timeout','20','--max-time','300','--retry','2',
                    'https://raw.githubusercontent.com/leanprover/elan/v4.1.2/elan-init.sh','-o',str(installer)])
                if not installer.read_bytes().startswith(b'#!/bin/sh'): raise RuntimeError('Unexpected Elan installer format')
                self.record['bootstrap_installer_sha256']=sha(installer)
                self.command('install_elan',['sh',str(installer),'-y','--no-modify-path','--default-toolchain','none'])
            self.command('install_pinned_lean',[str(elan),'toolchain','install',PINS['toolchain']])
            folder=home/'toolchains'/tcname/'bin';self.lean=str(folder/'lean');self.lake=str(folder/'lake')
        folder=Path(self.lean).parent
        self.env['PATH']=str(folder)+os.pathsep+self.env.get('PATH','')
        _,ver=self.command('lean_version',[self.lean,'--version'])
        if not re.search(r'\bversion\s+'+re.escape(PINS['lean_version'])+r'(?=[,\s)]|$)',ver,re.I):raise RuntimeError('Wrong compiler version')
        self.command('lake_version',[self.lake,'--version'])
        _,prefix=self.command('lean_prefix',[self.lean,'--print-prefix']);self.prefix=Path(prefix.strip())
        self.record['compiler_version']=ver.strip();self.save()

    def git(self, directory: Path, *args: str) -> str:
        return subprocess.check_output(['git','-C',str(directory),*args],env=self.env,text=True,stderr=subprocess.PIPE).strip()

    def verify_dependency(self, path: Path, entry: dict):
        if self.git(path,'rev-parse','HEAD')!=entry['rev']:raise ValueError('Wrong installed revision: '+entry['name'])
        if self.git(path,'diff','--name-only','HEAD','--'):raise ValueError('Modified dependency: '+entry['name'])
        loose=self.git(path,'ls-files','--others','--exclude-standard').splitlines()
        if any(x.endswith('.lean') or Path(x).name in {'lakefile.toml','lakefile.lean','lean-toolchain','lake-manifest.json'} for x in loose):
            raise ValueError('Untracked dependency proof/configuration: '+entry['name'])

    def checkout(self, path: Path, entry: dict):
        if not path.exists():
            if not self.args.setup:raise RuntimeError('Missing dependency '+entry['name']+'; use RUN.sh --setup')
            path.mkdir(parents=True)
        if not (path/'.git').exists():
            if any(path.iterdir()):raise ValueError('Refusing non-Git dependency directory: '+str(path))
            if not self.args.setup:raise RuntimeError('Uninitialized dependency '+entry['name'])
            self.command('git_init_'+entry['name'],['git','init','-q',str(path)])
            self.command('git_origin_'+entry['name'],['git','remote','add','origin',entry['url']],path)
        try:head=self.git(path,'rev-parse','--verify','HEAD')
        except subprocess.CalledProcessError:head=None
        if head is None:
            if not self.args.setup:raise RuntimeError('Incomplete dependency '+entry['name']+'; use --setup')
            if self.git(path,'status','--porcelain'):raise ValueError('Unexpected files in incomplete dependency '+entry['name'])
            self.command('git_fetch_'+entry['name'],['git','fetch','--depth','1',entry['url'],entry['rev']],path)
            self.command('git_checkout_'+entry['name'],['git','checkout','--detach','FETCH_HEAD'],path)
        self.verify_dependency(path,entry)

    def prepare(self, scope: str):
        package=self.root/scope
        lock=json.loads((package/'lake-manifest.json').read_text());deps={}
        for e in lock['packages']:
            if e['type']=='path':continue
            path=package/'.lake/packages'/e['name']
            # Optional local sharing is version-checked and never checked into Git.
            if scope=='research' and self.args.setup and not path.exists() and not path.is_symlink():
                common=self.root/'.lake/packages'/e['name']
                if common.exists() and PINS['dependencies']['.'].get(e['name'])==e['rev']:
                    self.verify_dependency(common,e);path.parent.mkdir(parents=True,exist_ok=True)
                    path.symlink_to(os.path.relpath(common,path.parent),target_is_directory=True)
            if path.is_symlink() and not path.exists():raise ValueError('Broken dependency cache link: '+str(path))
            self.checkout(path,e);deps[e['name']]=e['rev']
        self.record.setdefault('dependencies',{})[scope]=deps
        mathlib=package/'.lake/packages/mathlib'
        marker=mathlib/'.lake/erdos647-cache-ready.json'
        sentinel=mathlib/'.lake/build/lib/lean/Mathlib.olean'
        # A failed first setup can leave valid repositories but no compiled Mathlib.
        # Resume only that cache step. Tool/repository installation still requires --setup.
        cache_missing = not sentinel.exists()
        if cache_missing or (self.args.setup and (self.args.refresh_cache or not marker.exists())):
            self.record.setdefault('cache_actions', {})[scope] = (
                'resume_missing_pinned_cache' if cache_missing else 'explicit_cache_refresh')
            self.save()
            self.command('mathlib_cache_'+('core' if scope=='.' else 'research'),[self.lake,'exe','cache','get'],package)
            if not sentinel.exists():raise RuntimeError('Mathlib cache completed without Mathlib.olean')
            atomic_json(marker,{'toolchain':PINS['toolchain'],'mathlib':PINS['mathlib_revision']})
        else:
            self.record.setdefault('cache_actions', {})[scope] = 'reuse_existing'
        # Verify the actual resolved compiled-library search path.
        _,raw=self.command('search_path_'+('core' if scope=='.' else 'research'),
            [self.lake,'env','python3','-c',"import os,json; print(json.dumps(os.environ.get('LEAN_PATH','').split(os.pathsep)))"],package)
        paths=json.loads(raw.strip().splitlines()[-1])
        allowed={(package/'.lake/build/lib/lean').resolve(),(self.prefix/'lib/lean').resolve()}
        allowed.update((package/'.lake/packages'/n/'.lake/build/lib/lean').resolve() for n in deps)
        if scope=='research':allowed.add((self.root/'.lake/build/lib/lean').resolve())
        observed=[(package/Path(p)).resolve() if not Path(p).is_absolute() else Path(p).resolve() for p in paths if p]
        if not observed or any(p not in allowed for p in observed):
            raise ValueError('Unexpected Lean search path: '+str(observed))
        if (package/'.lake/build/lib/lean').resolve() not in observed:
            raise ValueError('Package build directory absent from Lean search path')
        self.record.setdefault('search_paths',{})[scope]=[str(p) for p in observed];self.save()

    def verify_gate_modules(self, name: str) -> None:
        gate = GATES[name]
        scope = gate['package']
        paths = [Path(p) for p in self.record.get('search_paths', {}).get(scope, [])]
        if not paths:
            raise ValueError('No verified Lean search path for ' + scope)
        rows = []
        failures = []
        for module, (_, expected) in sorted(gate_module_sources(self.root, gate).items()):
            actual = resolve_module_object(module, paths)
            same = actual is not None and actual.resolve() == expected.resolve()
            exists = actual is not None and actual.is_file()
            rows.append({'module': module, 'expected': str(expected),
                         'resolved': str(actual) if actual else None,
                         'correct_owner': same, 'object_exists': exists})
            if not same or not exists:
                failures.append(module + ': expected ' + str(expected) + ', resolved ' + str(actual))
        atomic_json(self.dest / 'module_resolution' / (name + '.json'), rows)
        self.record.setdefault('module_resolution_checks', {})[name] = {
            'count': len(rows), 'passed': not failures}
        self.save()
        if failures:
            raise ValueError('Compiled module ownership check failed: ' + '; '.join(failures))

    def check_pntplus_sources(self):
        upstream = self.root/'research/.lake/packages/PrimeNumberTheoremAnd'
        compat = self.root/'research/Erdos647Research/Compat/PNTPlus.lean'
        report = inspect_closure(upstream, compat)
        atomic_json(self.dest/'dependency_closure/pntplus.json', report)
        self.record['pntplus_source_closure'] = {
            'status':report['status'], 'module_count':report['module_count'],
            'report':'dependency_closure/pntplus.json'}
        # Preserve exact inspected upstream sources, not just the final wrapper.
        for item in report['modules'].values():
            if item.get('missing'): continue
            src = upstream/item['path']
            dst = self.dest/'source_dependencies/PNTPlus'/item['path']
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
        self.save()
        if report['status'] != 'SOURCE_CLOSURE_CLEAN':
            raise ValueError('PNT+ source closure rejected: ' + '; '.join(report['errors']))

    def gate(self, name: str):
        gate=GATES[name];package=self.root/gate['package']
        result={'status':'RUNNING','historical_status':gate['historical_status'],'axioms':{}}
        self.record['gates'][name]=result;self.save()
        try:
            if name == 'pntplus_inputs':
                self.check_pntplus_sources()
            _, build_log = self.command(name+'_build',[self.lake,'build',*gate['build']],package)
            warnings = lean_warnings(build_log)
            result['build_warnings'] = warnings
            if warnings:
                raise ValueError('Build emitted warnings (including replayed warnings): ' + '; '.join(warnings))
            self.verify_gate_modules(name)
            for i,(file,targets) in enumerate(gate['audits'].items()):
                _,log=self.command(name+f'_audit_{i}',[self.lake,'env','lean','-DwarningAsError=true',file],package)
                result['axioms'].update({t:parse_axioms(log,t) for t in targets})
            result['status']='PASS'
        except (OSError,ValueError,RuntimeError,subprocess.SubprocessError) as exc:
            result.update(status='FAIL',error=str(exc))
        self.save();print(f'[{result["status"]}] {name}',flush=True)

    def finish(self):
        record_endpoint_acceptance(self.record)
        self.record['finished_utc']=datetime.now(timezone.utc).isoformat();self.save()
        lines=['# Repository check results','',f'Run: `{self.id}`',f'Status: **{self.record["status"]}**','',
            '| Gate | This invocation |','|---|---|']
        lines += [f'| {k} | {v["status"]} |' for k,v in self.record['gates'].items()]
        if self.record.get('package_errors'):
            lines += ['', '## Setup failures', '']
            lines += [f'- `{scope}`: {error}' for scope, error in self.record['package_errors'].items()]
        failures = [(name, entry) for name, entry in self.record['gates'].items()
                    if entry.get('error') or entry.get('reason')]
        if failures:
            lines += ['', '## Gate details', '']
            lines += [f'- `{name}`: {entry.get("error", entry.get("reason"))}' for name, entry in failures]
        if self.record.get('error'):lines += ['',self.record['error']]
        if self.record.get('warnings'):
            lines += ['', '## Recorded metadata changes', ''] + self.record['warnings']
        lines += ['','Historical proof acceptance is not a current run result.',
                  'A selected failure or blocked gate makes the overall command fail.',
                  ('The fixed-coefficient endpoint passed in this invocation with c=1/1000; '
                   'this is not a resolution of Erdos #647.' if self.record['endpoint_proved'] else
                   'No final endpoint acceptance is established by this invocation.')]
        (self.dest/'SUMMARY.md').write_text('\n'.join(lines)+'\n')
        for p in source_files(self.root):
            dst=self.dest/'source'/p.relative_to(self.root);dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst)
        # Redact only diagnostics. Source must remain byte-exact for reproducing edits.
        for p in self.dest.rglob('*'):
            if p.is_file() and not {'source', 'source_dependencies'} & set(p.relative_to(self.dest).parts):
                p.write_text(redact(p.read_text(errors='replace'),self.root),encoding='utf-8')
        atomic_json(self.dest/'MANIFEST.json',{p.relative_to(self.dest).as_posix():sha(p)
                    for p in self.dest.rglob('*') if p.is_file()})
        report=self.dest.with_suffix('.zip')
        with zipfile.ZipFile(report,'x',zipfile.ZIP_DEFLATED) as z:
            for p in sorted(self.dest.rglob('*')):
                if p.is_file():z.write(p,self.id+'/'+p.relative_to(self.dest).as_posix())
        (self.root/'results/latest_result.txt').write_text(str(report)+'\n')
        print('\nRESULTS ZIP: '+str(report),flush=True)


def record_endpoint_acceptance(record: dict) -> None:
    """Endpoint status comes only from this invocation's successful final audit.

    Static documentation, historical evidence and a clean printed axiom list after
    a failed command never count. A failed overall/source check keeps status false.
    """
    record['endpoint_proved'] = False
    record['endpoint_coefficient'] = None
    record['endpoint_acceptance'] = None
    name = 'endpoint_final'
    if record.get('status') != 'PASS_SELECTED_CHECKS' or name not in record.get('selected_gates', []):
        return
    if record.get('checks_role') != 'BUILD_TYPE_AXIOM':
        return
    before, after = record.get('source_sha256_before'), record.get('source_sha256_after')
    if not before or not after or any(e['role'] == 'checked_input' for e in changed_sources(before, after).values()):
        return
    final = record.get('gates', {}).get(name, {})
    if final.get('status') != 'PASS' or final.get('build_warnings'):
        return
    targets = [t for ts in GATES[name]['audits'].values() for t in ts]
    axioms = final.get('axioms', {})
    if set(axioms) != set(targets) or any(set(axioms[t]) - ALLOW for t in targets):
        return
    needed = set()
    def include(gate):
        if gate in needed:
            return
        needed.add(gate)
        for parent in GATES[gate]['prerequisites']:
            include(parent)
    include(name)
    if any(record.get('gates', {}).get(g, {}).get('status') != 'PASS' for g in needed):
        return
    commands = record.get('commands', [])
    for label in [name + '_build', name + '_audit_0']:
        matching = [c for c in commands if c.get('label') == label]
        if len(matching) != 1 or matching[0].get('exit_code') != 0:
            return
    record['endpoint_proved'] = True
    record['endpoint_coefficient'] = {'numerator': 1, 'denominator': 1000}
    record['endpoint_acceptance'] = {
        'run_id': record['run_id'], 'gate': name,
        'theorem': 'Erdos647Sieve.Endpoint.endpointBound_one_div_thousand',
        'legacy_theorem': 'Erdos647Sieve.endpoint',
        'general_theorem': 'Erdos647Sieve.Endpoint.endpointBound_of_lt_principal_rate',
        'positive_coefficient_range': {'lower_exclusive': 0,
            'upper_exclusive': {'numerator': 1499, 'denominator': 1000000}},
        'positive_claim': 'Erdos647Sieve.Endpoint.positiveEndpoint',
        'is_resolution_of_erdos647': False,
        'basis': 'current build, expanded-type and transitive-axiom audits; stable checked inputs'}


def selected_gates(args: argparse.Namespace) -> list[str]:
    if args.gate:
        requested=list(dict.fromkeys(args.gate))
    elif args.scope=='core':requested=['core']
    elif args.scope=='research':requested=[k for k in GATES if k!='core']
    elif args.scope=='tooling':requested=[]
    else:requested=list(GATES)
    # Explicit prerequisites are selected too, in topological order.
    selected=[]
    def add(k):
        for dep in GATES[k]['prerequisites']:add(dep)
        if k not in selected:selected.append(k)
    for k in requested:add(k)
    return selected


def parser() -> argparse.ArgumentParser:
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('scope',nargs='?',default='all',choices=['all','core','research','tooling'])
    p.add_argument('--setup','--upgrade',action='store_true',dest='setup',help='Install/resume the pinned toolchain and dependencies; no floating upgrade')
    p.add_argument('--refresh-cache',action='store_true',help='With --setup, retry Mathlib cache retrieval')
    p.add_argument('--gate',action='append',choices=list(GATES),help='Check a named gate and its explicit prerequisites')
    p.add_argument('--jobs',type=int,help='Lean worker threads (LEAN_NUM_THREADS)')
    p.add_argument('--list',action='store_true',help='List gates without changing anything')
    p.add_argument('--collect-only',action='store_true',help='Print latest results ZIP; no compiler invocation')
    return p


def main(argv=None) -> int:
    args=parser().parse_args(argv)
    if args.jobs is not None and args.jobs<1:parser().error('--jobs must be positive')
    if args.refresh_cache and not args.setup:parser().error('--refresh-cache requires --setup')
    if args.list:
        for name,g in GATES.items():print(f'{name:30} {g["package"]:8} {g["historical_status"]}')
        return 0
    if args.collect_only:
        latest=ROOT/'results/latest_result.txt'
        if not latest.is_file():print('No completed diagnostic archive exists.',file=sys.stderr);return 2
        print('RESULTS ZIP: '+latest.read_text().strip());return 0
    run=None
    try:
        with run_lock(ROOT):
            run=Run(ROOT,args)
            try:
                selected=selected_gates(args)
                run.record['selected_gates']=selected
                run.record['gates']={k:{'status':'NOT_STARTED' if k in selected else 'NOT_REQUESTED'} for k in GATES}
                run.record['checks_role']='BUILD_TYPE_AXIOM' if selected else 'TOOLING_ONLY'
                include_research = args.scope!='core' or any(GATES[g]['package']=='research' for g in selected)
                run.record['retired_module_paths'] = retire_v33_module_paths(ROOT)
                run.save()
                source_boundary(ROOT,include_research=include_research)
                before=snapshots(ROOT);run.record['source_sha256_before']=before;run.save()
                run.command('tooling_tests',[sys.executable,'-m','unittest','discover','-s','tests','-v'])
                if selected:
                    run.compiler()
                    manifest_scopes = list(dict.fromkeys(['.'] + [GATES[g]['package'] for g in selected]))
                    run.command('manifest_schema', [run.lean, '--run', str(ROOT/'scripts/check_manifests.lean'),
                        *[str(ROOT/scope/'lake-manifest.json') for scope in manifest_scopes]])
                    package_errors={}
                    for scope in dict.fromkeys(GATES[g]['package'] for g in selected):
                        try:run.prepare(scope)
                        except (OSError,ValueError,RuntimeError,subprocess.SubprocessError) as exc:package_errors[scope]=str(exc)
                    run.record['package_errors'] = package_errors
                    run.save()
                    for name in selected:
                        gate=GATES[name]
                        failed=[d for d in gate['prerequisites'] if run.record['gates'][d]['status']!='PASS']
                        if gate['package'] in package_errors:
                            run.record['gates'][name]={'status':'BLOCKED','reason':package_errors[gate['package']]};run.save()
                        elif failed:
                            run.record['gates'][name]={'status':'BLOCKED','reason':'Failed prerequisite: '+', '.join(failed)};run.save()
                        else:run.gate(name)
                    # Final environment and source checks cannot be replaced by an old PASS.
                    for scope in dict.fromkeys(GATES[g]['package'] for g in selected):
                        if scope in package_errors:continue
                        for entry in json.loads((ROOT/scope/'lake-manifest.json').read_text())['packages']:
                            if entry['type']=='git':run.verify_dependency(ROOT/scope/'.lake/packages'/entry['name'],entry)
                after=snapshots(ROOT)
                check_source_changes(run.record, before, after)
                success=all(run.record['gates'][k]['status']=='PASS' for k in selected)
                run.record['status']='PASS_SELECTED_CHECKS' if success else 'FAIL_OR_BLOCKED'
                rc=0 if success else 1
            except KeyboardInterrupt:
                run.record.update(status='INTERRUPTED',error='Interrupted; partial commands and sources collected');rc=130
            except (OSError,ValueError,RuntimeError,subprocess.SubprocessError) as exc:
                run.record.update(status='SETUP_OR_AUDIT_ERROR',error=str(exc));print('FAIL: '+str(exc),file=sys.stderr);rc=2
            finally:
                for state in run.record['gates'].values():
                    if state['status'] in {'NOT_STARTED', 'RUNNING'}:
                        state.update(status='BLOCKED', reason=run.record.get('error','Run stopped before this check completed'))
                run.finish()
            return rc
    except (OSError,ValueError,RuntimeError) as exc:
        print('FAIL: '+str(exc),file=sys.stderr);return 2


if __name__=='__main__':
    raise SystemExit(main())
