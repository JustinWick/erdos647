#!/usr/bin/env python3
"""Inspect the entire PNT+ SOURCE import closure of the small compatibility boundary.

This is deliberately stronger than checking only the final theorem's axioms. It
rejects placeholders in any reachable upstream module, even unused declarations.
It is not a claim about unimported PNT+ research files or Lean tactic internals.
The kernel/theorem audit is a separate mandatory gate.
"""
from __future__ import annotations
import hashlib
from pathlib import Path
import re

UPSTREAM_ROOT = 'PrimeNumberTheoremAnd.MediumPNT'
PREFIX = 'PrimeNumberTheoremAnd'
EXCLUDED = ('PrimeNumberTheoremAnd.IEANTN', 'PrimeNumberTheoremAnd.Wiener',
            'LeanCert', 'PrimeCert')
EXTERNAL_ROOTS = {'Mathlib', 'Architect', 'Batteries', 'Lean', 'Init', 'Std', 'Qq'}
BAD = re.compile(r'\b(?:sorry|sorryAx|admit|axiom|native_decide)\b|debug\.skipKernelTC|'
                 r'\b(?:Lean\.)?(?:ofReduceBool|ofReduceNat|trustCompiler)\b|\bdecide\s*\+native\b')
IDENT = re.compile(r'[A-Za-z_][A-Za-z0-9_\']*(?:\.[A-Za-z_][A-Za-z0-9_\']*)*\Z')


def code_only(text: str) -> str:
    """Mask nested comments and strings without losing source line/column offsets."""
    out = list(text)
    i = depth = 0
    quoted = False
    while i < len(text):
        if depth:
            if text.startswith('/-', i):
                out[i:i+2] = '  '; depth += 1; i += 2
            elif text.startswith('-/', i):
                out[i:i+2] = '  '; depth -= 1; i += 2
            else:
                if text[i] != '\n': out[i] = ' '
                i += 1
        elif quoted:
            if text[i] == '\\':
                out[i] = ' '; i += 1
                if i < len(text):
                    if text[i] != '\n': out[i] = ' '
                    i += 1
            elif text[i] == '"':
                out[i] = ' '; quoted = False; i += 1
            else:
                if text[i] != '\n': out[i] = ' '
                i += 1
        elif text.startswith('/-', i):
            out[i:i+2] = '  '; depth = 1; i += 2
        elif text.startswith('--', i):
            while i < len(text) and text[i] != '\n':
                out[i] = ' '; i += 1
        elif text[i] == '"':
            out[i] = ' '; quoted = True; i += 1
        else:
            i += 1
    if depth or quoted:
        raise ValueError('Unterminated Lean comment/string in dependency source')
    return ''.join(out)


def source_imports(code: str) -> list[str]:
    result = []
    for line in re.findall(r'^\s*(?:(?:public|private|meta)\s+)*import\s+([^\n]+)', code, re.M):
        for word in line.split():
            if word == 'all': continue
            if not IDENT.fullmatch(word):
                raise ValueError('Unsupported import syntax in dependency closure: ' + word)
            result.append(word)
    return result


def excluded(name: str) -> bool:
    return any(name == p or name.startswith(p + '.') for p in EXCLUDED)


def inspect_closure(upstream: Path, compat: Path) -> dict:
    """Read only. Do not modify the Git checkout, imports, caches, or proofs."""
    local_text = compat.read_text(encoding='utf-8')
    local_code = code_only(local_text)
    local_imports = source_imports(local_code)
    starting = [n for n in local_imports if n == PREFIX or n.startswith(PREFIX+'.')]
    errors = []
    if starting != [UPSTREAM_ROOT]:
        errors.append('Compatibility module must import exactly ' + UPSTREAM_ROOT)
    if BAD.search(local_code):
        errors.append('Forbidden proof shortcut in compatibility module')
    todo = list(starting)
    rows = {}
    external = set()
    while todo:
        name = todo.pop()
        if name in rows: continue
        if excluded(name):
            errors.append('Unfinished catalogue/import reintroduced: ' + name)
            # Fail closed but still record the source and all offending tokens below.
        if not IDENT.fullmatch(name):
            errors.append('Invalid upstream module identifier: ' + name); continue
        rel = Path(*name.split('.')).with_suffix('.lean')
        path = upstream/rel
        if not path.is_file():
            errors.append('Missing upstream source: ' + rel.as_posix())
            rows[name] = {'path': rel.as_posix(), 'missing': True}
            continue
        cursor = upstream
        for part in rel.parts:
            cursor = cursor/part
            if cursor.is_symlink():
                raise ValueError('Symlink inside upstream source tree: ' + rel.as_posix())
        raw = path.read_bytes()
        code = code_only(raw.decode('utf-8'))
        imps = source_imports(code)
        bad = [{'token':m.group(), 'line':code.count('\n', 0, m.start()) + 1}
               for m in BAD.finditer(code)]
        rows[name] = {'path':rel.as_posix(), 'sha256':hashlib.sha256(raw).hexdigest(),
                      'imports':imps, 'forbidden_tokens':bad}
        if bad:
            errors.append(name + ': ' + ', '.join(f'{x["token"]} at line {x["line"]}' for x in bad))
        for imp in imps:
            if imp == PREFIX or imp.startswith(PREFIX + '.'):
                if imp not in rows: todo.append(imp)
            elif excluded(imp) or imp.split('.')[0] not in EXTERNAL_ROOTS:
                errors.append('Unexpected external dependency: ' + imp)
            else: external.add(imp)
    return {'schema':1, 'scope':'Required PNT+ source import closure; not the full upstream catalogue',
            'root_module':UPSTREAM_ROOT, 'compat_sha256':hashlib.sha256(local_text.encode()).hexdigest(),
            'module_count':len(rows), 'modules':dict(sorted(rows.items())),
            'external_library_imports':sorted(external),
            'excluded_catalogues':list(EXCLUDED), 'errors':errors,
            'status':'SOURCE_CLOSURE_CLEAN' if rows and not errors else 'REJECTED',
            'kernel_axiom_audit_is_separate':True}
