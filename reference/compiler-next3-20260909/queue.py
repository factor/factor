#!/usr/bin/env python3
"""Explicit check or balanced timing queue; never auto-advance from checks."""
from pathlib import Path
import argparse,subprocess,os,platform
P=Path(__file__).resolve().parent;R=P.parents[1]
p=argparse.ArgumentParser();p.add_argument('mode',choices=['check','timing']);p.add_argument('--prefix',required=True);p.add_argument('--image',type=Path,default=P/'prepared.image');p.add_argument('--protocol',choices=['shared','individual'],default='shared');p.add_argument('--feature',choices=['loops','representations','memory','slp']);a=p.parse_args()
if platform.system()=='Linux':assert os.getpriority(os.PRIO_PROCESS,0)==0
features=['loops','representations','memory','slp']
if a.mode=='timing':
 subprocess.run(['python3',str(P/'validate-checks.py'),str(P),'--prefix',a.prefix],check=True,cwd=R)
 if a.protocol=='shared':
  assert a.feature is None,'Shared protocol includes all four features'
  jobs=[('loops','off',a.prefix+'-baseline',0)]+[(f,'on',a.prefix+'-'+f+'-on',0) for f in features]+[(f,'on',a.prefix+'-'+f+'-on',1) for f in reversed(features)]+[('loops','off',a.prefix+'-baseline',1)]
 else:
  jobs=[(f,s,a.prefix+'-'+f+'-'+s,n) for f in ([a.feature] if a.feature else features) for s,n in [('off',0),('on',0),('on',1),('off',1)]]
else:
 assert a.feature is None,'Run all five checked configurations'
 jobs=[('loops','off',a.prefix+'-baseline',0)]+[(f,'on',a.prefix+'-'+f+'-on',0) for f in features]
for feature,state,label,ordinal in jobs:
 cmd=['python3',str(P/'drive.py'),label,'--mode',a.mode,'--allocator','linear-scan','--feature',feature,'--enabled',state,'--samples','3','--round-offset',str(ordinal),'--image',str(a.image.resolve())]
 subprocess.run(cmd,check=True,cwd=R)
print('FEATURE '+a.mode.upper()+' QUEUE COMPLETE',flush=True)
