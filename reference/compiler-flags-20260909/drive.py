#!/usr/bin/env python3
"""Sequential fresh-process runs with retained status, fixed batches and CPU affinity."""
import argparse, hashlib, json, os, platform, subprocess, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'reference/compiler-flags-20260909'
ALLOCATORS=['linear-scan','greedy','backtracking','chordal']
p=argparse.ArgumentParser()
p.add_argument('label')
p.add_argument('--mode',choices=['check','timing'],default='timing')
p.add_argument('--rounds',type=int,default=1)
p.add_argument('--round-offset',type=int,default=0)
p.add_argument('--samples',type=int,default=3)
p.add_argument('--allocator',choices=ALLOCATORS)
p.add_argument('--rematerialize',choices=['on','off'],default='off')
p.add_argument('--gvn',choices=['on','off'],default='off')
p.add_argument('--loop-spills',choices=['on','off'],default='off')
p.add_argument('--image',default=str(OUT/'prepared.image'))
p.add_argument('--cpu',default='2')
a=p.parse_args()
if platform.system()=='Linux' and a.mode=='timing': assert a.cpu=='2'
for r in range(1 if a.mode=='check' else a.rounds):
    ordinal=r+a.round_offset
    order=ALLOCATORS[ordinal%4:]+ALLOCATORS[:ordinal%4]
    if a.allocator: order=[a.allocator]
    for allocator in order:
        name=f'{a.label}-{a.mode}-{allocator}-{ordinal+1}'
        log=OUT/(name+'.log')
        marker=ROOT/'.allocator-source-commit'
        revision=marker.read_text().strip() if marker.exists() else subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
        prepared_marker=ROOT/'.allocator-prepared-source-commit'
        if prepared_marker.exists():assert prepared_marker.read_text().strip()==revision, 'Prepared image/source mismatch; refresh the image before measuring'
        entry=OUT/'timing.factor'
        final_verifier=False
        if a.mode=='check' and (ROOT/'basis/compiler/cfg/register-allocation/verifier/verifier.factor').exists():
            final_verifier=True
            setup='USING: parser vocabs.loader ;\n<< "compiler.cfg.register-allocation.verifier" require'
            if (ROOT/'basis/compiler/cfg/register-allocation/verifier/rematerialization/rematerialization.factor').exists():
                setup+=' "compiler.cfg.register-allocation.verifier.rematerialization" require'
            setup+=' >>\n"reference/compiler-flags-20260909/timing.factor" run-file\n'
            entry=OUT/'checked-launch.factor'
            entry.write_text(setup)
        cmd=[str(ROOT/'factor'),'-resource-path='+str(ROOT),'-i='+str(Path(a.image).resolve()),'-no-user-init',str(entry),allocator,a.mode,str(a.samples),a.rematerialize,a.loop_spills,revision,a.gvn]
        if platform.system()=='Linux':cmd=['taskset','-c',a.cpu]+cmd
        print('START',name,flush=True)
        start=time.time()
        load_before=os.getloadavg()
        policy=None
        with log.open('w') as f:
            child=subprocess.Popen(cmd,cwd=ROOT,stdout=f,stderr=subprocess.STDOUT)
            while child.poll() is None:
                time.sleep(1)
                if platform.system()=='Darwin' and child.poll() is None:
                    policy=subprocess.run(['taskpolicy','-B','-p',str(child.pid)],capture_output=True,text=True)
                    # The child can exit between poll() and taskpolicy's syscall.
                    if policy.returncode != 0 and child.poll() is None:
                        raise RuntimeError(policy.stderr)
            code=child.returncode
        records=[]
        for line in log.read_text(errors='replace').splitlines():
            if line.startswith('{'):
                try: records.append(json.loads(line))
                except json.JSONDecodeError: pass
        (OUT/(name+'.jsonl')).write_text(''.join(json.dumps(x)+'\n' for x in records))
        kinds=[x['kind'] for x in records]
        expected=26*(1 if a.mode=='check' else a.samples+1)
        ok=code==0 and kinds.count('scope')==1 and kinds.count('compile')==1 and kinds.count('code')==12 and kinds.count('runtime')==expected
        scope=next((x for x in records if x['kind']=='scope'),{})
        ok=ok and scope.get('options')=={'rematerialize_constants':a.rematerialize=='on','backtracking_loop_spills':a.loop_spills=='on','gvn':a.gvn=='on'} and scope.get('checked')==(a.mode=='check')
        status=dict(source_commit=revision,gvn=a.gvn,rematerialize=a.rematerialize,loop_spills=a.loop_spills,image_sha256=hashlib.sha256(Path(a.image).read_bytes()).hexdigest(),vm_sha256=hashlib.sha256((ROOT/'factor').read_bytes()).hexdigest(),script_sha256={entry.name:hashlib.sha256(entry.read_bytes()).hexdigest(),'timing.factor':hashlib.sha256((OUT/'timing.factor').read_bytes()).hexdigest(),'drive.py':hashlib.sha256(Path(__file__).read_bytes()).hexdigest()},host_load_before=load_before,host_load_after=os.getloadavg(),final_value_verifier=final_verifier,exit_code=code,seconds=time.time()-start,command=cmd,ok=ok,counts={x:kinds.count(x) for x in set(kinds)})
        if policy:status['taskpolicy']=dict(exit_code=policy.returncode,stderr=policy.stderr)
        (OUT/(name+'.status.json')).write_text(json.dumps(status,indent=2)+'\n')
        print('DONE',name,'exit',code,'records',len(records),'seconds',round(time.time()-start,1),'OK',ok,flush=True)
        if not ok:raise SystemExit('Failed: '+str(log))
