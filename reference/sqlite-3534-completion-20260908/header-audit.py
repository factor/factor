#!/usr/bin/env python3
"""Audit every sqlite3.h declaration and generate independent native layout probes.

Run from any directory. Requires Python 3 and Clang. Defaults to this checkout's
binding and the pinned official 3.53.4 header. --binding permits before evidence.
--generate-layout emits layout-oracle.c and layout-factor.factor into --output.
--check-layout C.log Factor.log compares generated native sizeof/alignof/offsetof
measurements. The C oracle uses no SQLite library and tests all complete records.
"""
import argparse
import hashlib
import importlib.util
import json
import pathlib
import re
import subprocess
import sys

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[1]
COMPARE = ROOT / 'reference/library-release-comparison-20260908/sqlite/compare.py'
spec = importlib.util.spec_from_file_location('comparison', COMPARE)
comparison = importlib.util.module_from_spec(spec)
spec.loader.exec_module(comparison)


def factor_inventory(path):
    result = comparison.factor_inventory(path)
    src = re.sub(r'!.*', '', path.read_text())
    result['callbacks'] = {}
    structs = {m[1]: m.start() for m in re.finditer(r'^STRUCT:\s+(\S+)', src, re.M)}
    result['record_resets'] = [m[1] for m in re.finditer(r'^C-TYPE:\s+(\S+)', src, re.M) if m[1] in structs and m.start() > structs[m[1]]]
    for ret, name, params in re.findall(r'^CALLBACK:\s+(\S+)\s+(\S+)\s*\((.*?)\)', src, re.M | re.S):
        args = [p.strip().split()[0] for p in params.split(',') if p.strip()]
        result['callbacks'][name] = dict(returns=ret, params=args)
        result['typedefs'][name] = 'callback'
    for name, value in re.findall(r'^CONSTANT:\s+(NOT_WITHIN|PARTLY_WITHIN|FULLY_WITHIN)\s+([^\n]+)', src, re.M):
        result['constants'][name] = value.strip()
    return result


def split_args(args):
    result, start, depth = [], 0, 0
    for i, char in enumerate(args):
        if char in '([': depth += 1
        if char in ')]': depth -= 1
        if char == ',' and depth == 0:
            result.append(args[start:i].strip())
            start = i + 1
    result.append(args[start:].strip())
    return [] if result == ['void'] or result == [''] else result


def normalize(typ, inventory, factor=False):
    typ = re.sub(r'\b(const|volatile|restrict)\b', '', typ).strip()
    typ = re.sub(r'\s+', ' ', typ)
    callback = re.fullmatch(r'(.+?)\s*\(\s*\*\s*\)\s*\((.*)\)', typ)
    if callback:
        return ['callback', normalize(callback[1], inventory, factor),
                [normalize(arg, inventory, factor) for arg in split_args(callback[2])]]
    if factor and typ in inventory['callbacks']:
        cb = inventory['callbacks'][typ]
        return ['callback', normalize(cb['returns'], inventory, True),
                [normalize(arg, inventory, True) for arg in cb['params']]]
    array = re.fullmatch(r'(.+?)\s*\[(\d+)\]', typ)
    if array: return ['array', int(array[2]), normalize(array[1], inventory, factor)]
    if typ.endswith('*'): return ['pointer', normalize(typ[:-1].strip(), inventory, factor)]
    if typ.startswith('struct '): return ['record', typ[7:]]
    if typ in inventory['typedefs']:
        target = inventory['typedefs'][typ]
        if target in ('opaque', 'struct'): return ['record', typ]
        return normalize(target, inventory, factor)
    aliases = {'longlong': 'long long', 'ulonglong': 'unsigned long long',
               'uint': 'unsigned int', 'uchar': 'unsigned char', 'ushort': 'unsigned short',
               'ulong': 'unsigned long', 'c-string': ['pointer', 'char']}
    return aliases.get(typ, typ)


def compatible(c, f, location, accepted):
    if c == f: return True
    # These source declarations preserve ABI but deliberately omit pointed-to
    # types. Record each exception rather than silently pretending exact typing.
    if f == ['pointer', 'void'] and isinstance(c, list) and c[0] in ('pointer', 'callback'):
        accepted.append(dict(location=location, c=c, factor=f, reason='opaque pointer/callback ABI representation'))
        return True
    if c == ['pointer', 'void'] and isinstance(f, list) and f[0] == 'pointer':
        accepted.append(dict(location=location, c=c, factor=f, reason='typed pointer for C void pointer'))
        return True
    if c == ['pointer', 'unsigned char'] and f == ['pointer', 'char']:
        accepted.append(dict(location=location, c=c, factor=f, reason='UTF-8 byte pointer represented as char pointer/string'))
        return True
    if isinstance(c, list) and isinstance(f, list) and c[0] == f[0]:
        if c[0] == 'pointer': return compatible(c[1], f[1], location + ' pointee', accepted)
        if c[0] == 'array' and c[1] == f[1]: return compatible(c[2], f[2], location + ' element', accepted)
        if c[0] == 'callback' and len(c[2]) == len(f[2]):
            parts = [compatible(c[1], f[1], location + ' return', accepted)]
            parts += [compatible(a, b, location + f' callback arg {i}', accepted) for i, (a, b) in enumerate(zip(c[2], f[2]))]
            return all(parts)
    return False


