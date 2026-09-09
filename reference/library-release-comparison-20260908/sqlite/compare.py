#!/usr/bin/env python3
"""Inventory released sqlite3.h against active db.sqlite.ffi declarations.
Requires Python 3 and Clang. No SQLite installation or Factor image required.
Use --download to fetch/check the two official release archives again.
"""
import argparse, hashlib, io, json, pathlib, re, subprocess, zipfile, urllib.request
HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[2]
FLAGS = ['-DSQLITE_ENABLE_SESSION', '-DSQLITE_ENABLE_PREUPDATE_HOOK', '-DSQLITE_ENABLE_NORMALIZE']

def category(name):
    if name.startswith(('sqlite3session', 'sqlite3changeset', 'sqlite3changegroup', 'sqlite3rebaser', 'sqlite3_session', 'sqlite3_changeset', 'SQLITE_SESSION', 'SQLITE_CHANGESET', 'SQLITE_CHANGEGROUP')): return 'session'
    if name.startswith(('Fts5', 'fts5', 'FTS5')): return 'fts5'
    if name.startswith('sqlite3_rtree') or name in ('NOT_WITHIN', 'PARTLY_WITHIN', 'FULLY_WITHIN'): return 'rtree'
    if name.startswith(('sqlite3_carray', 'SQLITE_CARRAY')): return 'carray'
    return 'core'

def dump(name, obj):
    (HERE / name).write_text(json.dumps(obj, indent=2, sort_keys=True) + '\n')

def header_inventory(path):
    ast = json.loads(subprocess.check_output(['clang', '-x', 'c', *FLAGS, '-Xclang', '-ast-dump=json', '-fsyntax-only', str(path)]))
    result = {k: {} for k in ('functions', 'records', 'typedefs', 'constants')}
    def walk(node):
        name, kind = node.get('name', ''), node['kind']
        if name.startswith(('sqlite', 'Fts5', 'fts5')):
            typ = node.get('type', {}).get('qualType')
            if kind == 'FunctionDecl':
                result['functions'][name] = dict(signature=typ, params=[n['type']['qualType'] for n in node.get('inner', []) if n['kind'] == 'ParmVarDecl'], variadic=node.get('variadic', False), category=category(name))
            elif kind == 'TypedefDecl': result['typedefs'][name] = typ
            elif kind == 'RecordDecl' and node.get('completeDefinition'):
                result['records'][name] = {n['name']: n['type']['qualType'] for n in node.get('inner', []) if n['kind'] == 'FieldDecl'}
        for child in node.get('inner', []):
            # Recurse only declaration trees, not type references.
            if child['kind'] in ('RecordDecl', 'FunctionDecl', 'TypedefDecl'): walk(child)
    for node in ast['inner']: walk(node)
    # Public value-like macros, excluding include/annotation/build macros.
    # Capture source rather than -dM so the enabled-feature switches above are not counted.
    src = re.sub(r'/\*.*?\*/', '', path.read_text(), flags=re.S)
    for name, value in re.findall(r'^#\s*define\s+([A-Za-z_]\w*)[^\S\n]+([^\n]+)', src, re.M):
        value = value.strip()
        if (name.startswith(('SQLITE_', 'FTS5_')) or name in ('NOT_WITHIN', 'PARTLY_WITHIN', 'FULLY_WITHIN')) and (re.match(r'[-+\d"(]', value) or value.startswith('SQLITE_') and name not in ('SQLITE_STDCALL',)):
            if name not in ('SQLITE_WASI', 'SQLITE_THREADSAFE'): result['constants'][name] = value
    return result

