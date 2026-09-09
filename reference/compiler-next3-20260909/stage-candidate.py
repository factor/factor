#!/usr/bin/env python3
from pathlib import Path
import subprocess,hashlib,json,io,tarfile
P=Path(__file__).resolve().parent;repo=P.parents[1]
base_revision='8780b3c0908ba06be2720c5ac0949e3c68b871e4';revision=subprocess.check_output(['git','rev-parse','020b74ce5d'],cwd=repo,text=True).strip()
base='/home/erg/factor-compiler-next3-baseline-20260909';root='/home/erg/factor-compiler-next3-candidate-20260909';rel='reference/compiler-next3-20260909';h='reference/allocator-speed-crossarch-20260908'
changed=subprocess.check_output(['git','diff','--name-only',base_revision,revision,'--','basis','core','extra','vm'],cwd=repo,text=True).splitlines()
refs=[]
for directory in ['compiler-next3-loops-20260909','compiler-next3-representations-20260909','compiler-next3-memory-20260909','compiler-next3-vectorization-20260909']:
 refs += [p for p in subprocess.check_output(['git','ls-tree','-r','--name-only',revision,'reference/'+directory],cwd=repo,text=True).splitlines() if p.endswith('.factor')]
archive=subprocess.check_output(['git','archive',revision,*changed,*refs],cwd=repo)
def run(command,**kw):return subprocess.run(['ssh','agent1',command],check=True,**kw)
def put(path,data):run('cat > '+path,input=data.encode() if isinstance(data,str) else data)
expected=json.loads(subprocess.check_output(['ssh','agent1','cat '+base+'/'+h+'/source-expected.json']))
source_files={};reference_files={}
with tarfile.open(fileobj=io.BytesIO(archive)) as t:
 for m in t:
  if m.isfile():
   digest=hashlib.sha256(t.extractfile(m).read()).hexdigest()
   if m.name in changed:expected['files'][m.name]=digest;source_files[m.name]=digest
   else:reference_files[m.name]=digest
expected['source_commit']=revision
run('test ! -e '+root+' && cp -a --reflink=auto '+base+' '+root)
run('tar -xf - -C '+root,input=archive)
put(root+'/'+h+'/source-expected.json',json.dumps(expected,indent=2)+'\n');put(root+'/.allocator-source-commit',revision+'\n')
harness={}
for n in ['features.factor','witnesses.factor','timing.factor','drive.py','prepare.factor','prepare.py','queue.py','validate-checks.py']:
 b=(P/n).read_bytes();put(root+'/'+rel+'/'+n,b);harness[n]=hashlib.sha256(b).hexdigest()
manifest={'source':revision,'base_source':base_revision,'root':root,'changed_source':source_files,'witness_sources':reference_files,'harness_sha256':harness,'source_manifest_paths':len(expected['files']),'input_image':base+'/reference/compiler-flags-20260909/prepared.image','input_image_sha256':'358139bcf48356b821c3b3e4159ad5df77c56d921e9fbb99ffa2a4a9e5b608fd'}
(P/'candidate-stage.json').write_text(json.dumps(manifest,indent=2)+'\n');put(root+'/'+rel+'/candidate-stage.json',json.dumps(manifest,indent=2)+'\n')
run('cd '+root+' && python3 '+h+'/source-manifest.py && python3 '+rel+'/prepare.py --image '+manifest['input_image']+' --label native-prepare')
print(root,revision,flush=True)
