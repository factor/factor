#!/usr/bin/env python3
from pathlib import Path
import subprocess,hashlib,json,io,tarfile
P=Path(__file__).resolve().parent;repo=P.parents[1]
old='ad0fc337de5ce51816f8251fa490f7aee9b74074';new='8780b3c0908ba06be2720c5ac0949e3c68b871e4'
base='/home/erg/factor-compiler-flags-20260909';root='/home/erg/factor-compiler-next3-baseline-20260909';rel='reference/compiler-next3-20260909';h='reference/allocator-speed-crossarch-20260908'
changed=subprocess.check_output(['git','diff','--name-only',old,new,'--','basis','core','extra','vm'],cwd=repo,text=True).splitlines()
expected_paths=['basis/compiler/cfg/register-allocation/rematerialization/rematerialization-tests.factor','basis/compiler/cfg/value-numbering/global/validation/validation-tests.factor','basis/compiler/cfg/value-numbering/global/validation/validation.factor']
assert changed==expected_paths
archive=subprocess.check_output(['git','archive',new,*changed],cwd=repo)
def run(command,**kw):return subprocess.run(['ssh','agent1',command],check=True,**kw)
def put(path,data):run('cat > '+path,input=data.encode() if isinstance(data,str) else data)
expected=json.loads(subprocess.check_output(['ssh','agent1','cat '+base+'/'+h+'/source-expected.json']))
changed_hashes={}
with tarfile.open(fileobj=io.BytesIO(archive)) as t:
 for m in t:
  if m.isfile():
   digest=hashlib.sha256(t.extractfile(m).read()).hexdigest();expected['files'][m.name]=digest;changed_hashes[m.name]=digest
expected['source_commit']=new
run('test ! -e '+root+' && cp -a --reflink=auto '+base+' '+root)
run('tar -xf - -C '+root,input=archive);run('mkdir -p '+root+'/'+rel)
put(root+'/'+h+'/source-expected.json',json.dumps(expected,indent=2)+'\n');put(root+'/.allocator-source-commit',new+'\n')
proof={'source':new,'prepared_image_source':old,'production_and_workloads_identical':True,'changed_test_only_paths':changed_hashes,'base_root':base,'root':root,'image':base+'/reference/compiler-flags-20260909/prepared.image','image_sha256':'358139bcf48356b821c3b3e4159ad5df77c56d921e9fbb99ffa2a4a9e5b608fd','vm_sha256':'5004b96bf99cc5edeecdadafe01f6ccc8697d3708dfdb04005f70e5c2a79922f','selected_words':28500,'source_manifest_paths':len(expected['files'])}
(P/'baseline-source-proof.json').write_text(json.dumps(proof,indent=2)+'\n');put(root+'/'+rel+'/baseline-source-proof.json',json.dumps(proof,indent=2)+'\n')
run('cd '+root+' && python3 '+h+'/source-manifest.py')
print(root,flush=True)
