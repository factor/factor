from pathlib import Path
import subprocess,hashlib,json,io,tarfile
repo=Path('/Users/erg/factor.worktrees/compiler-next-comparison');h='reference/allocator-speed-crossarch-20260908';n='reference/compiler-next-20260909';r='/home/erg/factor-compiler-next-final-c6948-20260909';old='c6948a99de5ebfb7251c322382dba66d6f8050df';rev='a7f554b613bd763fb7fbfc520643b75b321a6e16'
changed=subprocess.check_output(['git','diff','--name-only',old,rev,'--','basis','core','extra','vm'],cwd=repo,text=True).splitlines()
assert all(p.endswith('-tests.factor') or p.endswith('.md') for p in changed),changed
archive=subprocess.check_output(['git','archive',rev,*changed],cwd=repo)
def run(s,**kw):return subprocess.run(['ssh','agent1',s],check=True,**kw)
def put(path,data):run('cat > '+path,input=data.encode() if isinstance(data,str) else data)
expected=json.loads(subprocess.check_output(['ssh','agent1','cat '+r+'/'+h+'/source-expected.json']))
with tarfile.open(fileobj=io.BytesIO(archive)) as t:
 for m in t:
  if m.isfile():expected['files'][m.name]=hashlib.sha256(t.extractfile(m).read()).hexdigest()
expected['source_commit']=rev
run('cp --reflink=auto '+r+'/'+n+'/prepared.image '+r+'/'+n+'/prepared-c6948.image')
run('tar -xf - -C '+r,input=archive)
put(r+'/'+h+'/source-expected.json',json.dumps(expected,indent=2)+'\n');put(r+'/.allocator-source-commit',rev+'\n')
put('/home/erg/run-corrected-native-a7.py',(repo/n/'run-corrected-native.py').read_bytes())
run('cd '+r+' && python3 '+h+'/source-manifest.py && python3 '+n+'/prepare.py --image '+n+'/prepared-c6948.image --label corrected-a7-prepare --script '+n+'/prepare-corrected.factor')
launch='''import os,subprocess
assert os.getpriority(os.PRIO_PROCESS,0)==0
f=open('/home/erg/compiler-next-corrected-native-a7.log','w')
p=subprocess.Popen(['python3','/home/erg/run-corrected-native-a7.py','--candidate','''+repr(r)+''','--source','''+repr(rev)+''','--reuse-baseline-capture'],stdout=f,stderr=subprocess.STDOUT,start_new_session=True)
print(p.pid)
'''
run('python3 -',input=launch.encode())
print('A7 QUEUE STARTED',flush=True)
