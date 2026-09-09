#!/usr/bin/env python3
import argparse,json,os,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('mode',choices=['check','timing']);a=p.parse_args()
ROOT=Path('/home/erg/factor-compiler-flags-20260909');OUT=ROOT/'reference/compiler-flags-20260909'
assert os.getpriority(os.PRIO_PROCESS,0)==0
assert (ROOT/'.allocator-source-commit').read_text().strip()=='ad0fc337de5ce51816f8251fa490f7aee9b74074'
configs=['00','10','01','11'] if a.mode=='check' else ['00','10','11','01','01','11','10','00']
counts={}
for config in configs:
 n=counts.get(config,0);counts[config]=n+1
 command=['python3',str(OUT/'drive.py'),'native-'+config,'--allocator','linear-scan','--mode',a.mode,'--samples','3','--round-offset',str(n),'--gvn','on' if config[0]=='1' else 'off','--rematerialize','on' if config[1]=='1' else 'off','--loop-spills','off','--image',str(OUT/'prepared.image')]
 subprocess.run(command,cwd=ROOT,check=True)
print('NATIVE FLAGS '+a.mode.upper()+' COMPLETE',flush=True)
