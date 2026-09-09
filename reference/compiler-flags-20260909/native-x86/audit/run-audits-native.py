#!/usr/bin/env python3
from pathlib import Path
import subprocess,json,hashlib,time,os
R=Path('/home/erg/factor-compiler-flags-audit-20260909');P=R/'reference/compiler-flags-20260909';O=P/'native-audits';O.mkdir(exist_ok=True)
I=Path('/home/erg/factor-compiler-flags-20260909/reference/compiler-flags-20260909/prepared.image')
assert os.getpriority(os.PRIO_PROCESS,0)==0
jobs=[('remat-check','allocator-flags-rematerialization-20260909/check.factor','REMAT-TEST-FAILURES 0'),('remat-metrics','allocator-flags-rematerialization-20260909/metrics.factor',None),('remat-verifier','allocator-flags-rematerialization-20260909/verifier-check.factor','REMAT-TEST-FAILURES 0'),('gvn-check','compiler-gvn-verification-20260909/check.factor','GVN INDEPENDENT VALIDATION PASS'),('callbacks','compiler-flags-safety-20260909/callback-matrix.factor','CALLBACK-MATRIX-COMPLETE: 16 configurations'),('moving-gc','compiler-flags-safety-20260909/moving-gc.factor','MOVING-GC-MATRIX-COMPLETE: 16 configurations, 768 native answers')]
for label,script,marker in jobs:
 script=R/'reference'/script;cmd=['taskset','-c','2',str(R/'factor'),'-i='+str(I),'-no-user-init','-resource-path='+str(R),str(script)]
 print('START',label,flush=True);t=time.time()
 with (O/(label+'.log')).open('wb') as out:q=subprocess.run(cmd,cwd=R,stdout=out,stderr=subprocess.STDOUT)
 raw=(O/(label+'.log')).read_text();ok=q.returncode==0 and (marker is None or marker in raw)
 rows=[]
 if label=='remat-metrics' and ok:
  for line in raw.splitlines():
   try:r=json.loads(line)
   except ValueError:continue
   if isinstance(r,dict):rows.append(r)
  ok=len(rows)==8
  (O/'remat-metrics.json').write_text(json.dumps(rows,indent=2)+'\n')
 status={'ok':ok,'exit_code':q.returncode,'seconds':time.time()-t,'command':cmd,'script_sha256':hashlib.sha256(script.read_bytes()).hexdigest(),'image_sha256':hashlib.sha256(I.read_bytes()).hexdigest(),'vm_sha256':hashlib.sha256((R/'factor').read_bytes()).hexdigest(),'log_sha256':hashlib.sha256((O/(label+'.log')).read_bytes()).hexdigest()}
 (O/(label+'.status.json')).write_text(json.dumps(status,indent=2)+'\n');print('DONE',label,status['seconds'],ok,flush=True)
 assert ok,label
print('ALL NATIVE AUDITS PASS',flush=True)
