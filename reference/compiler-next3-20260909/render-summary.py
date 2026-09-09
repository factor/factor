#!/usr/bin/env python3
"""Render validated numeric results; causal interpretation belongs in the audit."""
import argparse,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('result',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
r=json.loads(a.result.read_text());assert r['accepted']
friendly={'loops':'LICM','representations':'Representation costs','memory':'Memory load reuse','slp':'Integer SLP'}
features=list(friendly);witness=dict(zip(features,r['witness_cases']))
def pct(x):return f'{100*(x-1):+.3f}%'
def two(d):return pct(d['instructions'])+' / '+pct(d['cpu_seconds'])
s=['# Feature measurements','',f"Frozen source `{r['source_commit']}`; {r['scope_count']:,} selected words; {r['checked_processes']} checked configurations; {r['timing_processes']} timing processes and {r['measured_batches']} measured batches. All language outputs, source/image/VM identities, and checked-versus-timed final code metrics match.",'','Each result below is ON/OFF minus one. Negative means less work or CPU time. The geometric mean combines the two process-level ratios; each process contributes the median of three runtime batches per case. Compiler measurements have two observations per setting. The original 26 workloads are separate from the four constructed witnesses.','','| Feature | Compiler retired / CPU | Original 26 retired / CPU | Own witness retired / CPU |','|---|---:|---:|---:|']
for f in features:
 d=r['features'][f];s.append(f"| {friendly[f]} | {two(d['compile_geomean'])} | {two(d['corpus_geomean'])} | {two(d['witnesses'][witness[f]])} |")
s+=['','The two OFF processes are shared anchors for all four comparisons. Estimates are correlated, and the settings have different temporal distance from those anchors. These are paired observations, without significance claims.','','## Individual rounds','','| Feature / round | Compiler retired / CPU | Original 26 retired / CPU | Own witness retired / CPU |','|---|---:|---:|---:|']
for f in features:
 for i,d in enumerate(r['features'][f]['rounds'],1):s.append(f"| {friendly[f]} / {i} | {two(d['compile'])} | {two(d['corpus_geomean'])} | {two(d['per_case'][witness[f]])} |")
s+=['','## Final emitted size changes','','Only targets with a final size or final machine-IR change are listed. Machine-IR copies are not a count of emitted moves; equal-register copies can disappear in code generation.','','| Feature | Target | Bytes OFF → ON |','|---|---|---:|']
for f in features:
 d=r['features'][f]['final_static']
 for w in r['metric_ids']:
  if d['off'][w]!=d['on'][w]:s.append(f"| {friendly[f]} | `{w}` | {sum(p['code-bytes'] for p in d['off'][w])} → {sum(p['code-bytes'] for p in d['on'][w])} |")
s+=['','All 16 final static reports match the corresponding strict checked configuration and repeat across both timing processes. The all-OFF first 12 reports match the retained old default-OFF baseline.' if r['default_off_first12_match_old'] else 'All 16 final static reports match the corresponding strict checked configuration and repeat across both timing processes.','','Full per-case and per-round observations, including unaffected witnesses, are retained in `'+a.result.name+'`. CPU changes with unchanged retired instructions require separate execution-rate or code-layout investigation; this report does not infer their cause.','']
a.output.write_text('\n'.join(s))