def factor_inventory(path):
    src = re.sub(r'!.*', '', path.read_text())
    result = {k: {} for k in ('functions', 'records', 'typedefs', 'constants')}
    for ret, name, params in re.findall(r'^FUNCTION:\s+(\S+)\s+(\S+)\s*\((.*?)\)', src, re.M | re.S):
        args = [p.strip().split()[0] for p in params.split(',') if p.strip()]
        result['functions'][name] = dict(signature=f'{ret} ({", ".join(args)})', returns=ret, params=[p for p in args if p != '...'], variadic='...' in args, category=category(name))
    for name, fields in re.findall(r'^STRUCT:\s+(\S+)\s+(.*?);', src, re.M | re.S):
        result['records'][name] = dict(re.findall(r'\{\s+(\S+)\s+(\S+)\s+\}', fields))
    for typ, name in re.findall(r'^TYPEDEF:\s+(\S+)\s+(\S+)', src, re.M): result['typedefs'][name] = typ
    for name in re.findall(r'^C-TYPE:\s+(\S+)', src, re.M): result['typedefs'].setdefault(name, 'opaque')
    for name in result['records']: result['typedefs'].setdefault(name, 'struct')
    for name, value in re.findall(r'^CONSTANT:\s+((?:SQLITE|FTS5)_\w+)\s+([^\n]+)', src, re.M): result['constants'][name] = value.strip()
    for name, value in re.findall(r'^: (SQLITE_(?:STATIC|TRANSIENT)) \( -- ptr \) (-?\d+) <alien>', src, re.M): result['constants'][name] = f'((sqlite3_destructor_type){value})'
    return result

def delta(old, new, factor):
    out = {}
    for kind in new:
        a, b, f = set(old[kind]), set(new[kind]), set(factor[kind])
        out[kind] = dict(upstream=len(b), bound=len(b&f), missing=len(b-f), added_since_3_51_0=sorted(b-a), missing_new=sorted(b-a-f), missing_preexisting=sorted((b&a)-f), binding_only=sorted(f-b), changed_since_3_51_0={n: {'old': old[kind][n], 'new': new[kind][n]} for n in sorted(a&b) if old[kind][n] != new[kind][n]})
    def value(expr, constants):
        if expr.startswith('"') or expr.startswith('((sqlite3_destructor_type)'): return expr
        expr = re.sub(r'\bSQLITE_\w+\b', lambda m: str(value(constants[m[0]], constants)), expr)
        if not re.fullmatch(r'[0-9a-fA-FxX()|<>+* /&~^-]+', expr): raise ValueError(expr)
        return eval(expr, {'__builtins__': {}}, {})
    out['bound_constant_value_mismatches'] = {n: {'upstream': new['constants'][n], 'factor': factor['constants'][n]} for n in sorted(set(new['constants']) & set(factor['constants'])) if value(new['constants'][n], new['constants']) != value(factor['constants'][n], factor['constants'])}
    out['function_groups'] = {}
    for group in ('core', 'session', 'rtree', 'fts5', 'carray'):
        names = {n for n in new['functions'] if category(n) == group}
        out['function_groups'][group] = dict(upstream=len(names), bound=len(names & set(factor['functions'])), missing=sorted(names-set(factor['functions'])))
    out['record_field_gaps'] = {n: {'missing': [f for f in new['records'][n] if f not in factor['records'][n]], 'extra': [f for f in factor['records'][n] if f not in new['records'][n]]} for n in sorted(set(new['records']) & set(factor['records'])) if set(new['records'][n]) != set(factor['records'][n])}
    out['arity_or_variadic_mismatches'] = {n: {'upstream': new['functions'][n], 'factor': factor['functions'][n]} for n in sorted(set(new['functions']) & set(factor['functions'])) if len(new['functions'][n]['params']) != len(factor['functions'][n]['params']) or new['functions'][n]['variadic'] != factor['functions'][n]['variadic']}
    return out

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--download', action='store_true')
    args = parser.parse_args()
    sources = json.loads((HERE/'sources.json').read_text())
    inventories = []
    for source in sources:
        path = HERE/f"sqlite3-{source['version']}.h"
        if args.download:
            archive = urllib.request.urlopen(source['url']).read()
            assert hashlib.sha3_256(archive).hexdigest() == source['archive_sha3_256']
            with zipfile.ZipFile(io.BytesIO(archive)) as z:
                path.write_bytes(z.read(next(n for n in z.namelist() if n.endswith('/sqlite3.h'))))
        assert hashlib.sha256(path.read_bytes()).hexdigest() == source['header_sha256']
        inv = header_inventory(path)
        dump(f"inventory-{source['version']}.json", inv)
        inventories.append(inv)
    factor = factor_inventory(ROOT/'basis/db/sqlite/ffi/ffi.factor')
    dump('inventory-factor.json', factor)
    diff = delta(*inventories, factor)
    dump('comparison.json', diff)
    for kind in inventories[1]: print(kind, {k: diff[kind][k] for k in ('upstream', 'bound', 'missing')})
    print('arity/variadic mismatches:', len(diff['arity_or_variadic_mismatches']))

if __name__ == '__main__': main()
