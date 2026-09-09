import pathlib,subprocess,json,time,os
HOME=pathlib.Path('/home/erg');REL=pathlib.Path('reference/allocator-speed-crossarch-20260908');NEXT=pathlib.Path('reference/compiler-next-20260909')
BASE=HOME/'factor-compiler-next-greedy-baseline-20260909'
assert os.getpriority(os.PRIO_PROCESS,0)==0, 'foreground priority required'
def run(cmd,cwd=None):
 print('RUN',*map(str,cmd),flush=True);subprocess.run(list(map(str,cmd)),cwd=cwd,check=True)
def stage(name):
 r=HOME/('factor-compiler-next-'+name+'-20260909')
 if r.exists():
  if not (r/'factor').is_symlink(): (r/'factor').unlink(); (r/'factor').symlink_to(BASE/'factor')
  run(['python3',r/REL/'source-manifest.py'])
  return r
 run(['cp','-a','--reflink=auto',BASE,r])
 (r/'factor').unlink(); (r/'factor').symlink_to(BASE/'factor')
 run(['tar','-xf',HOME/('compiler-next-'+name+'.tar'),'-C',r])
 run(['python3',r/REL/'source-manifest.py'])
 run(['python3',r/NEXT/'prepare.py','--image',BASE/NEXT/'prepared.image','--label','next-prepare','--script',r/NEXT/'prepare-next.factor'],r)
 return r
def compile_only(root,label,allocator):
 out=root/NEXT; rev=(root/'.allocator-source-commit').read_text().strip()
 assert (root/'.allocator-prepared-source-commit').read_text().strip()==rev
 script=(root/REL/'timing.factor').read_text().replace('USING: alien.syntax','USING: system alien.syntax')
 needle='    metric-workloads [ measure-compilation'
 assert script.count(needle)==1
 script=script[:script.index(needle)]+'    0 exit ;\nmain\n'
 entry=out/'compile-only.factor';entry.write_text(script)
 cmd=['taskset','-c','2',str(root/'factor'),'-resource-path='+str(root),'-i='+str(out/'prepared.image'),'-no-user-init',str(entry),allocator,'timing','0','on','on',rev]
 start=time.monotonic();load=os.getloadavg()
 with (out/(label+'.log')).open('w') as f:p=subprocess.run(cmd,cwd=root,stdout=f,stderr=subprocess.STDOUT)
 rows=[json.loads(x) for x in (out/(label+'.log')).read_text().splitlines() if x.startswith('{')]
 ok=p.returncode==0 and [x['kind'] for x in rows]==['scope','compile']
 (out/(label+'.jsonl')).write_text(''.join(json.dumps(x)+'\n' for x in rows))
 (out/(label+'.status.json')).write_text(json.dumps(dict(ok=ok,exit_code=p.returncode,source_commit=rev,command=cmd,seconds=time.monotonic()-start,load_before=load,load_after=os.getloadavg()),indent=2)+'\n')
 assert ok,label
 print('COMPILE',label,rows[-1],flush=True)
def drive(root,label,allocator,mode='timing',ordinal=0):
 run(['python3',root/'reference/allocator-tuning-20260909/drive.py',label,'--allocator',allocator,'--mode',mode,'--round-offset',str(ordinal),'--samples','3','--rematerialize','on','--loop-spills','on','--image',root/NEXT/'prepared.image'],root)
# Let the already running, exclusive-core greedy pairs complete first.
deadline=time.monotonic()+900
while True:
 p=BASE/REL/'next-baseline-timing-greedy-2.status.json'
 if p.exists(): assert json.loads(p.read_text())['ok'];break
 assert time.monotonic()<deadline
 time.sleep(2)
for name,allocator in [('algebra','linear-scan'),('chordal','chordal'),('backtracking','backtracking')]:
 r=stage(name)
 drive(r,'isolated3-'+name,allocator,'check')
 for v,i in [('baseline',1),('candidate',1),('candidate',2),('baseline',2)]:
  target=BASE if v=='baseline' else r
  if name=='backtracking':drive(target,'isolated-'+name+'-'+v,allocator,ordinal=i-1)
  else:compile_only(target,'isolated-'+name+'-'+v+'-'+str(i),allocator)
 run(['python3',r/REL/'source-manifest.py'])
r=stage('combined')
for allocator in ['linear-scan','greedy','backtracking','chordal']:drive(r,'combined',allocator,'check')
for ordinal in range(2):
 for allocator in ['linear-scan','greedy','backtracking','chordal'][::1 if ordinal==0 else -1]:drive(r,'combined',allocator,ordinal=ordinal)
run(['python3',r/'reference/allocator-tuning-20260909/gates.py','--image',r/NEXT/'prepared.image'])
run(['python3',r/REL/'source-manifest.py'])
print('NATIVE COMPLETE',flush=True)
