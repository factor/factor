#!/usr/bin/env python3
"""Launch one explicit native queue at nice0 without shell backgrounding."""
from pathlib import Path
import argparse,hashlib,json,os,subprocess,time
p=argparse.ArgumentParser();p.add_argument('mode',choices=['check','timing']);a=p.parse_args()
root=Path('/home/erg/factor-compiler-combined-20260909');out=root/'reference/compiler-combined-20260909'
assert os.getpriority(os.PRIO_PROCESS,0)==0
command=['python3',str(out/'queue.py'),a.mode,'--prefix','native-combined']
with (out/(a.mode+'-queue.log')).open('wb') as log:
 child=subprocess.Popen(command,cwd=root,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
record={'pid':child.pid,'command':command,'launched_unix':time.time(),'nice':os.getpriority(os.PRIO_PROCESS,child.pid),'queue_sha256':hashlib.sha256((out/'queue.py').read_bytes()).hexdigest()}
(out/(a.mode+'-queue-launch.json')).write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record))
