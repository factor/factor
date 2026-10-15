#!/usr/bin/env python3
"""Exercise actual GNU32 VM callback allocation with a native struct caller.

The callback body is explicit ABI assembly, not a compiler-generated Factor
body. The boot image must contain the three-operand SPARC32 callback template.
Requires existing GNU32 C++ VM objects; does not certify compiler/io acceptance.
"""
import argparse
import pathlib
import shlex
import subprocess

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--build-dir', type=pathlib.Path, required=True)
p.add_argument('--output', type=pathlib.Path, required=True)
p.add_argument('--image', type=pathlib.Path, required=True)
p.add_argument('--sysroot', type=pathlib.Path, required=True)
a = p.parse_args()
root = pathlib.Path(__file__).resolve().parents[2]
output = a.output.resolve()
output.mkdir(parents=True, exist_ok=True)
flags = ['-m32', '-mcpu=v9', '-ffixed-g2', '-ffixed-g3', '-ffixed-g4', '-ffixed-g5']
objects = []
for name, compiler, extra in [
        ('cpp-callback-allocation-probe.cpp', 'sparc64-linux-gnu-g++', ['-std=c++17']),
        ('cpp-callback-allocation-entry.S', 'sparc64-linux-gnu-gcc', [])]:
    obj = output / (name + '.o')
    subprocess.run([compiler, '-O2', *flags, *extra, '-I', str(root / 'vm'),
                    '-c', str(root / 'misc/sparc' / name), '-o', str(obj)], check=True)
    objects.append(obj)
binary = output / 'cpp-callback-allocation'
plan = subprocess.check_output([
    'make', '-n', 'CONFIG=vm/Config.linux.sparc.32',
    'CC=sparc64-linux-gnu-gcc', 'CXX=sparc64-linux-gnu-g++',
    'BUILD_DIR=' + str(a.build_dir.resolve()), 'EXECUTABLE=' + str(binary),
    'factor-executable'], cwd=root, text=True)
lines = [line for line in plan.splitlines() if line.startswith('sparc64-linux-gnu-g++ -L.')]
assert len(lines) == 1, 'missing unique full VM link command'
link = shlex.split(lines[0])
assert sum(arg.endswith('/main-unix.o') for arg in link) == 1
link = [str(objects[0]) if arg.endswith('/main-unix.o') else arg for arg in link]
link.append(str(objects[1]))
subprocess.run(link, cwd=root, check=True)
with (output / 'run.log').open('w') as log:
    subprocess.run(['qemu-sparc32plus', '-L', str(a.sysroot.resolve()),
                    str(binary), str(a.image.resolve())], cwd=root,
                   stdout=log, stderr=subprocess.STDOUT, timeout=120, check=True)
content = (output / 'run.log').read_text()
assert 'PASS actual full C++ VM callback allocation GNU32 SRET 1681 cases' in content
print(content, end='')
