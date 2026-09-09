#!/usr/bin/env python3
"""Strictly collect and report a completed local-host matrix."""
import argparse,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('baseline');p.add_argument('candidate');p.add_argument('output',type=Path)
p.add_argument('--architecture',required=True)
p.add_argument('--baseline-label',default='baseline');p.add_argument('--candidate-label',default='candidate')
a=p.parse_args()
def run(*args):subprocess.run([sys.executable,*map(str,args)],check=True)
run(HERE/'collect.py',a.baseline,a.candidate,a.output,
    '--baseline-source','7b6cd9519a71960a4fb0385bf6ceeaf66097d618',
    '--candidate-source','5c848c90f63cea092191b70e1678bec4441e0238',
    '--baseline-label',a.baseline_label,'--candidate-label',a.candidate_label)
run(ROOT/'reference/allocator-speed-crossarch-20260908/analyze.py',a.output,'--require-complete','--min-samples','6')
run(ROOT/'reference/allocator-full-comparison-20260908/rank.py',a.output/'summary.json','--output',a.output/'final-rank')
run(HERE/'diagnostics.py',a.output)
run(HERE/'report.py',a.output,'--architecture',a.architecture)
print('FINAL ACCEPTED',a.output,flush=True)
