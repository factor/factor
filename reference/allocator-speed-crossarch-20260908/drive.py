#!/usr/bin/env python3
"""Sequential fresh-process runs with retained status, fixed batches and CPU affinity."""
import argparse, hashlib, json, os, platform, subprocess, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
OUT=Path(__file__).resolve().parent
ALLOCATORS=['linear-scan','greedy','backtracking','chordal']
p=argparse.ArgumentParser()
p.add_argument('label')
p.add_argument('--mode',choices=['check','timing'],default='timing')
p.add_argument('--rounds',type=int,default=1)
p.add_argument('--round-offset',type=int,default=0)
p.add_argument('--samples',type=int,default=3)
p.add_argument('--allocator',choices=ALLOCATORS)
p.add_argument('--rematerialize',choices=['on','off'],default='off')
p.add_argument('--loop-spills',choices=['on','off'],default='off')
p.add_argument('--image',default=str(OUT/'prepared.image'))
p.add_argument('--cpu',default='2')
a=p.parse_args()
for r in range(1 if a.mode=='check' else a.rounds):
    ordinal=r+a.round_offset
    order=ALLOCATORS[ordinal%4:]+ALLOCATORS[:ordinal%4]
    if a.allocator: order=[a.allocator]
    for allocator in order:
        name=f'{a.label}-{a.mode}-{allocator}-{ordinal+1}'
        log=OUT/(name+'.log')
        entry=OUT/'timing.factor'
        final_verifier=False
        if a.mode=='check' and (ROOT/'basis/compiler/cfg/register-allocation/verifier/verifier.factor').exists():
            final_verifier=True
            setup='USING: parser vocabs.loader ;\n<< "compiler.cfg.register-allocation.verifier" require'
            if (ROOT/'basis/compiler/cfg/register-allocation/verifier/rematerialization/rematerialization.factor').exists():
                setup+=' "compiler.cfg.register-allocation.verifier.rematerialization" require'
            setup+=' >>\n"reference/allocator-speed-crossarch-20260908/timing.factor" run-file\n'
            entry=OUT/'checked-launch.factor'
            entry.write_text(setup)
        cmd=[str(ROOT/'factor'),'-resource-path='+str(ROOT),'-i='+str(Path(a.image).resolve()),'-no-user-init',str(entry),allocator,a.mode,str(a.samples),a.rematerialize,a.loop_spills]
        if platform.system()=='Linux':cmd=['taskset','-c',a.cpu]+cmd
        print('START',name,flush=True)
        start=time.time()
        load_before=os.getloadavg()
        policy=None
        with log.open('w') as f:
            child=subprocess.Popen(cmd,cwd=ROOT,stdout=f,stderr=subprocess.STDOUT)
            if platform.system()=='Darwin':
                time.sleep(1)
                policy=subprocess.run(['taskpolicy','-B','-p',str(child.pid)],capture_output=True,text=True)
            code=child.wait()
        records=[]
        for line in log.read_text(errors='replace').splitlines():
            if line.startswith('{'):
                try: records.append(json.loads(line))
                except json.JSONDecodeError: pass
        (OUT/(name+'.jsonl')).write_text(''.join(json.dumps(x)+'\n' for x in records))
        kinds=[x['kind'] for x in records]
        expected=26*(1 if a.mode=='check' else a.samples+1)
        ok=code==0 and kinds.count('scope')==1 and kinds.count('compile')==1 and kinds.count('code')==12 and kinds.count('runtime')==expected
        status=dict(host_load_before=load_before,host_load_after=os.getloadavg(),final_value_verifier=final_verifier,exit_code=code,seconds=time.time()-start,command=cmd,ok=ok,counts={x:kinds.count(x) for x in set(kinds)})
        if policy:status['taskpolicy']=dict(exit_code=policy.returncode,stderr=policy.stderr)
        (OUT/(name+'.status.json')).write_text(json.dumps(status,indent=2)+'\n')
        print('DONE',name,'exit',code,'records',len(records),'seconds',round(time.time()-start,1),'OK',ok,flush=True)
        if not ok:raise SystemExit('Failed: '+str(log))