def audit(header, factor):
    result = {'coverage': {}, 'signature_mismatches': [], 'field_mismatches': [],
              'typedef_mismatches': [], 'abi_compatible_representations': []}
    for kind in ('functions', 'constants', 'typedefs', 'records'):
        names, bound = set(header[kind]), set(factor[kind])
        result['coverage'][kind] = dict(upstream=len(names), bound=len(names & bound),
            missing=sorted(names-bound), binding_only=sorted(bound-names))
    # Reuse the release comparison's restricted arithmetic evaluator for values.
    result['constant_value_mismatches'] = comparison.delta(header, header, factor)['bound_constant_value_mismatches']
    result['record_reset_mismatches'] = factor['record_resets']
    accepted = result['abi_compatible_representations']
    for name, c in header['functions'].items():
        if name not in factor['functions']: continue
        f = factor['functions'][name]
        cr = c['signature'].split('(', 1)[0].strip()
        pairs = [(cr, f['returns'], 'return')]
        pairs += [(a, b, f'arg {i}') for i, (a, b) in enumerate(zip(c['params'], f['params']))]
        if len(c['params']) != len(f['params']) or c['variadic'] != f['variadic']:
            result['signature_mismatches'].append(dict(name=name, c=c, factor=f, reason='arity/variadic marker'))
        for a, b, loc in pairs:
            cn, fn = normalize(a, header), normalize(b, factor, True)
            if not compatible(cn, fn, name + ' ' + loc, accepted):
                result['signature_mismatches'].append(dict(name=name, location=loc, c=a, factor=b, normalized_c=cn, normalized_factor=fn))
    for name, fields in header['records'].items():
        if name not in factor['records']: continue
        ff = factor['records'][name]
        if list(fields) != list(ff):
            result['field_mismatches'].append(dict(name=name, reason='field names/order', c=list(fields), factor=list(ff)))
        for field in fields.keys() & ff.keys():
            cn, fn = normalize(fields[field], header), normalize(ff[field], factor, True)
            if not compatible(cn, fn, name + '.' + field, accepted):
                result['field_mismatches'].append(dict(name=name, field=field, c=fields[field], factor=ff[field], normalized_c=cn, normalized_factor=fn))
    for name in header['typedefs'].keys() & factor['typedefs'].keys():
        cn, fn = normalize(name, header), normalize(name, factor, True)
        if not compatible(cn, fn, name, accepted): result['typedef_mismatches'].append(dict(name=name, c=cn, factor=fn))
    # Preserve ownership/writable-buffer expectations beyond ABI shape. c-string
    # auto-conversion would otherwise lose allocations or copy writable storage.
    expected = {
        'sqlite3_expanded_sql': ('returns', 'char*'),
        'sqlite3_serialize': ('returns', 'uchar*'),
        'sqlite3_create_filename': ('returns', 'sqlite3_filename'),
        'sqlite3_db_filename': ('returns', 'sqlite3_filename'),
        'sqlite3_filename_database': ('returns', 'sqlite3_filename'),
        'sqlite3_filename_journal': ('returns', 'sqlite3_filename'),
        'sqlite3_filename_wal': ('returns', 'sqlite3_filename'),
        'sqlite3_mprintf': ('returns', 'char*'),
        'sqlite3_vmprintf': ('returns', 'char*'),
        'sqlite3_str_finish': ('returns', 'char*'),
        'sqlite3_snprintf': ('returns', 'char*'),
        'sqlite3_vsnprintf': ('returns', 'char*'),
        'sqlite3_column_text16': ('returns', 'void*'),
        'sqlite3_value_text16': ('returns', 'void*'),
        'sqlite3_value_text16le': ('returns', 'void*'),
        'sqlite3_value_text16be': ('returns', 'void*'),
        'sqlite3_win32_utf8_to_unicode': ('returns', 'void*'),
        'sqlite3_win32_unicode_to_utf8': ('returns', 'char*'),
    }
    result['ownership_mismatches'] = []
    for name, (key, typ) in expected.items():
        if name in header['functions'] and name in factor['functions'] and factor['functions'][name][key] != typ:
            result['ownership_mismatches'].append(dict(name=name, expected=typ, actual=factor['functions'][name][key]))
    for name, index, typ in [('sqlite3_snprintf', 1, 'char*'), ('sqlite3_vsnprintf', 1, 'char*'), ('sqlite3_complete16', 0, 'void*'), ('sqlite3_prepare16', 1, 'void*'), ('sqlite3_deserialize', 2, 'uchar*'), ('sqlite3_database_file_object', 0, 'sqlite3_filename'), ('sqlite3_uri_parameter', 0, 'sqlite3_filename'), ('sqlite3_uri_boolean', 0, 'sqlite3_filename'), ('sqlite3_uri_int64', 0, 'sqlite3_filename'), ('sqlite3_uri_key', 0, 'sqlite3_filename')]:
        if name in factor['functions'] and factor['functions'][name]['params'][index] != typ:
            result['ownership_mismatches'].append(dict(name=name, argument=index, expected=typ, actual=factor['functions'][name]['params'][index]))
    for field in ('a', 'b'):
        if factor['records'].get('Fts5PhraseIter', {}).get(field) != 'uchar*':
            result['ownership_mismatches'].append(dict(name='Fts5PhraseIter', field=field, expected='uchar*', actual=factor['records'].get('Fts5PhraseIter', {}).get(field)))
    result['pass'] = not any(v['missing'] for v in result['coverage'].values()) and not any(result[k] for k in ('signature_mismatches', 'field_mismatches', 'typedef_mismatches', 'constant_value_mismatches', 'ownership_mismatches', 'record_reset_mismatches'))
    return result


