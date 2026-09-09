#!/usr/bin/env python3
"""Fresh-process untimed gate with exact source/image/script provenance."""
from pathlib import Path
import argparse,subprocess,platform,time,hashlib,json,os
P=Path(__file__).resolve().parent;R=P.parents[1]
p=argparse.ArgumentParser();p.add_argument('--script',type=Path,required=True);p.add_argument('--label',required=True);p.add_argument('--marker',required=True);p.add_argument('--image',type=Path,default=P/'prepared.image');p.add_argument('--timeout',type=float,default=180);a=p.parse_args()
script=a.script if a.script.is_absolute() else R/a.script;image=a.image.resolve()
if platform.system()=='Linux':assert os.getpriority(os.PRIO_PROCESS,0)==0
cmd=[str(R/'factor'),'-i='+str(image),'-no-user-init','-resource-path='+str(R),str(script)]
if platform.system()=='Linux':cmd=['taskset','-c','2']+cmd
log=P/(a.label+'.log');start=time.time();timed_out=False;policies=[]
with log.open('wb') as f:
 child=subprocess.Popen(cmd,cwd=R,stdout=f,stderr=subprocess.STDOUT)
 while child.poll() is None:
  time.sleep(0.25)
  if time.time()-start>a.timeout:child.kill();timed_out=True;break
  if platform.system()=='Darwin' and child.poll() is None:
   q=subprocess.run(['taskpolicy','-B','-p',str(child.pid)],capture_output=True,text=True);policies.append({'returncode':q.returncode,'stderr':q.stderr})
 code=child.wait()
raw=log.read_bytes();ok=code==0 and a.marker in raw.decode(errors='replace')
result={'ok':ok,'exit_code':code,'timed_out':timed_out,'seconds':time.time()-start,'source_commit':(R/'.allocator-source-commit').read_text().strip(),'command':cmd,'script_sha256':hashlib.sha256(script.read_bytes()).hexdigest(),'image_sha256':hashlib.sha256(image.read_bytes()).hexdigest(),'vm_sha256':hashlib.sha256((R/'factor').read_bytes()).hexdigest(),'log_sha256':hashlib.sha256(raw).hexdigest(),'taskpolicy':policies}
(P/(a.label+'.status.json')).write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result),flush=True);raise SystemExit(0 if ok else 1)
