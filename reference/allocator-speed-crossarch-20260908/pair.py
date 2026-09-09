#!/usr/bin/env python3
"""Alternate source revisions on one physical host, using separate source roots."""
import argparse,json,subprocess,sys
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument('baseline',type=Path);p.add_argument('candidate',type=Path)
p.add_argument('--allocators',nargs='+',choices=['linear-scan','greedy','backtracking','chordal'])
p.add_argument('--rounds',type=int,default=2);p.add_argument('--samples',type=int,default=3)
p.add_argument('--baseline-rematerialize',choices=['on','off'],default='off')
p.add_argument('--candidate-rematerialize',choices=['on','off'],default='on')
p.add_argument('--baseline-loop-spills',choices=['on','off'],default='off')
p.add_argument('--dry-run',action='store_true')
p.add_argument('--candidate-loop-spills',choices=['on','off'],default='off')
p.add_argument('--linear-scan-remat-attribution',action='store_true')
p.add_argument('--mode',choices=['check','timing'],default='timing')
a=p.parse_args()
if a.linear_scan_remat_attribution and a.candidate_rematerialize != 'on':
 p.error('rematerialization attribution requires candidate rematerialization on')
if a.rounds < 1 or a.samples < 1:p.error('rounds and samples must be positive')
def run(cmd, root):
 if a.dry_run:print(json.dumps(dict(cwd=str(root.resolve()),command=cmd)))
 else:subprocess.run(cmd,cwd=root,check=True)
allocators=a.allocators or ['linear-scan','greedy','backtracking','chordal']
for r in range(a.rounds if a.mode=='timing' else 1):
 rotation=r%len(allocators)
 order=allocators[rotation:]+allocators[:rotation]
 roots=[('baseline',a.baseline),('candidate',a.candidate)]
 if r%2:roots.reverse()
 for allocator in order:
  for label,root in roots:
   driver=root.resolve()/'reference/allocator-speed-crossarch-20260908/drive.py'
   cmd=[sys.executable,str(driver),label,'--mode',a.mode,'--allocator',allocator,'--round-offset',str(r),'--samples',str(a.samples)]
   cmd+=['--rematerialize',a.candidate_rematerialize if label=='candidate' else a.baseline_rematerialize,'--loop-spills',a.candidate_loop_spills if label=='candidate' else a.baseline_loop_spills]
   attribution=a.linear_scan_remat_attribution and a.mode=='timing' and label=='candidate' and allocator=='linear-scan'
   off=cmd.copy()
   off[2]='remat-off'
   off[off.index('--rematerialize')+1]='off'
   if attribution and r%2:run(off,root)
   run(cmd,root)
   if attribution and not r%2:run(off,root)
