import subprocess,pathlib,json,time
R=pathlib.Path('/Users/erg/factor.worktrees/compiler-next-integration');B=pathlib.Path('/Users/erg/factor.worktrees/compiler-next-comparison');S=pathlib.Path('/Users/erg/factor.worktrees/allocator-tuning-final-candidate');REL=pathlib.Path('reference/allocator-speed-crossarch-20260908');NEXT=pathlib.Path('reference/compiler-next-20260909')
def run(cmd,cwd=R):
 print('RUN',*map(str,cmd),flush=True);subprocess.run(list(map(str,cmd)),cwd=cwd,check=True)
for allocator in ['linear-scan','greedy','backtracking','chordal']:
 p=pathlib.Path('/tmp/compiler-next-combined-'+allocator+'/status.json')
 while not p.exists():time.sleep(2)
 assert json.loads(p.read_text())['exit_code']==0
run(['python3',R/'reference/allocator-speed-20260908/run-command.py','--cwd',R,'--output','/tmp/compiler-next-default-bootstrap','--timeout','300','--','/usr/sbin/taskpolicy','-a','-t','0','-l','0',R/'factor','-i='+str(R/'boot.unix-arm.64.image'),'-no-user-init','-resource-path='+str(R),'-output-image='+str(R/'compiler-next-default.factor.image')])
run(['python3',R/'reference/allocator-speed-20260908/run-command.py','--cwd',R,'--output','/tmp/compiler-next-default-image-check','--timeout','120','--',R/'factor','-i='+str(R/'compiler-next-default.factor.image'),'-no-user-init','-resource-path='+str(R),R/'reference/allocator-speed-20260908/verify-image.factor'])
for root in [B,R]:
 run(['python3',root/NEXT/'prepare.py','--image',S/REL/'prepared.image','--label','arm-next-prepare','--script',root/NEXT/'prepare-next.factor'],root)
 run(['python3',root/REL/'source-manifest.py'],root)
def drive(root,label,allocator,mode='timing',ordinal=0):
 run(['python3',root/'reference/allocator-tuning-20260909/drive.py',label,'--allocator',allocator,'--mode',mode,'--round-offset',str(ordinal),'--samples','3','--rematerialize','on','--loop-spills','on','--image',root/NEXT/'prepared.image'],root)
for allocator in ['linear-scan','greedy','backtracking','chordal']:drive(R,'combined',allocator,'check')
for allocator in ['linear-scan','backtracking']:
 for root,label,ordinal in [(B,'arm-next-baseline',0),(R,'arm-next-candidate',0),(R,'arm-next-candidate',1),(B,'arm-next-baseline',1)]:drive(root,label,allocator,ordinal=ordinal)
run(['python3',R/'reference/allocator-tuning-20260909/gates.py','--image',R/NEXT/'prepared.image'])
print('ARM COMPLETE',flush=True)
