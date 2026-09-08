#!/usr/bin/env python3
"""Alternate source revisions on one physical host, using separate source roots."""
import argparse,subprocess,sys
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument('baseline',type=Path);p.add_argument('candidate',type=Path)
p.add_argument('--rounds',type=int,default=2);p.add_argument('--samples',type=int,default=3)
p.add_argument('--candidate-loop-spills',choices=['on','off'],default='off')
p.add_argument('--linear-scan-remat-attribution',action='store_true')
p.add_argument('--mode',choices=['check','timing'],default='timing')
a=p.parse_args()
allocators=['linear-scan','greedy','backtracking','chordal']
for r in range(a.rounds if a.mode=='timing' else 1):
 order=allocators[r%4:]+allocators[:r%4]
 roots=[('baseline',a.baseline),('candidate',a.candidate)]
 if r%2:roots.reverse()
 for allocator in order:
  for label,root in roots:
   driver=root.resolve()/'reference/allocator-speed-crossarch-20260908/drive.py'
   cmd=[sys.executable,str(driver),label,'--mode',a.mode,'--allocator',allocator,'--round-offset',str(r),'--samples',str(a.samples)]
   cmd+=['--rematerialize','on' if label=='candidate' else 'off','--loop-spills',a.candidate_loop_spills if label=='candidate' else 'off']
   attribution=a.linear_scan_remat_attribution and a.mode=='timing' and label=='candidate' and allocator=='linear-scan'
   off=cmd.copy()
   off[2]='remat-off'
   off[off.index('--rematerialize')+1]='off'
   if attribution and r%2:subprocess.run(off,cwd=root,check=True)
   subprocess.run(cmd,cwd=root,check=True)
   if attribution and not r%2:subprocess.run(off,cwd=root,check=True)
