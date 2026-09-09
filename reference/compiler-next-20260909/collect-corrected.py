#!/usr/bin/env python3
"""Retain the complete corrected native sequence and audit its exact scopes."""
from pathlib import Path
import difflib, hashlib, importlib.util, json, statistics, subprocess

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('collector',HERE/'collect-isolated.py')
c=importlib.util.module_from_spec(spec);spec.loader.exec_module(c)
OUT=HERE/'corrected-native/final-a7'
BASE='/home/erg/factor-compiler-next-greedy-baseline-20260909'
CAND='/home/erg/factor-compiler-next-final-c6948-20260909'
PREFIX='/home/erg/factor-compiler-next-combined-20260909'
SOURCE='a7f554b613bd763fb7fbfc520643b75b321a6e16'
OLD='5c848c90f63cea092191b70e1678bec4441e0238'
PRE='eccfc0accc5c513b44701f2e59d4a9bafb7515f0'
rows={};captures={};scopes={};compiles={}
for v,root,rev in [('baseline',BASE,OLD),('candidate',CAND,SOURCE)]:
    names=['corrected-'+v+'-timing-backtracking-'+str(i) for i in (1,2)]
    f=c.fetch(root,c.REL,[n+e for n in names for e in ('.jsonl','.status.json','.log')],OUT/v)
    rows[v]=[c.getrows(f,n) for n in names]
    scopes[v]=[];compiles[v]=[]
    for name,rr in zip(names,rows[v]):
        st=json.loads(f[name+'.status.json']);assert st['source_commit']==rev
        ss=next(x for x in rr if x['kind']=='scope');scopes[v].append(ss)
        assert ss['source']==rev and ss['allocator']=='backtracking' and ss['checked'] is False
        assert ss['options']=={'rematerialize_constants':True,'backtracking_loop_spills':True,'gvn':False}
        assert st['command'][:3]==['taskset','-c','2']
        compiles[v].append(next(x for x in rr if x['kind']=='compile'))
        assert len([x for x in rr if x['kind']=='code'])==12
        assert len([x for x in rr if x['kind']=='runtime'])==104
    assert scopes[v][0]['words']==scopes[v][1]['words']
    m=c.fetch(root,c.REL,['source-expected.json','source-manifest.json'],OUT/v)
    assert json.loads(m['source-manifest.json'])['all_match'] is True
    name='corrected-'+v+'-captured-check'
    f=c.fetch(root,c.NXT,[name+e for e in ('.jsonl','.status.json','.log')]+['capture-checked.factor','capture-workload-code.factor'],OUT/v/'capture')
    rr=c.getrows(f,name);st=json.loads(f[name+'.status.json'])
    assert st['diagnostic_only'] and st['final_value_verifier'] and st['source_commit']==rev
    assert all(st['script_sha256'][n]==hashlib.sha256(f[n]).hexdigest() for n in ['capture-checked.factor','capture-workload-code.factor'])
    ss=next(x for x in rr if x['kind']=='scope');assert ss['words']==scopes[v][0]['words'] and ss['checked']
    assert len([x for x in rr if x['kind']=='runtime'])==26
    captures[v]={x['word']:x for x in rr if x['kind']=='generated-code'}
    assert set(captures[v])=={'allocator-runtime-comparison:base32-work','allocator-runtime-comparison:integer-pressure-work'}

oracle=[(x['word'],x['output']) for x in rows['baseline'][0] if x['kind']=='runtime'][:26]
for vv in rows.values():
    for rr in vv:
        runtime=[x for x in rr if x['kind']=='runtime']
        for i in range(0,104,26):assert [(x['word'],x['output']) for x in runtime[i:i+26]]==oracle
subprocess.run(['python3',str(HERE/'summarize-pair.py'),str(OUT)],check=True,stdout=subprocess.DEVNULL)

word_names={v:{w.rsplit('|',1)[0] for w in ss[0]['words']} for v,ss in scopes.items()}
entrypoints={word for word,_ in oracle}
assert all(entrypoints <= names for names in word_names.values())
required=['classes.algebra:class-and','classes.algebra:class-or',
    'compiler.cfg.register-allocation.backtracking:common-entry-home?',
    'compiler.cfg.register-allocation.backtracking:entry-transport-records',
    'compiler.cfg.register-allocation.backtracking:check-recorded-entry-reload',
    'compiler.cfg.register-allocation.backtracking:reify-entry-transports',
    'compiler.cfg.register-allocation.ssa.phases:assign-phase-ssa-registers-recording',
    'compiler.cfg.register-allocation.ssa.phases:activate-recorded-entry']
assert all(w in word_names['candidate'] for w in required)

