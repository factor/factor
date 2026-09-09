#!/usr/bin/env python3
from pathlib import Path
import subprocess,json,hashlib,io,tarfile
P=Path(__file__).resolve().parent;repo=P.parents[1]
base='/home/erg/factor-compiler-flags-20260909';root='/home/erg/factor-compiler-flags-audit-20260909'
overlays=[('02be782537',['basis/compiler/cfg/register-allocation/rematerialization/rematerialization-tests.factor']),('666a994e14',['reference/allocator-flags-rematerialization-20260909/check.factor','reference/allocator-flags-rematerialization-20260909/metrics.factor','reference/allocator-flags-rematerialization-20260909/verifier-check.factor']),('0c8afbdb55',['basis/compiler/cfg/value-numbering/global/validation','reference/compiler-gvn-verification-20260909/check.factor']),('34c98f134c',['reference/compiler-flags-safety-20260909/callback-matrix.factor','reference/compiler-flags-safety-20260909/callback-execute.factor','reference/compiler-flags-safety-20260909/moving-gc.factor'])]
def run(cmd,**kw):return subprocess.run(['ssh','agent1',cmd],check=True,**kw)
run('test ! -e '+root+' && cp -a --reflink=auto '+base+' '+root)
manifest={'production_source':'ad0fc337de5ce51816f8251fa490f7aee9b74074','base':base,'audit_root':root,'overlays':[]}
for rev,paths in overlays:
 full=subprocess.check_output(['git','rev-parse',rev],cwd=repo,text=True).strip();data=subprocess.check_output(['git','archive',rev,*paths],cwd=repo);files={}
 with tarfile.open(fileobj=io.BytesIO(data)) as t:
  for m in t:
   if m.isfile():files[m.name]=hashlib.sha256(t.extractfile(m).read()).hexdigest()
 run('tar -xf - -C '+root,input=data);manifest['overlays'].append({'commit':full,'files':files})
run('cat > '+root+'/reference/compiler-flags-20260909/audit-source.json',input=(json.dumps(manifest,indent=2)+'\n').encode())
(P/'audit-source.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(root,flush=True)
