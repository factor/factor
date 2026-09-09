#!/usr/bin/env python3
"""Stage a new source-equivalent root; do not modify retained native datasets."""
from pathlib import Path
import hashlib,io,json,subprocess,tarfile
P=Path(__file__).resolve().parent;repo=P.parents[1]
source=subprocess.check_output(['git','rev-parse','6b14328972'],cwd=repo,text=True).strip()
prior=subprocess.check_output(['git','rev-parse','020b74ce5d'],cwd=repo,text=True).strip()
base='/home/erg/factor-compiler-next3-candidate-20260909';root='/home/erg/factor-compiler-combined-20260909';manifest_dir='reference/allocator-speed-crossarch-20260908'
changed=subprocess.check_output(['git','diff','--name-only',prior,source,'--','basis','core','extra','vm'],cwd=repo,text=True).splitlines()
assert changed==['basis/compiler/cfg/slp/slp-tests.factor'],changed
archive=subprocess.check_output(['git','archive',source,*changed],cwd=repo)
def run(command,**kw):return subprocess.run(['ssh','agent1',command],check=True,**kw)
def put(path,data):run('cat > '+path,input=data.encode() if isinstance(data,str) else data)
expected=json.loads(subprocess.check_output(['ssh','agent1','cat '+base+'/'+manifest_dir+'/source-expected.json']))
with tarfile.open(fileobj=io.BytesIO(archive)) as t:
 for m in t:
  if m.isfile():expected['files'][m.name]=hashlib.sha256(t.extractfile(m).read()).hexdigest()
expected['source_commit']=source
run('test ! -e '+root+' && cp -a --reflink=auto '+base+' '+root)
run('tar -xf - -C '+root,input=archive)
put(root+'/'+manifest_dir+'/source-expected.json',json.dumps(expected,indent=2)+'\n');put(root+'/.allocator-source-commit',source+'\n')
put(root+'/.allocator-prepared-source-commit','awaiting-combined-preparation:'+source+'\n')
run('mkdir -p '+root+'/reference/compiler-combined-20260909')
proof={'source_commit':source,'prior_production_commit':prior,'native_root':root,'seed_root':base,'only_source_changes':changed,'only_test_changes':True,'production_equal':True,'source_manifest_paths':len(expected['files']),'input_image':base+'/reference/compiler-next3-20260909/prepared.image','input_image_sha256':'15a12ce2c70d85f4a43adb10f5816cabf68492ae68dfbccd44b8bedb4ebe4e45','vm_sha256':'5004b96bf99cc5edeecdadafe01f6ccc8697d3708dfdb04005f70e5c2a79922f'}
(P/'stage.json').write_text(json.dumps(proof,indent=2)+'\n');put(root+'/reference/compiler-combined-20260909/native-stage.json',json.dumps(proof,indent=2)+'\n')
run('cd '+root+' && python3 '+manifest_dir+'/source-manifest.py')
print(root,source,flush=True)
