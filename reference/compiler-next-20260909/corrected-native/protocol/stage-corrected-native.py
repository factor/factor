from pathlib import Path
import subprocess,hashlib,json,io,tarfile
repo=Path('/Users/erg/factor.worktrees/compiler-next-comparison');rel='reference/compiler-next-20260909';old='eccfc0accc5c513b44701f2e59d4a9bafb7515f0';rev='c6948a99de5ebfb7251c322382dba66d6f8050df'
source='/home/erg/factor-compiler-next-combined-20260909';root='/home/erg/factor-compiler-next-final-c6948-20260909';base='/home/erg/factor-compiler-next-greedy-baseline-20260909';h='reference/allocator-speed-crossarch-20260908'
changed=subprocess.check_output(['git','diff','--name-only',old,rev,'--','basis','core','extra','vm'],cwd=repo,text=True).splitlines()
archive=subprocess.check_output(['git','archive',rev,*changed],cwd=repo)
expected=json.loads((repo/rel/'independent-native-audit/native-combined/provenance/source-expected.json').read_text())
with tarfile.open(fileobj=io.BytesIO(archive)) as t:
 for m in t:
  if m.isfile():expected['files'][m.name]=hashlib.sha256(t.extractfile(m).read()).hexdigest()
expected['source_commit']=rev
assert expected['files']['basis/compiler/cfg/register-allocation/backtracking/backtracking.factor']=='6f82a95b997dd4bec37e9018679da8cdf5fce22b0288b02985eaddc6fd125d87'
assert expected['files']['basis/compiler/cfg/register-allocation/ssa/phases/phases.factor']=='ce6a81a72bb7a1ddb0ad165cf68f2e0dd7df7017a63bf3df5c85a066a85ea134'
def run(s,**kw):return subprocess.run(['ssh','agent1',s],check=True,**kw)
def put(path,data):run('cat > '+path,input=data.encode() if isinstance(data,str) else data)
run('test ! -e '+root+' && cp -a --reflink=auto '+source+' '+root)
run('tar -xf - -C '+root,input=archive)
put(root+'/'+h+'/source-expected.json',json.dumps(expected,indent=2)+'\n')
put(root+'/.allocator-source-commit',rev+'\n')
prep='''USING: vocabs.loader ;
<< "classes.algebra" reload
   "compiler.cfg.register-allocation.ssa.phases" reload
   "compiler.cfg.register-allocation.backtracking" reload >>
USING: allocator-runtime-comparison memory namespaces ;
workloads benchmark-closure benchmark-words set-global
"reference/compiler-next-20260909/prepared.image" save-image-and-exit
'''
put(root+'/'+rel+'/prepare-corrected.factor',prep)
for target in [base,root]:
 for n in ['capture-workload-code.factor','capture-checked.factor']:
  put(target+'/'+rel+'/'+n,(repo/rel/n).read_bytes())
unit='''USING: parser vocabs.loader ;
<< "compiler.cfg.register-allocation.verifier" require
   "compiler.cfg.register-allocation.verifier.rematerialization" require >>
"reference/allocator-tuning-backtracking-20260909/checked-tests.factor" run-file
'''
put(root+'/'+rel+'/corrected-unit.factor',unit)
put('/home/erg/run-corrected-native.py',(repo/rel/'run-corrected-native.py').read_bytes())
run('test "$(readlink -f '+root+'/factor)" = "'+base+'/factor" && getcap '+base+'/factor')
run('cd '+root+' && python3 '+h+'/source-manifest.py && python3 '+rel+'/prepare.py --image '+source+'/'+rel+'/prepared.image --label corrected-prepare --script '+rel+'/prepare-corrected.factor')
print('CORRECTED ROOT PREPARED',root,rev,flush=True)
