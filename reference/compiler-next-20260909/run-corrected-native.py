#!/usr/bin/env python3
"""Exclusive corrected-source native sequence; staging is performed separately."""
import argparse, hashlib, json, os, subprocess, time
from pathlib import Path

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--candidate',type=Path,required=True)
p.add_argument('--source',required=True)
p.add_argument('--phase',choices=['sequence','capture-baseline','capture-callees'],default='sequence')
p.add_argument('--reuse-baseline-capture',action='store_true')
a=p.parse_args()
BASE=Path('/home/erg/factor-compiler-next-greedy-baseline-20260909')
PREFIX=Path('/home/erg/factor-compiler-next-combined-20260909')
REL=Path('reference/allocator-speed-crossarch-20260908')
NEXT=Path('reference/compiler-next-20260909')
assert os.getpriority(os.PRIO_PROCESS,0)==0
assert (a.candidate/'.allocator-source-commit').read_text().strip()==a.source
assert (a.candidate/'.allocator-prepared-source-commit').read_text().strip()==a.source

def run(command,root):
    print('RUN',*map(str,command),flush=True)
    subprocess.run(list(map(str,command)),cwd=root,check=True)

def unit_gate(root):
    entry=root/NEXT/'corrected-unit.factor'
    cmd=['taskset','-c','2',str(root/'factor'),'-resource-path='+str(root),
         '-i='+str(root/NEXT/'prepared.image'),'-no-user-init',str(entry),
         'backtracking','on','on']
    out=root/NEXT; start=time.monotonic()
    with (out/'corrected-unit.log').open('w') as f:
        child=subprocess.run(cmd,cwd=root,stdout=f,stderr=subprocess.STDOUT)
    ok=child.returncode==0 and 'SPEED compiler-suite=passed' in (out/'corrected-unit.log').read_text()
    (out/'corrected-unit.status.json').write_text(json.dumps(dict(ok=ok,exit_code=child.returncode,
        command=cmd,source_commit=a.source,seconds=time.monotonic()-start,
        script_sha256=hashlib.sha256(entry.read_bytes()).hexdigest()),indent=2)+'\n')
    print('UNIT',ok,flush=True)
    assert ok,'corrected BT unit gate'

def captured_check(root,label,include_callees=False):
    source=(root/'.allocator-source-commit').read_text().strip()
    assert (root/'.allocator-prepared-source-commit').read_text().strip()==source
    entry=root/NEXT/('capture-callees-checked.factor' if include_callees else 'capture-checked.factor')
    cmd=['taskset','-c','2',str(root/'factor'),'-resource-path='+str(root),
         '-i='+str(root/NEXT/'prepared.image'),'-no-user-init',str(entry),
         'backtracking','check','3','on','on',source]
    before=os.getloadavg();start=time.monotonic();out=root/NEXT
    print('START',label,flush=True)
    with (out/(label+'.log')).open('w') as f:
        child=subprocess.run(cmd,cwd=root,stdout=f,stderr=subprocess.STDOUT)
    data=(out/(label+'.log')).read_text()
    records=[json.loads(s) for s in data.splitlines() if s.startswith('{')]
    kinds=[r['kind'] for r in records]
    captured={r['word'] for r in records if r['kind']=='generated-code'}
    expected={'allocator-runtime-comparison:base32-work','allocator-runtime-comparison:integer-pressure-work'}
    if include_callees: expected.add('allocator-runtime-comparison:integer-pressure')
    ok=(child.returncode==0 and kinds.count('scope')==1 and kinds.count('compile')==1
        and kinds.count('code')==12 and kinds.count('runtime')==26
        and captured==expected and 'CODE-CAPTURE-COMPLETE' in data)
    (out/(label+'.jsonl')).write_text(''.join(json.dumps(x)+'\n' for x in records))
    status=dict(ok=ok,exit_code=child.returncode,source_commit=source,command=cmd,
        diagnostic_only=True,final_value_verifier=True,seconds=time.monotonic()-start,
        host_load_before=before,host_load_after=os.getloadavg(),
        counts={k:kinds.count(k) for k in set(kinds)},
        script_sha256={n:hashlib.sha256((root/NEXT/n).read_bytes()).hexdigest()
                       for n in [entry.name,'capture-workload-code.factor']})
    (out/(label+'.status.json')).write_text(json.dumps(status,indent=2)+'\n')
    print('DONE',label,ok,status['seconds'],flush=True)
    assert ok,label

