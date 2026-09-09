#!/usr/bin/env python3
"""Checked all-off/all-on gates, then a balanced OFF/ON/ON/OFF queue."""
from pathlib import Path
import argparse,subprocess,os,platform
P=Path(__file__).resolve().parent;R=P.parents[1]
p=argparse.ArgumentParser();p.add_argument('mode',choices=['check','timing']);p.add_argument('--prefix',required=True);p.add_argument('--image',type=Path,default=P/'prepared.image');a=p.parse_args()
if platform.system()=='Linux':assert os.getpriority(os.PRIO_PROCESS,0)==0
if a.mode=='timing':
 subprocess.run(['python3',str(P/'validate-checks.py'),str(P),'--prefix',a.prefix],check=True,cwd=R)
 jobs=[('off',0),('on',0),('on',1),('off',1)]
else:jobs=[('off',0),('on',0)]
for state,ordinal in jobs:
 cmd=['python3',str(P/'drive.py'),a.prefix+'-'+state,'--mode',a.mode,'--allocator','linear-scan','--feature','all','--enabled',state,'--samples','3','--round-offset',str(ordinal),'--image',str(a.image.resolve())]
 subprocess.run(cmd,check=True,cwd=R)
print('COMBINED '+a.mode.upper()+' QUEUE COMPLETE',flush=True)
