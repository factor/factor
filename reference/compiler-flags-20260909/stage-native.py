#!/usr/bin/env python3
from pathlib import Path
import subprocess,hashlib,json,io,tarfile
P=Path(__file__).resolve().parent;repo=P.parents[1]
old='a7f554b613bd763fb7fbfc520643b75b321a6e16';rev='ad0fc337de5ce51816f8251fa490f7aee9b74074'
base='/home/erg/factor-compiler-next-final-c6948-20260909';root='/home/erg/factor-compiler-flags-20260909';rel='reference/compiler-flags-20260909';h='reference/allocator-speed-crossarch-20260908'
changed=subprocess.check_output(['git','diff','--name-only',old,rev,'--','basis','core','extra','vm'],cwd=repo,text=True).splitlines();assert len(changed)==4
archive=subprocess.check_output(['git','archive',rev,*changed],cwd=repo)
def run(command,**kw):return subprocess.run(['ssh','agent1',command],check=True,**kw)
def put(path,data):run('cat > '+path,input=data.encode() if isinstance(data,str) else data)
expected=json.loads(subprocess.check_output(['ssh','agent1','cat '+base+'/'+h+'/source-expected.json']))
with tarfile.open(fileobj=io.BytesIO(archive)) as t:
 for m in t:
  if m.isfile():expected['files'][m.name]=hashlib.sha256(t.extractfile(m).read()).hexdigest()
expected['source_commit']=rev
run('test ! -e '+root+' && cp -a --reflink=auto '+base+' '+root)
run('tar -xf - -C '+root,input=archive)
run('mkdir -p '+root+'/'+rel)
put(root+'/'+h+'/source-expected.json',json.dumps(expected,indent=2)+'\n');put(root+'/.allocator-source-commit',rev+'\n')
for n in ['timing.factor','drive.py','prepare.factor','prepare.py']:put(root+'/'+rel+'/'+n,(P/n).read_bytes())
run('cd '+root+' && python3 '+h+'/source-manifest.py && python3 '+rel+'/prepare.py --image '+base+'/reference/compiler-next-20260909/prepared.image --label native-prepare --script '+rel+'/prepare.factor')
print(root,rev,flush=True)
