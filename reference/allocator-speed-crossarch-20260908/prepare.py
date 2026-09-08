#!/usr/bin/env python3
"""Prepare a frozen image, keeping macOS setup out of background policy."""
import argparse,json,platform,subprocess,time
from pathlib import Path
root=Path(__file__).resolve().parents[2]
out=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--image',default=str(root/'factor.image'));p.add_argument('--label',default='prepare');a=p.parse_args()
cmd=[str(root/'factor'),'-resource-path='+str(root),'-i='+str(Path(a.image).resolve()),'-no-user-init',str(out/'prepare.factor')]
if platform.system()=='Linux':cmd=['taskset','-c','2']+cmd
start=time.monotonic();policies=[]
with (out/(a.label+'.log')).open('w') as f:
 child=subprocess.Popen(cmd,cwd=root,stdout=f,stderr=subprocess.STDOUT)
 while child.poll() is None:
  time.sleep(1)
  if platform.system()=='Darwin' and child.poll() is None:
   r=subprocess.run(['taskpolicy','-B','-p',str(child.pid)],capture_output=True,text=True)
   policies.append(dict(status=r.returncode,stderr=r.stderr))
 status=child.wait()
(out/(a.label+'.status.json')).write_text(json.dumps(dict(command=cmd,status=status,seconds=time.monotonic()-start,taskpolicy=policies),indent=2)+'\n')
raise SystemExit(status)