identities={}
for word,b in captures['baseline'].items():
    a=captures['candidate'][word]
    identities[word]=dict(bytes={v:len(captures[v][word]['code-bytes']) for v in captures},
        code_sha256={v:hashlib.sha256(bytes(captures[v][word]['code-bytes'])).hexdigest() for v in captures},
        equal={k:b[k]==a[k] for k in ['code-bytes','relocations','parameters','literals','frame-bytes','physical-instructions']},
        physical_diff=list(difflib.unified_diff(b['physical-instructions'],a['physical-instructions'],fromfile='baseline',tofile='candidate')))

g=c.fetch(CAND,'reference/allocator-tuning-20260909',[n+e for n in ['callback-matrix.factor','moving-gc.factor'] for e in ('','.log','.status.json')]+['gates.py'],OUT/'gates')
for n,marker in [('callback-matrix.factor','CALLBACK-MATRIX-COMPLETE'),('moving-gc.factor','MOVING-GC-MATRIX-COMPLETE')]:
    st=json.loads(g[n+'.status.json']);assert st['ok'] and st['exit_code']==0 and st['source_commit']==SOURCE
    assert marker.encode() in g[n+'.log'] and st['script_sha256']==hashlib.sha256(g[n]).hexdigest()
    assert st['final_value_verifier'] and st['rematerialization']==[False,True]
u=c.fetch(CAND,c.NXT,['corrected-unit.factor','corrected-unit.log','corrected-unit.status.json',
    'prepare-corrected.factor','corrected-a7-prepare.status.json','corrected-a7-prepare.log'],OUT/'gates')
st=json.loads(u['corrected-unit.status.json']);assert st['ok'] and st['exit_code']==0 and st['source_commit']==SOURCE
prep=json.loads(u['corrected-a7-prepare.status.json']);assert prep['status']==0 and prep['source_commit']==SOURCE
assert prep['preparation_script_sha256']==hashlib.sha256(u['prepare-corrected.factor']).hexdigest()
ch='corrected-check-chordal-1'
f=c.fetch(CAND,c.REL,[ch+e for e in ('.jsonl','.status.json','.log')],OUT/'gates')
rr=c.getrows(f,ch);ss=next(x for x in rr if x['kind']=='scope')
assert ss['allocator']=='chordal' and ss['checked'] and ss['source']==SOURCE and ss['words']==scopes['candidate'][0]['words']
assert [(x['word'],x['output']) for x in rr if x['kind']=='runtime']==oracle

bracket=[]
for root,label,rev in [(PREFIX,'corrected-chordal-prefix-1',PRE),(CAND,'corrected-chordal-final-1',SOURCE),(PREFIX,'corrected-chordal-prefix-2',PRE)]:
    f=c.fetch(root,c.NXT,[label+e for e in ('.jsonl','.status.json','.log')]+['corrected-compile-only.factor'],OUT/'chordal-bracket'/label)
    rr=c.getrows(f,label);assert [r['kind'] for r in rr]==['scope','compile']
    st=json.loads(f[label+'.status.json']);assert st['source_commit']==rev and st['script_sha256']==hashlib.sha256(f['corrected-compile-only.factor']).hexdigest()
    assert rr[0]['source']==rev and rr[0]['allocator']=='chordal' and not rr[0]['checked']
    assert rr[0]['options']=={'rematerialize_constants':True,'backtracking_loop_spills':True,'gvn':False}
    bracket.append(dict(label=label,source=rev,scope_words=len(rr[0]['words']),compile=rr[1]))
summary=dict(accepted=True,acceptance_scope='Measurement/gate integrity; performance decision belongs to parent.',
    source_commit=SOURCE,baseline_compiler_snapshot=OLD,logical_baseline='c1f7e4d34cd604bbdf22576b237406b39758896d',
    scope_words={v:len(w) for v,w in word_names.items()},added_words=sorted(word_names['candidate']-word_names['baseline']),
    removed_words=sorted(word_names['baseline']-word_names['candidate']),required_helpers=required,
    benchmark_entrypoints=sorted(entrypoints),
    compile=compiles,compile_candidate_over_baseline=c.compile_ratios(compiles['baseline'],compiles['candidate']),
    code_identity=identities,chordal_bracket=bracket,
    chordal_final_over_bracketing_mean={k:bracket[1]['compile'][k]/statistics.mean([bracket[0]['compile'][k],bracket[2]['compile'][k]]) for k in ['cpu_seconds','instructions','ns']},
    preparation=prep,timing_runs=4,measured_runtime_batches=312,runtime_samples_per_case_per_revision=6)
(OUT/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps({k:v for k,v in summary.items() if k not in ['code_identity','preparation','compile']},indent=2))
