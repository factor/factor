#!/usr/bin/env python3
import hashlib,json,os,subprocess,time
from pathlib import Path
BASE=Path('/home/erg/factor-compiler-next-final-c6948-20260909');CAND=Path('/home/erg/factor-compiler-next2-residency-20260909')
OUT=Path('/home/erg/compiler-next2-residency-20260909');OUT.mkdir(exist_ok=True)
REL=Path('reference/allocator-speed-crossarch-20260908');NEXT=Path('reference/compiler-next-20260909');IMAGE=NEXT/'prepared.image'
assert os.getpriority(os.PRIO_PROCESS,0)==0
assert hashlib.sha256((BASE/'factor').read_bytes()).hexdigest()==hashlib.sha256((CAND/'factor').read_bytes()).hexdigest()
def execute(root,label,entry,args,expected):
 source=(root/'.allocator-source-commit').read_text().strip();assert source==(root/'.allocator-prepared-source-commit').read_text().strip()
 command=['taskset','-c','2',str(root/'factor'),'-resource-path='+str(root),'-i='+str(root/IMAGE),'-no-user-init',str(entry),*args]
 st={'source':source,'command':command,'script_sha256':hashlib.sha256(entry.read_bytes()).hexdigest(),'prepared_image_sha256':hashlib.sha256((root/IMAGE).read_bytes()).hexdigest(),'vm_sha256':hashlib.sha256((root/'factor').read_bytes()).hexdigest(),'load_before':os.getloadavg(),'nice':os.getpriority(os.PRIO_PROCESS,0),'capability':subprocess.check_output(['getcap',str((root/'factor').resolve())],text=True)}
 assert 'cap_perfmon=ep' in st['capability'];start=time.monotonic();print('START',label,flush=True)
 with (OUT/(label+'.log')).open('w') as f:r=subprocess.run(command,cwd=root,stdout=f,stderr=subprocess.STDOUT)
 rr=[json.loads(x) for x in (OUT/(label+'.log')).read_text().splitlines() if x.startswith('{')]
 ok=r.returncode==0 and expected(rr);st.update(ok=ok,exit_code=r.returncode,seconds=time.monotonic()-start,load_after=os.getloadavg());(OUT/(label+'.status.json')).write_text(json.dumps(st,indent=2)+'\n');(OUT/(label+'.jsonl')).write_text(''.join(json.dumps(x)+'\n' for x in rr));print('DONE',label,ok,st['seconds'],flush=True);assert ok,label
execute(CAND,'focused-unit',CAND/NEXT/'residency-unit.factor',[],lambda r:True)
subprocess.run(['python3',str(CAND/'reference/allocator-tuning-20260909/drive.py'),'residency','--allocator','chordal','--mode','check','--samples','3','--rematerialize','on','--loop-spills','on','--image',str(CAND/IMAGE)],cwd=CAND,check=True)
b=[json.loads(x) for x in (BASE/REL/'corrected-check-chordal-1.jsonl').read_text().splitlines()];c=[json.loads(x) for x in (CAND/REL/'residency-check-chordal-1.jsonl').read_text().splitlines()]
def strip(x):
 if isinstance(x,dict):return {k:strip(v) for k,v in x.items() if 'nanoseconds' not in k}
 if isinstance(x,list):return list(map(strip,x))
 return x
scopes=[next(x for x in rr if x['kind']=='scope') for rr in [b,c]];assert scopes[0]['words']==scopes[1]['words'] and len(scopes[0]['words'])==28500
bc=[[strip(x) for x in rr if x['kind']=='code'] for rr in [b,c]];equiv=bc[0]==bc[1]
result={'scope_objects':28500,'scope_identical':True,'static_reports_identical':equiv,'baseline':bc[0],'candidate':bc[1],'baseline_checked_record_reused':str(BASE/REL/'corrected-check-chordal-1.jsonl')};(OUT/'static-equivalence.json').write_text(json.dumps(result,indent=2)+'\n');assert equiv,'12 static reports changed'
assert [(x['word'],x['output']) for x in b if x['kind']=='runtime']==[(x['word'],x['output']) for x in c if x['kind']=='runtime']
for root in [BASE,CAND]:
 s=(root/REL/'timing.factor').read_text().replace('USING: alien.syntax','USING: system alien.syntax');needle='    metric-workloads [ measure-compilation';assert s.count(needle)==1
 (root/NEXT/'residency-compile-only.factor').write_text(s[:s.index(needle)]+'    0 exit ;\nmain\n')
for variant,i in [('baseline',1),('candidate',1),('candidate',2),('baseline',2)]:
 root=BASE if variant=='baseline' else CAND;source=(root/'.allocator-source-commit').read_text().strip();execute(root,variant+'-'+str(i),root/NEXT/'residency-compile-only.factor',['chordal','timing','0','on','on',source],lambda r:[x['kind'] for x in r]==['scope','compile'] and next(x for x in r if x['kind']=='scope')['words']==scopes[0]['words'])
print('RESIDENCY PAIRS COMPLETE',flush=True)
