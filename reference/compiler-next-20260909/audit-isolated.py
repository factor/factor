#!/usr/bin/env python3
"""Read-only collection and independent scope/options audit of completed pairs."""
from pathlib import Path
import hashlib, importlib.util, json, statistics, sys

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('collector', HERE/'collect-isolated.py')
c = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c)
name = sys.argv[1]
assert name in ('greedy', 'algebra', 'chordal', 'backtracking')
dest = HERE/'independent-native-audit'/('native-'+name)
base = '/home/erg/factor-compiler-next-greedy-baseline-20260909'
candidate = '/home/erg/factor-compiler-next-'+('greedy-candidate' if name == 'greedy' else name)+'-20260909'
scopes, compiles, runs, prepares = {}, {}, {}, {}
for variant, root in [('baseline', base), ('candidate', candidate)]:
    if name == 'greedy':
        names = ['next-'+variant+'-timing-greedy-'+str(i) for i in (1, 2)]
        sub = c.REL
    elif name == 'backtracking':
        names = ['isolated-backtracking-'+variant+'-timing-backtracking-'+str(i) for i in (1, 2)]
        sub = c.REL
    else:
        names = ['isolated-'+name+'-'+variant+'-'+str(i) for i in (1, 2)]
        sub = c.NXT
    files = c.fetch(root, sub, [n+e for n in names for e in ('.jsonl', '.status.json', '.log')], dest/variant)
    runs[variant] = [c.getrows(files, n) for n in names]
    scopes[variant] = [next(r for r in rows if r['kind']=='scope') for rows in runs[variant]]
    compiles[variant] = [next(r for r in rows if r['kind']=='compile') for rows in runs[variant]]
    for n, scope in zip(names, scopes[variant]):
        status = json.loads(files[n+'.status.json'])
        assert scope['source'] == status['source_commit']
        assert scope['allocator'] == ('linear-scan' if name == 'algebra' else name)
        assert scope['options'] == {'rematerialize_constants': True, 'backtracking_loop_spills': True, 'gvn': False}
        assert scope['checked'] is False
        assert status['command'][:3] == ['taskset', '-c', '2']
    assert scopes[variant][0]['words'] == scopes[variant][1]['words']
    mf = c.fetch(root, c.REL, ['source-expected.json', 'source-manifest.json'], dest/variant)
    manifest = json.loads(mf['source-manifest.json'])
    assert manifest['all_match'] is True
    assert manifest['source_commit'] == scopes[variant][0]['source']
    if variant == 'baseline' or name == 'greedy':
        label = 'greedy-'+variant+'-prepare'
        prep = 'prepare-greedy.factor'
    else:
        label = 'next-prepare'
        prep = 'prepare-next.factor'
    pf = c.fetch(root, c.NXT, [label+'.status.json', label+'.log', prep], dest/variant)
    prepares[variant] = json.loads(pf[label+'.status.json'])
    assert prepares[variant]['status'] == 0
    assert prepares[variant]['source_commit'] == scopes[variant][0]['source']
    assert prepares[variant]['preparation_script_sha256'] == hashlib.sha256(pf[prep]).hexdigest()

words = {v:[w.rsplit('|', 1)[0] for w in ss[0]['words']] for v,ss in scopes.items()}
required = ['classes.algebra:class-and', 'classes.algebra:class-or']
if name == 'greedy': required += ['compiler.cfg.register-allocation.greedy:hint-score', 'compiler.cfg.register-allocation.greedy:allocation-order']
if name == 'chordal': required += ['compiler.cfg.register-allocation.chordal:preferred-free-color']
if name == 'backtracking': required += ['compiler.cfg.register-allocation.backtracking:reify-entry-transports']
assert all(w in words['candidate'] for w in required)
assert all(w in words['baseline'] for w in required[:2])
summary = dict(accepted=True, scope_words={v:len(w) for v,w in words.items()},
    required_candidate_words=required, added_words=sorted(set(words['candidate'])-set(words['baseline'])),
    removed_words=sorted(set(words['baseline'])-set(words['candidate'])),
    identical_scope_sequence=words['baseline']==words['candidate'],
    compile=compiles, compile_candidate_over_baseline=c.compile_ratios(compiles['baseline'],compiles['candidate']),
    per_round_compile_candidate_over_baseline=[{k:b[k]/a[k] for k in ('cpu_seconds','instructions','ns')}
        for a,b in zip(compiles['baseline'],compiles['candidate'])],
    preparation=prepares, order=['baseline-1','candidate-1','candidate-2','baseline-2'])
if name in ('greedy','backtracking'):
    kernel = {}
    for v, rows in runs.items():
        kernel[v] = [[c.strip(r['report']) for r in rr if r['kind']=='code'] for rr in rows]
        assert all(len(k)==12 for k in kernel[v])
        assert all(len([r for r in rr if r['kind']=='runtime'])==104 for rr in rows)
    summary['all_kernel_non_timing_metrics_equal'] = all(k==kernel['baseline'][0] for rows in kernel.values() for k in rows)
    # Match the ordered 26 cases, including repeated word names with distinct inputs.
    batches = {v:[[r for r in rr if r['kind']=='runtime'] for rr in rows] for v,rows in runs.items()}
    oracle = [(r['word'],r['output']) for r in batches['baseline'][0][:26]]
    assert all([(r['word'],r['output']) for r in rows[i:i+26]]==oracle
               for vv in batches.values() for rows in vv for i in range(0,104,26))
    summary['outputs_identical_26_cases_all_batches'] = True
(dest/'audit.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps(summary,indent=2))
