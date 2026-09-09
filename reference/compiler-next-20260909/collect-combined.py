#!/usr/bin/env python3
"""Strict read-only collection of the completed native same-source matrix."""
from pathlib import Path
import gzip, hashlib, importlib.util, json, math, statistics

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('collector', HERE/'collect-isolated.py')
c = importlib.util.module_from_spec(spec); spec.loader.exec_module(c)
ROOT = '/home/erg/factor-compiler-next-combined-20260909'
OUT = HERE/'independent-native-audit/native-combined'
SOURCE = 'eccfc0accc'
ALLOCATORS = ['linear-scan','greedy','backtracking','chordal']
KEYS = ['cpu_seconds','instructions','ns']
names = ['combined-check-'+a+'-1' for a in ALLOCATORS]
names += ['combined-timing-'+a+'-'+str(i) for i in (1,2) for a in ALLOCATORS]
files = c.fetch(ROOT,c.REL,[n+e for n in names for e in ('.jsonl','.status.json','.log')],OUT/'runs')
metadata = c.fetch(ROOT,c.REL,['source-expected.json','source-manifest.json','timing.factor','workloads.factor','pressure.factor'],OUT/'provenance')
prep = c.fetch(ROOT,c.NXT,['next-prepare.status.json','next-prepare.log','prepare-next.factor'],OUT/'provenance')
gates = c.fetch(ROOT,'reference/allocator-tuning-20260909',
    [n+e for n in ('callback-matrix.factor','moving-gc.factor') for e in ('','.log','.status.json')]+['gates.py','drive.py'],OUT/'gates')
manifest = json.loads(metadata['source-manifest.json'])
source = manifest['source_commit']; assert source.startswith(SOURCE)
assert manifest['all_match'] is True
prepare = json.loads(prep['next-prepare.status.json'])
assert prepare['status']==0 and prepare['source_commit']==source
assert prepare['preparation_script_sha256']==hashlib.sha256(prep['prepare-next.factor']).hexdigest()
for script, marker in [('callback-matrix.factor','CALLBACK-MATRIX-COMPLETE'),('moving-gc.factor','MOVING-GC-MATRIX-COMPLETE')]:
    status = json.loads(gates[script+'.status.json'])
    assert status['ok'] and status['exit_code']==0 and status['source_commit']==source
    assert status['final_value_verifier'] is True and status['rematerialization']==[False,True]
    assert status['gvn'] is False and status['backtracking_loop_spills'] is True
    assert status['script_sha256']==hashlib.sha256(gates[script]).hexdigest()
    assert marker.encode() in gates[script+'.log']

baseline = HERE/'independent-native-audit/native-backtracking/baseline/isolated-backtracking-baseline-timing-backtracking-1.jsonl.gz'
baseline_rows = [json.loads(s) for s in gzip.decompress(baseline.read_bytes()).splitlines()]
oracle = [(r['word'],r['output']) for r in baseline_rows if r['kind']=='runtime'][:26]
scope = None; runs = {}; checks = {}; measured = 0
for name in names:
    status = json.loads(files[name+'.status.json'])
    assert status['source_commit']==source
    rows = c.getrows(files,name)
    assert status['command'][:3]==['taskset','-c','2']
    ss = [r for r in rows if r['kind']=='scope']; assert len(ss)==1
    ss = ss[0]; checked = '-check-' in name
    assert ss['source']==source and ss['checked']==checked
    assert ss['options']=={'rematerialize_constants':True,'backtracking_loop_spills':True,'gvn':False}
    assert ss['allocator'] in ALLOCATORS
    if scope is None: scope=ss['words']
    assert scope==ss['words']
    assert len([r for r in rows if r['kind']=='compile'])==1
    assert len([r for r in rows if r['kind']=='code'])==12
    runtime = [r for r in rows if r['kind']=='runtime']
    assert len(runtime)==(26 if checked else 104)
    for i in range(0,len(runtime),26):
        batch = runtime[i:i+26]
        assert [(r['word'],r['output']) for r in batch]==oracle
        assert all(r['trial']==i//26-1 for r in batch)
        assert all(r[k]>0 for r in batch for k in KEYS)
    if checked:
        assert status['final_value_verifier'] is True
        checks[ss['allocator']]=name
    else:
        runs.setdefault(ss['allocator'],[]).append(rows)
        measured += len([r for r in runtime if r['trial']>=0])
assert len(checks)==4 and all(len(v)==2 for v in runs.values()) and measured==624
word_names = [w.rsplit('|',1)[0] for w in scope]
required = ['classes.algebra:class-and','classes.algebra:class-or',
    'compiler.cfg.register-allocation.greedy:hint-score','compiler.cfg.register-allocation.greedy:allocation-order',
    'compiler.cfg.register-allocation.chordal:preferred-free-color',
    'compiler.cfg.register-allocation.backtracking:edge-entry-reload?',
    'compiler.cfg.register-allocation.backtracking:reify-entry-transports',
    'compiler.cfg.register-allocation.backtracking:backtracking-edge-entry-reloads']
assert all(w in word_names for w in required)
old_scope = next(r for r in baseline_rows if r['kind']=='scope')['words']
old_names = {w.rsplit('|',1)[0] for w in old_scope}
runtime = {a:[[r for r in rr if r['kind']=='runtime' and r['trial']>=0] for rr in runs[a]] for a in ALLOCATORS}
compile = {a:[next(r for r in rr if r['kind']=='compile') for rr in runs[a]] for a in ALLOCATORS}
def mean(xs): return statistics.mean(xs)
def gm(xs): return math.exp(mean(map(math.log,xs)))
rank = {}; cases = {}
for a in ALLOCATORS:
    cases[a] = []
    for i in range(26):
        ratio = {k:mean(rr[j][k] for rr in runtime[a] for j in (i,i+26,i+52))/mean(rr[j][k] for rr in runtime['linear-scan'] for j in (i,i+26,i+52)) for k in KEYS}
        rounds = [{k:mean(rr[j][k] for j in (i,i+26,i+52))/mean(ls[j][k] for j in (i,i+26,i+52)) for k in KEYS} for rr,ls in zip(runtime[a],runtime['linear-scan'])]
        cases[a].append(dict(index=i,word=oracle[i][0],over_linear_scan=ratio,per_round=rounds))
    rank[a]=dict(runtime_over_linear_scan={k:gm(x['over_linear_scan'][k] for x in cases[a]) for k in KEYS},
        per_round_runtime_over_linear_scan=[{k:gm(x['per_round'][i][k] for x in cases[a]) for k in KEYS} for i in (0,1)],
        compiler_over_linear_scan={k:mean(x[k] for x in compile[a])/mean(x[k] for x in compile['linear-scan']) for k in KEYS})
summary = dict(accepted=True,acceptance_scope='Measurement integrity only; BT policy promotion held.',
    candidate_state='Before the backtracking entry-transport profitability correction.',
    source_commit=source,scope_words=len(scope),required_helpers=required,
    added_words=sorted(set(word_names)-old_names),removed_words=sorted(old_names-set(word_names)),
    source_files=len(manifest['files']),timing_runs=8,checked_runs=4,measured_runtime_batches=624,
    checked_outputs=104,rounds=2,runtime_samples_per_case=6,compiler_observations_per_allocator=2,
    comparison='Same-source allocator ranking, not a new 16-run baseline/candidate matrix.',
    estimator='Ratio of arithmetic sample means per workload; equal-workload geometric mean across 26 cases.',
    rank=rank,compile=compile,cases=cases,preparation=prepare)
(OUT/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps({k:v for k,v in summary.items() if k not in ('cases','compile','preparation')},indent=2))
