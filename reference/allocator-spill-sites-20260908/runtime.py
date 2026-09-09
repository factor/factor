#!/usr/bin/env python3
"""Alternating in-process runtime/retired-instruction phases, startup excluded."""
import json
from pathlib import Path
import subprocess
import sys
import threading
import time

root = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(root / 'reference/allocator-speed-20260908'))
from process_usage import usage
art = Path(__file__).resolve().parent
reloads = ['compiler.cfg.linear-scan.numbering', 'compiler.cfg.linear-scan.allocation.spilling',
           'compiler.cfg.linear-scan.assignment', 'compiler.cfg.linear-scan.resolve',
           'compiler.cfg.register-allocation', 'compiler.cfg.register-allocation.backtracking']
expression = 'USING: vocabs.loader parser ; ' + ' '.join(json.dumps(v) + ' reload' for v in reloads)
expression += ' ' + json.dumps(str(art / 'runtime.factor')) + ' run-file'
child = subprocess.Popen([str(root/'factor'), '-i='+str(root/'factor.image'), '-no-user-init',
                          '-e='+expression], cwd=root, stdin=subprocess.PIPE,
                         stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)
done = threading.Event()
def foreground():
    while not done.is_set():
        subprocess.run(['/usr/sbin/taskpolicy', '-B', '-p', str(child.pid)],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        done.wait(1)
thread = threading.Thread(target=foreground)
thread.start()
rows = []
try:
    with (art/'runtime.log').open('w') as log:
        for enabled in [False, True, True, False, False, True, True, False]:
            while True:
                line = child.stdout.readline()
                if not line:
                    raise RuntimeError('Factor exited before READY')
                log.write(line); log.flush()
                if line.strip() == 'READY': break
            before = usage(child.pid)
            started = time.monotonic()
            child.stdin.write('go\n'); child.stdin.flush()
            elapsed_ns = child.stdout.readline().strip()
            if child.stdout.readline().strip() != 'DONE':
                raise RuntimeError('Missing DONE')
            after = usage(child.pid)
            row = dict(enabled=enabled, benchmark_ns=int(elapsed_ns),
                       wall_seconds=time.monotonic()-started,
                       delta={key: after[key]-before[key] for key in before})
            rows.append(row)
            print(json.dumps(row), flush=True)
            child.stdin.write('next\n'); child.stdin.flush()
        child.wait(timeout=15)
        if child.returncode: raise RuntimeError('Factor failed')
finally:
    if child.poll() is None: child.kill(); child.wait()
    done.set(); thread.join()
    (art/'runtime.json').write_text(json.dumps(rows, indent=2)+'\n')
