import subprocess,time,sys
from pathlib import Path
root=Path('/Users/erg/factor.worktrees/compiler-next3-vectorization')
code='USING: vocabs.refresh ; << refresh-all >> USING: vocabs.loader ; "compiler.cfg.slp" require USE: tools.test "compiler.cfg.slp" test :test-failures test-failures get empty? [ 0 ] [ 1 ] if exit'

log='/tmp/compiler-next3-vectorization-check.log'
with open(log,'w') as f:
 p=subprocess.Popen(['./factor',f'-i={root}/factor.image',f'-resource-path={root}','-no-user-init','-e='+code],cwd=root,stdout=f,stderr=subprocess.STDOUT)
 while p.poll() is None:
  subprocess.run(['taskpolicy','-B','-p',str(p.pid)],capture_output=True)
  time.sleep(1)
 print('test exit',p.returncode,'log',log,flush=True)
 sys.exit(p.returncode)