def drive(root,label,allocator,mode,ordinal=0):
    run(['python3',root/'reference/allocator-tuning-20260909/drive.py',label,
         '--allocator',allocator,'--mode',mode,'--round-offset',str(ordinal),
         '--samples','3','--rematerialize','on','--loop-spills','on',
         '--image',root/NEXT/'prepared.image'],root)

def compile_only(root,label):
    source=(root/'.allocator-source-commit').read_text().strip()
    assert (root/'.allocator-prepared-source-commit').read_text().strip()==source
    text=(root/REL/'timing.factor').read_text().replace('USING: alien.syntax','USING: system alien.syntax')
    needle='    metric-workloads [ measure-compilation'
    assert text.count(needle)==1
    entry=root/NEXT/'corrected-compile-only.factor'
    entry.write_text(text[:text.index(needle)]+'    0 exit ;\nmain\n')
    cmd=['taskset','-c','2',str(root/'factor'),'-resource-path='+str(root),
         '-i='+str(root/NEXT/'prepared.image'),'-no-user-init',str(entry),
         'chordal','timing','0','on','on',source]
    before=os.getloadavg();start=time.monotonic();out=root/NEXT
    print('START',label,flush=True)
    with (out/(label+'.log')).open('w') as f:
        child=subprocess.run(cmd,cwd=root,stdout=f,stderr=subprocess.STDOUT)
    rows=[json.loads(s) for s in (out/(label+'.log')).read_text().splitlines() if s.startswith('{')]
    ok=child.returncode==0 and [r['kind'] for r in rows]==['scope','compile']
    (out/(label+'.jsonl')).write_text(''.join(json.dumps(x)+'\n' for x in rows))
    (out/(label+'.status.json')).write_text(json.dumps(dict(ok=ok,exit_code=child.returncode,
        source_commit=source,command=cmd,seconds=time.monotonic()-start,
        host_load_before=before,host_load_after=os.getloadavg(),
        script_sha256=hashlib.sha256(entry.read_bytes()).hexdigest()),indent=2)+'\n')
    assert ok,label
    print('COMPILE',label,rows[-1],flush=True)

if a.phase=='capture-baseline':
    captured_check(BASE,'corrected-baseline-captured-check')
    raise SystemExit(0)
if a.phase=='capture-callees':
    captured_check(BASE,'corrected-baseline-callee-check',True)
    captured_check(a.candidate,'corrected-candidate-callee-check',True)
    raise SystemExit(0)
for root in [BASE,a.candidate,PREFIX]:run(['python3',root/REL/'source-manifest.py'],root)
unit_gate(a.candidate)
if a.reuse_baseline_capture:
    previous=json.loads((BASE/NEXT/'corrected-baseline-captured-check.status.json').read_text())
    assert previous['ok'] and previous['exit_code']==0
    assert previous['source_commit']==(BASE/'.allocator-source-commit').read_text().strip()
    assert previous['counts']['generated-code']==2
    assert all(previous['script_sha256'][n]==hashlib.sha256((BASE/NEXT/n).read_bytes()).hexdigest()
               for n in ['capture-checked.factor','capture-workload-code.factor'])
    print('REUSE verified original-baseline captured check',flush=True)
else:
    captured_check(BASE,'corrected-baseline-captured-check')
captured_check(a.candidate,'corrected-candidate-captured-check')
run(['python3',a.candidate/'reference/allocator-tuning-20260909/gates.py',
     '--image',a.candidate/NEXT/'prepared.image'],a.candidate)
drive(a.candidate,'corrected','chordal','check')
for variant,i in [('baseline',1),('candidate',1),('candidate',2),('baseline',2)]:
    drive(BASE if variant=='baseline' else a.candidate,'corrected-'+variant,
          'backtracking','timing',i-1)
for root,label in [(PREFIX,'corrected-chordal-prefix-1'),(a.candidate,'corrected-chordal-final-1'),(PREFIX,'corrected-chordal-prefix-2')]:
    compile_only(root,label)
for root in [BASE,a.candidate,PREFIX]:run(['python3',root/REL/'source-manifest.py'],root)
print('CORRECTED NATIVE COMPLETE',flush=True)
