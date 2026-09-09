import pathlib,subprocess,json,hashlib
R=pathlib.Path('/Users/erg/factor.worktrees/compiler-next2-integration');B=pathlib.Path('/Users/erg/factor.worktrees/compiler-next2-baseline');REL=pathlib.Path('reference/compiler-next2-20260909')
def run(cmd,cwd=R):
 print('RUN',*map(str,cmd),flush=True);subprocess.run(list(map(str,cmd)),cwd=cwd,check=True)
run(['python3',R/REL/'prepare.py','--image',B/REL/'prepared.image','--label','combined-prepare'])
run(['python3',R/'reference/allocator-speed-crossarch-20260908/source-manifest.py'])
for a,remat in [('linear-scan','off'),('chordal','on')]:
 run(['python3',R/'reference/allocator-tuning-20260909/drive.py','next2','--allocator',a,'--mode','check','--samples','0','--rematerialize',remat,'--loop-spills','on','--image',R/REL/'prepared.image'])
for root,label in [(B,'default-baseline-1'),(R,'default-candidate-1'),(R,'default-candidate-2'),(B,'default-baseline-2')]:
 run(['python3',R/REL/'run-compile.py','--root',root,'--label',label,'--allocator','linear-scan'])
run(['python3',R/'reference/allocator-tuning-20260909/gates.py','--image',R/REL/'prepared.image'])
run(['python3',R/'reference/allocator-speed-20260908/run-command.py','--cwd',R,'--output','/tmp/compiler-next2-bootstrap','--timeout','360','--','/usr/sbin/taskpolicy','-a','-t','0','-l','0',R/'factor','-i='+str(R/'boot.unix-arm.64.image'),'-no-user-init','-resource-path='+str(R),'-output-image='+str(R/'compiler-next2-default.factor.image')])
run(['python3',R/'reference/allocator-speed-20260908/run-command.py','--cwd',R,'--output','/tmp/compiler-next2-image-check','--timeout','120','--',R/'factor','-i='+str(R/'compiler-next2-default.factor.image'),'-no-user-init','-resource-path='+str(R),R/'reference/allocator-speed-20260908/verify-image.factor'])
run(['python3',R/'reference/allocator-speed-crossarch-20260908/source-manifest.py'])
print('NEXT2 ARM DEFAULT MEASUREMENTS COMPLETE',flush=True)
