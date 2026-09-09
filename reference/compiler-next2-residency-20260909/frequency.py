import subprocess,time,sys
from pathlib import Path
root=Path('/Users/erg/factor.worktrees/compiler-next2-residency')

log='/tmp/compiler-next2-residency-frequency.log'
with open(log,'w') as f:
 p=subprocess.Popen(['./factor',f'-i={root}/factor.image',f'-resource-path={root}','-no-user-init','reference/compiler-next2-residency-20260909/frequency.factor'],cwd=root,stdout=f,stderr=subprocess.STDOUT)
 while p.poll() is None:
  subprocess.run(['taskpolicy','-B','-p',str(p.pid)],capture_output=True)
  time.sleep(1)
 print('test exit',p.returncode,'log',log,flush=True)
 sys.exit(p.returncode)
