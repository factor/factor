#!/usr/bin/env python3
from pathlib import Path
import subprocess,hashlib,json,io,tarfile
P=Path(__file__).resolve().parent;repo=P.parents[1]
old='a7f554b613bd763fb7fbfc520643b75b321a6e16';rev=subprocess.check_output(['git','rev-parse','04fa5fdbba'],cwd=repo,text=True).strip()
base='/home/erg/factor-compiler-next-final-c6948-20260909';root='/home/erg/factor-compiler-next2-class-info-20260909';rel='reference/compiler-next-20260909';h='reference/allocator-speed-crossarch-20260908'
changed=subprocess.check_output(['git','diff','--name-only',old,rev,'--','basis','core','extra','vm'],cwd=repo,text=True).splitlines();assert len(changed)==2 and all('/propagation/info/' in n for n in changed)
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
put(root+'/'+h+'/source-expected.json',json.dumps(expected,indent=2)+'\n');put(root+'/.allocator-source-commit',rev+'\n')
prep='''USING: vocabs.loader ;
<< "compiler.tree.propagation.info" reload >>
USING: allocator-runtime-comparison memory namespaces ;
workloads benchmark-closure benchmark-words set-global
"reference/compiler-next-20260909/prepared.image" save-image-and-exit
'''
put(root+'/'+rel+'/prepare-class-info.factor',prep)
unit='''USING: vocabs.loader tools.test namespaces sequences system ;
"compiler.tree.propagation.info" require
"compiler.tree.propagation.info" test
"classes.algebra" require "classes.algebra" test
:test-failures test-failures get empty? [ 0 ] [ 1 ] if exit
'''
put(root+'/'+rel+'/class-info-unit.factor',unit)
run('cd '+root+' && python3 '+h+'/source-manifest.py && python3 '+rel+'/prepare.py --image '+base+'/'+rel+'/prepared.image --label class-info-prepare --script '+rel+'/prepare-class-info.factor')
print(root,rev,flush=True)
