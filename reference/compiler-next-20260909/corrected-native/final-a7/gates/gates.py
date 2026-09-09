#!/usr/bin/env python3
"""Retain strict callback and moving-GC gates, separate from timing processes."""
import argparse, hashlib, json, os, platform, subprocess, time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--image', type=Path, required=True)
p.add_argument('--cpu', default='6')
a = p.parse_args()
source = (ROOT / '.allocator-source-commit').read_text().strip()
assert (ROOT / '.allocator-prepared-source-commit').read_text().strip() == source
for script, marker in [('callback-matrix.factor', 'CALLBACK-MATRIX-COMPLETE'),
                       ('moving-gc.factor', 'MOVING-GC-MATRIX-COMPLETE')]:
    command = [str(ROOT / 'factor'), '-resource-path=' + str(ROOT),
               '-i=' + str(a.image.resolve()), '-no-user-init', str(OUT / script)]
    if platform.system() == 'Linux': command = ['taskset', '-c', a.cpu] + command
    start = time.monotonic(); before = os.getloadavg(); policies = []
    log = OUT / (script + '.log')
    with log.open('w') as output:
        child = subprocess.Popen(command, cwd=ROOT, stdout=output, stderr=subprocess.STDOUT)
        while child.poll() is None:
            time.sleep(1)
            if platform.system() == 'Darwin' and child.poll() is None:
                result = subprocess.run(['taskpolicy', '-B', '-p', str(child.pid)], capture_output=True, text=True)
                policies.append(dict(exit_code=result.returncode, stderr=result.stderr))
    text = log.read_text(errors='replace')
    ok = child.returncode == 0 and marker in text
    status = dict(ok=ok, exit_code=child.returncode, source_commit=source,
                  seconds=time.monotonic()-start, command=command,
                  host_load_before=before, host_load_after=os.getloadavg(),
                  final_value_verifier=True, rematerialization=[False, True],
                  gvn=False, backtracking_loop_spills=True, taskpolicy=policies,
                  script_sha256=hashlib.sha256((OUT / script).read_bytes()).hexdigest())
    (OUT / (script + '.status.json')).write_text(json.dumps(status, indent=2)+'\n')
    print(script, 'PASS' if ok else 'FAIL', round(status['seconds'], 2), flush=True)
    if not ok: raise SystemExit(str(log))
