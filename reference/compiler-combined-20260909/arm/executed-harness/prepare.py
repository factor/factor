#!/usr/bin/env python3
"""Prepare a frozen image, keeping macOS setup out of background policy."""
import argparse,hashlib,json,platform,subprocess,time
from pathlib import Path
root=Path(__file__).resolve().parents[2]
out=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--image',default=str(root/'factor.image'));p.add_argument('--label',default='prepare');p.add_argument('--script',type=Path,default=out/'prepare.factor');a=p.parse_args()
cmd=[str(root/'factor'),'-resource-path='+str(root),'-i='+str(Path(a.image).resolve()),'-no-user-init',str(a.script.resolve())]
if platform.system()=='Linux':cmd=['taskset','-c','2']+cmd
def digest(path):
 with Path(path).open('rb') as source:
  result=hashlib.sha256()
  for chunk in iter(lambda:source.read(1024*1024),b''):result.update(chunk)
 return result.hexdigest()
marker=root/'.compiler-combined-source-commit'
revision=marker.read_text().strip() if marker.exists() else subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()
prepared_marker=root/'.compiler-combined-prepared-source-commit'
prepared_marker.write_text('preparing:'+revision+'\n')
initial_image_sha256=digest(a.image)
start=time.monotonic();policies=[]
with (out/(a.label+'.log')).open('w') as f:
 child=subprocess.Popen(cmd,cwd=root,stdout=f,stderr=subprocess.STDOUT)
 while child.poll() is None:
  time.sleep(1)
  if platform.system()=='Darwin' and child.poll() is None:
   r=subprocess.run(['taskpolicy','-B','-p',str(child.pid)],capture_output=True,text=True)
   policies.append(dict(status=r.returncode,stderr=r.stderr))
 status=child.wait()
prepared=out/'prepared.image'
result=dict(command=cmd,status=status,seconds=time.monotonic()-start,taskpolicy=policies,
 source_commit=revision,initial_image_sha256=initial_image_sha256,
 preparation_script_sha256=digest(a.script))
if status==0:
 result['prepared_image_sha256']=digest(prepared)
 current=marker.read_text().strip() if marker.exists() else subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()
 if current!=revision:
  status=1;result['status']=1;result['failure']='source changed during image preparation'
 else:prepared_marker.write_text(revision+'\n')
(out/(a.label+'.status.json')).write_text(json.dumps(result,indent=2)+'\n')
raise SystemExit(status)
