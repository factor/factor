#!/usr/bin/env python3
"""Four fresh native processes; installed-code captures bracket each batch."""
import hashlib,json,os,subprocess,time
from pathlib import Path
BASE=Path('/home/erg/factor-compiler-next-greedy-baseline-20260909')
CAND=Path('/home/erg/factor-compiler-next-final-c6948-20260909')
OUT=Path('/home/erg/compiler-next2-integer-20260909');OUT.mkdir(exist_ok=True)
PROBE=OUT/'integer-same-process.factor'
IMAGE=Path('reference/compiler-next-20260909/prepared.image')
assert os.getpriority(os.PRIO_PROCESS,0)==0
for root in [BASE,CAND]:
 subprocess.run(['python3',str(root/'reference/allocator-speed-crossarch-20260908/source-manifest.py')],cwd=root,check=True)
assert hashlib.sha256((BASE/'factor').read_bytes()).hexdigest()==hashlib.sha256((CAND/'factor').read_bytes()).hexdigest()
for variant,ordinal in [('baseline',1),('candidate',1),('candidate',2),('baseline',2)]:
 root=BASE if variant=='baseline' else CAND;source=(root/'.allocator-source-commit').read_text().strip()
 assert source==(root/'.allocator-prepared-source-commit').read_text().strip()
 label=variant+'-'+str(ordinal);command=['taskset','-c','2',str(root/'factor'),'-resource-path='+str(root),'-i='+str(root/IMAGE),'-no-user-init',str(PROBE),'backtracking','timing','3','on','on',source]
 st=dict(label=label,command=command,source=source,logical_source='c1f7e4d34cd604bbdf22576b237406b39758896d' if variant=='baseline' else '1d67bdd034110a385286179974f3bcaef77b35ba',probe_sha256=hashlib.sha256(PROBE.read_bytes()).hexdigest(),vm_sha256=hashlib.sha256((root/'factor').read_bytes()).hexdigest(),prepared_image_sha256=hashlib.sha256((root/IMAGE).read_bytes()).hexdigest(),load_before=os.getloadavg(),nice=os.getpriority(os.PRIO_PROCESS,0),capability=subprocess.check_output(['getcap',str((root/'factor').resolve())],text=True))
 assert 'cap_perfmon=ep' in st['capability']
 print('START',label,flush=True);start=time.monotonic()
 with (OUT/(label+'.log')).open('w') as f:r=subprocess.run(command,cwd=root,stdout=f,stderr=subprocess.STDOUT)
 rr=[json.loads(x) for x in (OUT/(label+'.log')).read_text().splitlines() if x.startswith('{')]
 st.update(exit_code=r.returncode,seconds=time.monotonic()-start,load_after=os.getloadavg(),counts={k:sum(x.get('kind')==k for x in rr) for k in set(x.get('kind') for x in rr)})
 ss=[x for x in rr if x.get('kind')=='scope'];runtime=[x for x in rr if x.get('kind')=='runtime'];captures=[x for x in rr if x.get('kind')=='installed-code']
 st['ok']=r.returncode==0 and len(ss)==1 and len(runtime)==4 and len(captures)==32 and ss[0]['checked'] is False and ss[0]['options']=={'rematerialize_constants':True,'backtracking_loop_spills':True,'gvn':False} and all(x['output']=='' for x in runtime)
 (OUT/(label+'.jsonl')).write_text(''.join(json.dumps(x)+'\n' for x in rr));(OUT/(label+'.status.json')).write_text(json.dumps(st,indent=2)+'\n')
 print('DONE',label,st['ok'],st['seconds'],flush=True)
 assert st['ok'],st
print('INTEGER PAIRS COMPLETE',flush=True)