def generate_layout(header, factor, output):
    c = ['/* Generated from pinned official SQLite 3.53.4 header by header-audit.py. */',
         '#include <stddef.h>', '#include <stdio.h>',
         '#define SQLITE_ENABLE_SESSION', '#define SQLITE_ENABLE_PREUPDATE_HOOK',
         '#include "../library-release-comparison-20260908/sqlite/sqlite3-3.53.4.h"', 'int main(void) {']
    f = ['! Generated by header-audit.py. Compare output to native C layout-oracle.c.',
         'USING: alien.c-types classes.struct continuations db.sqlite.ffi io kernel prettyprint vocabs.loader ;',
         'IN: scratchpad', '<< "db.sqlite.ffi" reload >>']
    for name, fields in header['records'].items():
        measures = [('size', f'sizeof(struct {name})', f'{name} heap-size'),
                    ('align', f'_Alignof(struct {name})', f'{name} c-type-align')]
        measures += [(field, f'offsetof(struct {name}, {field})', f'"{field}" {name} offset-of') for field in fields]
        for field, ce, fe in measures:
            label = f'LAYOUT {name} {field} '
            c.append(f'  printf("{label}%zu\\n", {ce});')
            if name in factor['records'] and (field in ('size', 'align') or field in factor['records'][name]):
                f.append(f'"{label}" write [ {fe} . ] [ drop "ERROR" print ] recover')
    c += ['  return 0;', '}']
    (output/'layout-oracle.c').write_text('\n'.join(c)+'\n')
    (output/'layout-factor.factor').write_text('\n'.join(f)+'\n')


def check_layout(paths):
    def read(path):
        rows = re.findall(r'^LAYOUT (\S+) (\S+) (\d+)\s*$', path.read_text(), re.M)
        return {f'{n}.{f}': int(v) for n,f,v in rows}
    c, f = map(read, paths)
    mismatches = {key: {'c': c.get(key), 'factor': f.get(key)} for key in sorted(c.keys() | f.keys()) if c.get(key) != f.get(key)}
    return dict(native_measurements=len(c), factor_measurements=len(f), native_records=len({k.split('.')[0] for k in c}), mismatches=mismatches, **{'pass': bool(c) and c == f})


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--binding', type=pathlib.Path, default=ROOT/'basis/db/sqlite/ffi/ffi.factor')
    ap.add_argument('--header', type=pathlib.Path, default=COMPARE.parent/'sqlite3-3.53.4.h')
    ap.add_argument('--output', type=pathlib.Path, default=HERE)
    ap.add_argument('--name', default='header-audit.json')
    ap.add_argument('--generate-layout', action='store_true')
    ap.add_argument('--check-layout', type=pathlib.Path, nargs=2)
    args = ap.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    if args.check_layout:
        result = check_layout(args.check_layout)
    else:
        expected_hash = '919e7f2e8ed1d8f56ac17b412b8971c76aa5d1a879752cc6058f75e7d5910e1d'
        if hashlib.sha256(args.header.read_bytes()).hexdigest() != expected_hash:
            raise SystemExit('Header differs from the pinned official SQLite 3.53.4 header')
        header = comparison.header_inventory(args.header)
        factor = factor_inventory(args.binding)
        result = audit(header, factor)
        result['header_sha256'] = expected_hash
        result['binding_sha256'] = hashlib.sha256(args.binding.read_bytes()).hexdigest()
        if args.generate_layout: generate_layout(header, factor, args.output)
    (args.output/args.name).write_text(json.dumps(result, indent=2, sort_keys=True)+'\n')
    if 'coverage' in result:
        for k,v in result['coverage'].items(): print(f'{k}: {v["bound"]}/{v["upstream"]}, {len(v["missing"])} missing')
        for k,v in result.items():
            if k.endswith('mismatches'): print(k, len(v))
    else: print(f"native records: {result['native_records']}; native measurements: {result['native_measurements']}; Factor measurements: {result['factor_measurements']}; mismatches: {len(result['mismatches'])}")
    print('PASS' if result['pass'] else 'FAIL')
    return 0 if result['pass'] else 1

if __name__ == '__main__': sys.exit(main())
