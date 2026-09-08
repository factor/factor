import subprocess,time,json
from pathlib import Path
root=Path.cwd();out=root/'work/interference-perf'
for allocator in ['backtracking']:
 for variant in ['baseline','candidate']:
  name=f'{allocator}-{variant}-round2'
  with (out/(name+'.log')).open('w') as log:
   child=subprocess.Popen([str(root/'factor'),'-i='+'/Users/erg/factor.worktrees/allocator-benchmarks/reference/allocator-benchmarks-20260908/prepared.image','-resource-path='+str(root),'-no-user-init',str(out/'run.factor'),allocator,variant],stdout=log,stderr=subprocess.STDOUT)
   while child.poll() is None:
    subprocess.run(['taskpolicy','-B','-p',str(child.pid)],capture_output=True)
    time.sleep(1)
  print(name,child.returncode,flush=True)
  if child.returncode: raise SystemExit(1)
