import subprocess,pathlib,json
R=pathlib.Path('/Users/erg/factor.worktrees/compiler-next-integration');B=pathlib.Path('/Users/erg/factor.worktrees/compiler-next-comparison');REL=pathlib.Path('reference/allocator-speed-crossarch-20260908');FINAL=pathlib.Path('reference/compiler-next-final-20260909');OLD=pathlib.Path('reference/compiler-next-20260909')
def run(cmd,cwd=R):
 print('RUN',*map(str,cmd),flush=True);subprocess.run(list(map(str,cmd)),cwd=cwd,check=True)
for a,remat in [('greedy','on'),('backtracking','on'),('chordal','on')]:
 run(['python3',R/'reference/allocator-speed-20260908/run-command.py','--cwd',R,'--output','/tmp/compiler-next-final-compiler-'+a,'--timeout','300','--',R/'factor','-i='+str(R/'compiler-next-default.factor.image'),'-no-user-init','-resource-path='+str(R),R/'reference/allocator-full-master-integration-20260908/compiler-suite.factor',a,remat,'on'])
run(['python3',R/FINAL/'prepare.py','--image',R/OLD/'prepared.image','--label','final-prepare'],R)
run(['python3',R/REL/'source-manifest.py'])
def drive(root,label,a,mode='timing',ordinal=0):
 image=root/(FINAL if root==R else OLD)/'prepared.image'
 run(['python3',root/'reference/allocator-tuning-20260909/drive.py',label,'--allocator',a,'--mode',mode,'--round-offset',str(ordinal),'--samples','3','--rematerialize','on','--loop-spills','on','--image',image],root)
for a in ['backtracking','chordal']:drive(R,'final',a,'check')
for root,label,i in [(B,'final-baseline',0),(R,'final-candidate',0),(R,'final-candidate',1),(B,'final-baseline',1)]:drive(root,label,'backtracking',ordinal=i)
run(['python3',R/'reference/allocator-tuning-20260909/gates.py','--image',R/FINAL/'prepared.image'])
run(['python3',R/'reference/allocator-speed-20260908/run-command.py','--cwd',R,'--output','/tmp/compiler-next-final-bootstrap','--timeout','300','--','/usr/sbin/taskpolicy','-a','-t','0','-l','0',R/'factor','-i='+str(R/'boot.unix-arm.64.image'),'-no-user-init','-resource-path='+str(R),'-output-image='+str(R/'compiler-next-final.factor.image')])
run(['python3',R/'reference/allocator-speed-20260908/run-command.py','--cwd',R,'--output','/tmp/compiler-next-final-image-check','--timeout','120','--',R/'factor','-i='+str(R/'compiler-next-final.factor.image'),'-no-user-init','-resource-path='+str(R),R/'reference/allocator-speed-20260908/verify-image.factor'])
run(['python3',R/REL/'source-manifest.py'])
print('FINAL ARM COMPLETE',flush=True)
