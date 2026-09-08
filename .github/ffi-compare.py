#!/usr/bin/env python3
"""Run the same independent C/Factor regressions on two untouched VM images."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess

p = argparse.ArgumentParser()
p.add_argument('--baseline', type=Path, required=True)
p.add_argument('--baseline-image', required=True)
p.add_argument('--candidate', type=Path, required=True)
p.add_argument('--candidate-image', required=True)
p.add_argument('--cc', required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args()
out = a.out.resolve()
out.mkdir(parents=True, exist_ok=True)
if any(out.iterdir()):
    p.error("--out must be an empty directory")
(out / 'tmp').mkdir(exist_ok=True)
source = a.candidate.resolve()
results = []

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def run(name, command, cwd=source, env=None):
    with (out / (name + '.log')).open('wb') as log:
        try:
            rc = subprocess.run(command, cwd=cwd, env=env, stdout=log,
                                stderr=subprocess.STDOUT, timeout=600).returncode
        except subprocess.TimeoutExpired:
            rc = 124
        except OSError as error:
            log.write(str(error).encode())
            rc = 127
    (out / (name + '.exit')).write_text(str(rc) + '\n')
    results.append(dict(name=name, command=[str(x) for x in command], cwd=str(cwd), exit=rc))
    (out / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
    return rc

manifest = {'test_sources': {}, 'workspaces': {}}

def save_manifest():
    manifest['artifacts'] = {f.name: sha(f) for f in out.iterdir()
                             if f.is_file() and f.name != 'manifest.json'}
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')

for label, root, image in [('baseline', a.baseline, a.baseline_image),
                           ('candidate', a.candidate, a.candidate_image)]:
    root = root.resolve()
    paths = subprocess.check_output(['git', 'ls-files', '-z'], cwd=root).split(b'\0')
    manifest['workspaces'][label] = dict(root=str(root),
        commit=subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip(),
        vm=sha(root / 'factor'), image=sha(root / image),
        source_hashes={os.fsdecode(n): sha(root / os.fsdecode(n)) for n in paths if n and (root / os.fsdecode(n)).is_file()})
    (out / (label + '.patch')).write_bytes(subprocess.check_output(['git', 'diff', '--binary', 'HEAD'], cwd=root))
save_manifest()
if run('toolchain', [a.cc, '--version']):
    save_manifest()
    raise SystemExit(1)
fixture = out / 'fixture.so'
flags = ['-O2', '-fno-lto', '-fno-fast-math']
if run('fixture-build', [a.cc, *flags, '-fPIC', '-shared', '-Wl,-z,defs', 'vm/ffi_test.c', '-lm', '-o', fixture]):
    save_manifest()
    raise SystemExit(1)
manifest['fixture'] = sha(fixture)
summaries = []
for c, factor in [('uint_callback', 'uint-callback'), ('array_struct', 'array-struct'), ('fp_status', 'fp-status')]:
    cpath = source / ('vm/tests/ffi_' + c + '.c')
    fpath = source / ('basis/compiler/tests/fixtures/' + factor + '.factor')
    for path in [cpath, fpath]:
        manifest['test_sources'][str(path.relative_to(source))] = sha(path)
    obj = out / (c + '.o')
    control = out / (c + '-control')
    if run(c + '-object', [a.cc, *flags, '-c', cpath, '-o', obj]):
        save_manifest()
        raise SystemExit(1)
    if run(c + '-link', [a.cc, *flags, '-DABI_CONTROL', cpath, obj, '-lm', '-o', control]):
        save_manifest()
        raise SystemExit(1)
    assembly_status = run(c + '-assembly', [a.cc, *flags, '-S', cpath, '-o', out / (c + '.s')])
    c_status = run(c + '-control', [control])
    env = dict(os.environ, FACTOR_REPRO_LIBRARY=str(fixture), FACTOR_REPRO_TESTS=str(fpath), TMPDIR=str(out / 'tmp'))
    statuses = []
    for label, root, image in [('baseline', a.baseline, a.baseline_image), ('candidate', a.candidate, a.candidate_image)]:
        root = root.resolve()
        statuses.append(run(c + '-' + label, [root / 'factor', '-resource-path=' + str(root), '-i=' + image,
            '-no-user-init', '-no-monitors', source / '.github/ffi-compare.factor'], root, env))
    base, candidate = statuses
    baseline_log = (out / (c + '-baseline.log')).read_text(errors='replace')
    failure_marker = ('Dispatching on object: +fp-zero-divide+' if c == 'fp_status' else '=== Got:')
    baseline_valid = base == 0 or (base == 1 and failure_marker in baseline_log)
    classification = ('qualification-coverage' if base == 0 else
                      'baseline-failure' if baseline_valid else 'baseline-infrastructure-failure')
    summaries.append(dict(case=c, control=c_status, baseline=base, candidate=candidate,
        classification=classification,
        passed=baseline_valid and assembly_status == 0 and c_status == 0 and candidate == 0))
(out / 'summary.json').write_text(json.dumps(summaries, indent=2) + '\n')
save_manifest()
raise SystemExit(0 if all(x['passed'] for x in summaries) else 1)
