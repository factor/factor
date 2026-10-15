#!/usr/bin/env python3
"""Build an RV64 FFI fixture while repairing Clang21 packed coercion storage.

Clang emits a six-byte rv_fp_bit alloca followed by a four-byte coercion at
byte four. Reserve eight bytes for those temporaries; retain the original
six-byte C/LLVM struct and its floating-point/integer register convention.
Raw IR and all previous build variants remain separate evidence.
"""
import argparse, hashlib, json, pathlib, shlex, subprocess
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--toolchain-profile', required=True, type=pathlib.Path)
p.add_argument('--source', required=True, type=pathlib.Path)
p.add_argument('--source-revision', required=True)
p.add_argument('--output', required=True, type=pathlib.Path)
p.add_argument('--evidence', required=True, type=pathlib.Path)
a = p.parse_args()
a.evidence.mkdir(parents=True, exist_ok=True)
a.output.parent.mkdir(parents=True, exist_ok=True)
cc = shlex.split(json.loads(a.toolchain_profile.read_text())['cc'])
flags = ['-march=rv64gc', '-mabi=lp64d', '-fPIC']
raw = a.evidence / 'ffi-raw.ll'
fixed = a.evidence / 'ffi-padded.ll'
commands = [cc + flags + ['-O0', '-S', '-emit-llvm', str(a.source), '-o', str(raw)]]
subprocess.run(commands[0], check=True)
s = raw.read_text()
needle = 'alloca %struct.rv_fp_bit, align 1'
assert '%struct.rv_fp_bit = type <{ float, i16 }>' in s, 'Packed C layout changed'
assert s.count(needle) == 4, 'Unexpected packed temporary count; inspect new compiler IR'
assert 'llvm.lifetime.' not in s, 'Inspect lifetime sizes before widening temporaries'
s = s.replace(needle, 'alloca [8 x i8], align 1').replace('optnone ', '')
assert '%struct.rv_fp_bit = type <{ float, i16 }>' in s
fixed.write_text(s)
commands.append(cc + flags + ['-O3', '-shared', str(fixed), '-o', str(a.output)])
subprocess.run(commands[1], check=True)
def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
inputs = sorted(set(a.source.parent.glob('ffi_test*.[ch]')) | set((a.source.parent / 'tests').glob('ffi_*.c')))
metadata = {'variant': 'clang21-packed-temporary-storage-8', 'source_revision': a.source_revision,
 'source': str(a.source), 'source_sha256': sha(a.source), 'commands': commands,
 'compiler_version': subprocess.check_output(cc[:1] + ['--version'], text=True),
 'toolchain_profile_sha256': sha(a.toolchain_profile), 'changed_temporaries': 4,
 'lifetime_annotations': 'absent in unoptimized IR', 'c_struct_bytes': 6,
 'temporary_bytes': 8, 'raw_ir_sha256': sha(raw), 'fixed_ir_sha256': sha(fixed),
 'output': str(a.output), 'output_sha256': sha(a.output),
 'fixture_inputs': {str(f): sha(f) for f in inputs}}
(a.evidence / 'provenance.json').write_text(json.dumps(metadata, indent=2) + '\n')
print(json.dumps({'output': str(a.output), 'sha256': metadata['output_sha256']}))
