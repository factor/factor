"""Retain Windows-generated instructions; translate object-file directives only.
This executes Windows parameter ABI code on the macOS CPU, not Windows itself.
"""
from pathlib import Path
import re
import subprocess
root = Path(__file__).resolve().parent.parent.parent
out = Path(__file__).resolve().parent
subprocess.run(['clang', '-target', 'aarch64-pc-windows-msvc', '-S', '-O2',
                str(root / 'vm/ffi_test_varargs_outgoing.c'), '-o', str(out / 'windows-oracle.s')], check=True)
source = (out / 'windows-oracle.s').read_text()
lines = []
skip = False
for line in source.splitlines():
    if line.startswith('\t.def\tvarout_control;'):
        skip = True
    elif line.startswith('\t.def\tvarout_'):
        skip = False
    if line.strip().startswith('.section'):
        break
    if skip or line.strip().startswith(('.def','.scl','.type','.endef','.seh_','.file')) or '@feat' in line:
        continue
    lines.append(re.sub(r'\bvarout_(\w+)\b', r'_win_varout_\1', line))
(out / 'windows-oracle-macho.s').write_text('\n'.join(lines) + '\n')
subprocess.run(['clang', '-dynamiclib', str(out / 'windows-oracle-macho.s'), '-o', str(out / 'windows-oracle.dylib')], check=True)
