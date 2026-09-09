import subprocess,time,sys
from pathlib import Path
root=Path('/Users/erg/factor.worktrees/compiler-next3-vectorization')

log='/tmp/compiler-next3-vectorization-native-check.log'
with open(log,'w') as f:
 p=subprocess.Popen(['./factor',f'-i={root}/factor.image',f'-resource-path={root}','-no-user-init','reference/compiler-next3-vectorization-20260909/native-check.factor'],cwd=root,stdout=f,stderr=subprocess.STDOUT)
 while p.poll() is None:
  subprocess.run(['taskpolicy','-B','-p',str(p.pid)],capture_output=True)
  time.sleep(1)
 print('test exit',p.returncode,'log',log,flush=True)
 sys.exit(p.returncode)
