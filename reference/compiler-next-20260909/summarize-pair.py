#!/usr/bin/env python3
"""Describe all ordered runtime cases and final machine-IR metrics in a pair."""
import gzip, json, math, statistics, sys
from pathlib import Path

folder = Path(sys.argv[1])
keys = ('cpu_seconds', 'instructions', 'ns')
def mean(xs): return statistics.mean(xs)
def gm(xs): return math.exp(mean(map(math.log, xs)))
def rows(path): return [json.loads(s) for s in gzip.decompress(path.read_bytes()).splitlines()]
runs = {v:[rows(p) for p in sorted((folder/v).glob('*timing-*.jsonl.gz'))] for v in ('baseline','candidate')}
assert all(len(rr)==2 for rr in runs.values())
runtime = {v:[[r for r in rr if r['kind']=='runtime'] for rr in runs[v]] for v in runs}
assert all(len(rr)==104 for vv in runtime.values() for rr in vv)
cases = []
for i in range(26):
    samples = {v:[[rr[j] for j in (i+26,i+52,i+78)] for rr in runtime[v]] for v in runs}
    word = runtime['baseline'][0][i]['word']
    assert all(r['word']==word for vv in samples.values() for rr in vv for r in rr)
    pooled = {k:mean(r[k] for rr in samples['candidate'] for r in rr)/mean(r[k] for rr in samples['baseline'] for r in rr) for k in keys}
    paired = [{k:mean(r[k] for r in b)/mean(r[k] for r in a) for k in keys}
              for a,b in zip(samples['baseline'],samples['candidate'])]
    cases.append(dict(index=i,word=word,candidate_over_baseline=pooled,per_round=paired,samples=samples))

def code_records(rr): return [r['report'] for r in rr if r['kind']=='code']
def final_metrics(report):
    return [dict(code_bytes=p['code-bytes'], **{k:v for k,v in p['passes'][-1].items() if k!='nanoseconds'}) for p in report['procedures']]
static = []
for i,(b,c) in enumerate(zip(code_records(runs['baseline'][0]),code_records(runs['candidate'][0]))):
    before,after = final_metrics(b),final_metrics(c)
    static.append(dict(index=i,input=b['input'],baseline=before,candidate=after,
        total_delta={k:sum(p[k] for p in after)-sum(p[k] for p in before)
                     for k in ('code_bytes','spills','reloads','copies','instructions','blocks')},
        stable_within_revision=all(final_metrics(code_records(runs[v][0])[i])==final_metrics(code_records(runs[v][1])[i]) for v in runs)))
summary = dict(runtime_geomean={k:gm(x['candidate_over_baseline'][k] for x in cases) for k in keys},
    per_round_geomean=[{k:gm(x['per_round'][i][k] for x in cases) for k in keys} for i in (0,1)],
    measured_samples_per_case_per_revision=6,ordered_cases=cases,kernel_metrics=static,
    copy_metric='Machine-IR ##copy count; equal-register copies may emit no machine instruction.')
(folder/'case-details.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps({k:v for k,v in summary.items() if k not in ('ordered_cases','kernel_metrics')},indent=2))
for c in cases:
    print(c['index'],c['word'],c['candidate_over_baseline'],c['per_round'])
for s in static:
    if any(s['total_delta'].values()): print('STATIC',s['index'],s['input'],s['total_delta'],s['stable_within_revision'])
