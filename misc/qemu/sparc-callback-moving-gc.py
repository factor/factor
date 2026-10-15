#!/usr/bin/env python3
"""Force real VM code compaction inside begin_callback and check repaired return.

Requires already-built GNU Linux SPARC VM objects and a matching boot image.
This proves callback moving-GC behavior, not the full compiler/io acceptance gate.
"""
import argparse
import json
import pathlib
import re
import shlex
import subprocess
import time

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--bits', type=int, choices=(32, 64), required=True)
p.add_argument('--build-dir', type=pathlib.Path, required=True)
p.add_argument('--output', type=pathlib.Path, required=True)
p.add_argument('--image', type=pathlib.Path, required=True)
p.add_argument('--sysroot', type=pathlib.Path, required=True)
p.add_argument('--compiler', default='sparc64-linux-gnu-g++')
p.add_argument('--cc', default='sparc64-linux-gnu-gcc')
p.add_argument('--qemu')
p.add_argument('--timeout', type=int, default=120)
a = p.parse_args()
root = pathlib.Path(__file__).resolve().parents[2]
a.output = a.output.resolve()
a.output.mkdir(parents=True, exist_ok=True)
flags = ['-m32', '-mcpu=v9'] if a.bits == 32 else ['-m64', '-mcpu=v9', '-mstack-bias']
source = (root / 'vm/contexts.cpp').read_text()
needle = '  spare_ctx = new_context();\n  callback_ids.push_back'
assert source.count(needle) == 1, 'begin_callback injection point changed'
injected = '''  spare_ctx = new_context();
  cell proof_frame = ctx->callstack_top;
  cell proof_before = sparc_frame_return_address(proof_frame);
  gc(COLLECT_COMPACT_OP, 0);
  fprintf(stderr, "SPARC callback code return before=%zx after=%zx\\n",
          (size_t)proof_before,
          (size_t)sparc_frame_return_address(proof_frame));
  callback_ids.push_back'''
proof_source = a.output / 'contexts.cpp'
proof_source.write_text(source.replace(needle, injected))
proof_object = a.output / 'contexts.o'
subprocess.run([a.compiler, '-O3', '-fPIC', '-std=c++17', *flags,
                '-ffixed-g2', '-ffixed-g3', '-ffixed-g4', '-ffixed-g5',
                '-I', str(root / 'vm'), '-c', str(proof_source), '-o', str(proof_object)], check=True)
binary = a.output / 'factor-moving-gc'
make = ['make', '-n', f'CONFIG=vm/Config.linux.sparc.{a.bits}',
        'ARCHITECTURE_FLAG=' + ' '.join(flags), f'CC={a.cc}', f'CXX={a.compiler}',
        f'BUILD_DIR={a.build_dir.resolve()}', f'EXECUTABLE={binary}', 'factor-executable']
plan = subprocess.check_output(make, cwd=root, text=True)
link_lines = [line for line in plan.splitlines() if line.startswith(a.compiler + ' -L.')]
assert len(link_lines) == 1, 'missing unique VM link command'
link = shlex.split(link_lines[0])
assert all(pathlib.Path(x).exists() for x in link if x.endswith('.o')), 'build the VM first'
assert sum(x.endswith('/contexts.o') for x in link) == 1
link = [str(proof_object) if x.endswith('/contexts.o') else x for x in link]
subprocess.run(link, cwd=root, check=True)
for name in ('basis', 'core', 'extra', 'LICENSE.txt'):
    target = a.output / name
    if not target.exists():
        target.symlink_to(root / name)
qemu = a.qemu or ('qemu-sparc32plus' if a.bits == 32 else 'qemu-sparc64')
command = [qemu, '-L', str(a.sysroot.resolve()), str(binary),
           '-i=' + str(a.image.resolve()), '-no-user-init', '-include=math compiler threads io tools']
log = a.output / 'run.log'
with log.open('w') as stream:
    process = subprocess.Popen(command, cwd=root, stdin=subprocess.DEVNULL,
                               stdout=stream, stderr=subprocess.STDOUT)
    deadline = time.monotonic() + a.timeout
    try:
        while time.monotonic() < deadline:
            content = log.read_text()
            match = re.search(r'SPARC callback code return before=([0-9a-f]+) after=([0-9a-f]+)', content)
            if match and 'Loading resource:basis/bootstrap/stage2.factor' in content:
                before, after = (int(x, 16) for x in match.groups())
                assert before != after, 'compaction did not move the callback return PC'
                result = {'status': 'pass', 'scope': 'callback code compaction and repaired generated return',
                          'bits': a.bits, 'before': hex(before), 'after': hex(after),
                          'log': str(log), 'command': command}
                (a.output / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
                print(json.dumps(result))
                break
            if process.poll() is not None:
                raise RuntimeError('VM exited before repaired continuation proof; see ' + str(log))
            time.sleep(0.25)
        else:
            raise TimeoutError('callback proof timed out; see ' + str(log))
    finally:
        if process.poll() is None:
            process.terminate()
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
