#!/usr/bin/env python3
"""Run isolated C fixture lanes and retain evidence, including failed commands."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys
import time

p = argparse.ArgumentParser()
p.add_argument('--cc', required=True)
p.add_argument('--cxx', default=os.environ.get('CXX', 'g++'))
p.add_argument('--out', required=True)
p.add_argument('--image', default='factor.image')
p.add_argument('--require-small', action='store_true')
p.add_argument('--native-arm64', action='store_true')
p.add_argument('--full', action='store_true')
a = p.parse_args()
root = Path.cwd()
out = Path(a.out).resolve()
out.mkdir(parents=True, exist_ok=True)
if any(out.iterdir()):
    p.error("--out must be an empty directory")
results = []

def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def run(name, cmd, expected=(0,), env=None):
    start = time.monotonic()
    with (out / (name + '.log')).open('wb') as log:
        try:
            rc = subprocess.run(cmd, stdout=log, stderr=subprocess.STDOUT,
                                env=env, timeout=7200).returncode
        except subprocess.TimeoutExpired:
            rc = 124
        except OSError as error:
            log.write(str(error).encode())
            rc = 127
    (out / (name + '.exit')).write_text(str(rc) + '\n')
    results.append(dict(name=name, command=cmd, exit=rc, expected=list(expected),
                        passed=rc in expected, seconds=time.monotonic()-start))
    (out / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
    print(name, rc, flush=True)
    return rc in expected

manifest = dict(machine=platform.machine(), platform=platform.platform(),
                libc=platform.libc_ver(), runtime='C++', native_arm64_requested=a.native_arm64,
                source_commit=subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip(),
                source_hashes={})
tracked = subprocess.check_output(['git', 'ls-files', '-z']).split(b'\0')
untracked = subprocess.check_output(['git', 'ls-files', '--others', '--exclude-standard', '-z']).split(b'\0')
for name in set(tracked + untracked):
    path = Path(os.fsdecode(name))
    if name and path.is_file() and not path.resolve().is_relative_to(out):
        manifest['source_hashes'][str(path)] = digest(path)
for name in ['factor', 'libfactor.a', a.image]:
    manifest.setdefault('artifacts', {})[name] = digest(name)
(out / 'source.patch').write_bytes(subprocess.check_output(['git', 'diff', '--binary', 'HEAD']))
(out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
run('cpu', ['lscpu'])
run('kernel', ['uname', '-a'])
run('libc', ['getconf', 'GNU_LIBC_VERSION'])
run('toolchain', [a.cc, '--version'])
run('vm-toolchain', [a.cxx, '--version'])
run('distribution', ['cat', '/etc/os-release'])
if a.native_arm64 and (platform.system() != 'Linux' or platform.machine() != 'aarch64'
                       or platform.libc_ver()[0] != 'glibc' or sys.byteorder != 'little'):
    (out / 'exclusions.txt').write_text('Native Linux AArch64/glibc required; this host cannot qualify.\n')
    sys.exit(1)
flags = ['-O2', '-fno-lto', '-fno-fast-math', '-fPIC']
if platform.machine() == 'aarch64':
    flags += ['-march=armv8-a']
if a.require_small:
    macros = subprocess.check_output([a.cc, '-dM', '-E', '-'], input=b'').decode()
    major = next((int(line.split()[-1]) for line in macros.splitlines()
                  if line.startswith('#define __clang_major__ ')), 0)
    if major < 18:
        (out / 'exclusions.txt').write_text('Required lane needs Clang 18+.\n')
        sys.exit(1)
    flags += ['--rtlib=compiler-rt']
fixture = out / 'libfactor-ffi-test.so'
original = root / 'libfactor-ffi-test.so'
backup = out / 'original-fixture.so'
if original.exists():
    shutil.copy2(original, backup)
env = os.environ.copy()
(out / 'tmp').mkdir(exist_ok=True)
env['TMPDIR'] = str(out / 'tmp')
env['FACTOR_REQUIRE_SMALL_FLOATS'] = '1' if a.require_small else '0'
factor = ['./factor', '-resource-path=' + str(root), '-i=' + a.image, '-no-user-init', '-no-monitors']
try:
    built = run('fixture', [a.cc, *flags, '-shared', '-Wl,-z,defs', 'vm/ffi_test.c', '-lm', '-o', str(fixture)])
    run('assembly', [a.cc, *flags, '-S', 'vm/ffi_test.c', '-o', str(out / 'fixture.s')])
    for defect in ['uint_callback', 'array_struct', 'fp_status']:
        source = 'vm/tests/ffi_' + defect + '.c'
        obj = str(out / (defect + '.o'))
        exe = str(out / (defect + '-control'))
        if run(defect + '-object', [a.cc, *flags, '-c', source, '-o', obj]):
            if run(defect + '-link', [a.cc, *flags, '-DABI_CONTROL', source, obj, '-lm', '-o', exe]):
                run(defect + '-control', [exe])
        run(defect + '-assembly', [a.cc, *flags, '-S', source, '-o', str(out / (defect + '.s'))])
    general = run('general-object', [a.cc, *flags, '-c', 'vm/ffi_test_arm64.c', '-o', str(out / 'general.o')])
    if general and run('general-link', [a.cc, *flags, 'vm/tests/ffi_abi_control.c', str(out / 'general.o'), '-o', str(out / 'general-control')]):
        run('general-control', [str(out / 'general-control')])
    if run('fpsimd-link', [a.cc, '-x', 'c++', '-O2', 'vm/tests/linux_arm64_fpsimd.cpp', '-lstdc++', '-o', str(out / 'fpsimd-control')]):
        run('fpsimd-control', [str(out / 'fpsimd-control')], (0,) if a.native_arm64 else (0, 77))
    if built:
        manifest['artifacts']['fixture'] = digest(fixture)
        shutil.copy2(fixture, original)
        thread = out / 'thread-entry'
        if run('thread-link', [a.cxx, '-std=c++17', '-O2', 'vm/tests/thread_entry.cpp',
                '-Wl,--whole-archive', 'libfactor.a', '-Wl,--no-whole-archive',
                '-ldl', '-lm', '-lrt', '-pthread', '-Wl,--export-dynamic', '-o', str(thread)]):
            thread_env = dict(env, FACTOR_REPRO_LIBRARY=str(fixture),
                FACTOR_REPRO_TESTS=str(root / 'basis/compiler/tests/fixtures/linux-runtime.factor'))
            run('thread-runtime', [str(thread), '-resource-path=' + str(root), '-i=' + a.image,
                '-no-user-init', '-no-monitors', '.github/ffi-compare.factor'], env=thread_env)
        if run('small-link', [a.cc, *flags, 'vm/tests/ffi_small_control.c', str(fixture), '-o', str(out / 'small-control')]):
            run('small-control', [str(out / 'small-control')], (0,) if a.require_small else (0, 77))
        if platform.machine() == 'aarch64':
            run('normal', [*factor, '.github/arm64-tests.factor'], env=env)
            run('disabled', [*factor, '-disable-neon-extensions', '.github/arm64-tests.factor'], env=env)
            run('image-save', [*factor, '.github/arm64-feature-cache-save.factor'], env=env)
            run('image-restart', ['./factor', '-i=arm64-feature-cache.image', '-no-user-init', '-no-monitors', '.github/arm64-feature-cache-check.factor'], env=env)
            if Path('arm64-feature-cache.image').exists():
                manifest['artifacts']['restart-image'] = digest('arm64-feature-cache.image')
        run('regressions', [*factor, '.github/ffi-regressions.factor'], env=env)
        run('allocators', [*factor, '.github/ffi-allocators.factor'], env=env)
        if a.full:
            run('compiler', [*factor, '.github/compiler-verify.factor'], env=env)
        run('assertion', [*factor, '.github/ffi-assertion.factor'], env=env)
        assertion = Path('.github/ffi-assertion.factor').read_text()
        negative = out / 'negative-assertion.factor'
        negative.write_text(assertion.replace('{ 3 } [ ffi_test_1 ]', '{ 4 } [ ffi_test_1 ]'))
        run('negative-assertion', [*factor, str(negative)], expected=(1,), env=env)
        if '=== Got:\n3' not in (out / 'negative-assertion.log').read_text():
            raise RuntimeError('Negative assertion did not reach the C-backed test')
        injected = out / 'injected-assertion.factor'
        injected.write_text(negative.read_text().split('\n:test-failures')[0] + '\n')
        suite = out / 'negative-suite.factor'
        suite.write_text(Path('.github/ffi-allocators.factor').read_text().replace(
            'global-value-numbering? on', 'global-value-numbering? on\n' +
            json.dumps(str(injected), ensure_ascii=False) + ' run-test-file'))
        run('negative-suite', [*factor, str(suite)], expected=(1,), env=env)
        if 'Allocator FFI verification failed' not in (out / 'negative-suite.log').read_text():
            raise RuntimeError('Injected assertion did not reach the ordinary suite status check')
        missing = out / 'unavailable.so'
        unavailable = out / 'unavailable.c'
        unavailable.write_text('int ffi_test_small_floats_available(void) { return 0; }\n')
        if run('negative-fixture-build', [a.cc, *flags, '-shared', '-Wl,-z,defs', str(unavailable), '-o', str(missing)]):
            shutil.copy2(missing, original)
            missing_env = dict(env, FACTOR_REQUIRE_SMALL_FLOATS='1')
            run('negative-unavailable', [*factor, '.github/ffi-small.factor'], expected=(1,), env=missing_env)
            if 'Required half/BF16 fixtures unavailable' not in (out / 'negative-unavailable.log').read_text():
                raise RuntimeError('Unavailable fixture control failed for an unrelated reason')
finally:
    if backup.exists():
        shutil.copy2(backup, original)
    elif original.exists():
        original.unlink()
    lines = []
    for log in out.glob('*.log'):
        lines += [log.name + ': ' + line for line in log.read_text(errors='replace').splitlines()
                  if line.startswith(('FFI-', 'C-CONTROL', 'C-SKIP', 'C-LAYOUT', 'TEST FAILURES', 'COMPILER ERRORS'))]
    (out / 'coverage.txt').write_text('\n'.join(lines) + '\n')
    manifest['artifact_hashes'] = {f.name: digest(f) for f in out.iterdir()
                                   if f.is_file() and f.name != 'manifest.json'}
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
sys.exit(0 if all(r['passed'] for r in results) else 1)
