import pathlib,subprocess
R=pathlib.Path('/Users/erg/factor.worktrees/compiler-next2-integration')
for allocator,remat in [('linear-scan','off'),('greedy','on'),('backtracking','on'),('chordal','on')]:
 cmd=['python3',str(R/'reference/allocator-speed-20260908/run-command.py'),'--cwd',str(R),'--output','/tmp/compiler-next2-compiler-'+allocator,'--timeout','360','--',str(R/'factor'),'-i='+str(R/'factor.image'),'-no-user-init','-resource-path='+str(R),str(R/'reference/allocator-full-master-integration-20260908/compiler-suite.factor'),allocator,remat,'on']
 print('RUN',allocator,flush=True);subprocess.run(cmd,cwd=R,check=True)
print('ALL NEXT2 ARM COMPILER GATES PASSED',flush=True)
