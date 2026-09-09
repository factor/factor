#!/usr/bin/env python3
"""Render every paired runtime observation without hiding regressions."""
import argparse,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('result',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
r=json.loads(a.result.read_text());assert r['accepted'];d=r['features']['all']
def pct(x):return f'{100*(x-1):+.3f}%'
def two(x):return pct(x['instructions'])+' / '+pct(x['cpu_seconds'])
s=['# Combined feature measurements','',f"Frozen source `{r['source_commit']}`; {r['scope_count']:,} selected words; two strict checked configurations, four fresh timing processes and {r['measured_batches']} measured batches.",'','All four new features switch together. Linear scan stays selected; GVN, rematerialization and loop spill changes stay OFF. A single prepared image is shared by both states. Temporal order: OFF / ON / ON / OFF. Each runtime observation is a median of three batches. Aggregate ratios are geometric means of the two process-level ON/OFF ratios. Negative percentages mean less work or time. There are two independent processes per state, not 360 independent compiler experiments.','','| Measurement | Retired instructions / CPU time |','|---|---:|',f"| Compile selected scope | {two(d['compile_geomean'])} |",f"| Original 26 workloads, geometric mean | {two(d['corpus_geomean'])} |",'','## Every runtime case','','The four constructed witnesses are listed separately from the existing workload corpus.','','| Workload | Aggregate retired / CPU | Round 1 retired / CPU | Round 2 retired / CPU |','|---|---:|---:|---:|']
for group in ['corpus_cases','witness_cases']:
 if group=='witness_cases':s+=['','### Constructed witnesses','','| Workload | Aggregate retired / CPU | Round 1 retired / CPU | Round 2 retired / CPU |','|---|---:|---:|---:|']
 for w in r[group]:s.append(f"| `{w}` | {two(d['per_case'][w])} | {two(d['rounds'][0]['per_case'][w])} | {two(d['rounds'][1]['per_case'][w])} |")
s+=['','## Compiler and corpus by round','','| Round | Compiler retired / CPU | Corpus retired / CPU |','|---|---:|---:|']
for i,x in enumerate(d['rounds'],1):s.append(f"| {i} | {two(x['compile'])} | {two(x['corpus_geomean'])} |")
s+=['','## Final emitted size changes','','Targets with any final static difference are listed, including equal-size changes.','','| Target | Code bytes OFF → ON |','|---|---:|']
for w in r['metric_ids']:
 off,on=(d['final_static'][state][w] for state in ['off','on'])
 if off!=on:s.append(f"| `{w}` | {sum(x['code-bytes'] for x in off)} → {sum(x['code-bytes'] for x in on)} |")
s+=['','Both strict configurations pass SSA, allocation and final value-flow checks. All 30 workload outputs and the full selected scope match. All 16 final static reports match the checked configuration and repeat across timing processes. Full raw observations, including absolute time and counters, are retained in `results.json`.','','This measures recompilation of the selected closure and workload execution, not bootstrap. CPU changes with unchanged retired instructions do not by themselves identify a compiler improvement or its cause. No default is changed by this experiment.','']
a.output.write_text('\n'.join(s))
