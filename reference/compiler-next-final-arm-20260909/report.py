#!/usr/bin/env python3
"""Render final ARM audit, preserving per-round uncertainty and pre-fix tradeoffs."""
import json,gzip,math
from pathlib import Path
P=Path(__file__).resolve().parent; a=json.loads((P/'audit.json').read_text());assert not a['pending'],a['pending']
pre=Path(__file__).resolve().parents[1]/'compiler-next-arm-20260909';old=json.loads((pre/'audit.json').read_text())
c=a['comparisons']['backtracking'];prior=old['comparisons']['backtracking']
def pct(x):return f'{(x-1)*100:+.3f}%'
def paired(case,metric,comp=c):
 key='allocator-runtime-comparison:'+case+'-pressure-work'
 return math.sqrt(comp['rounds'][0]['workloads'][key][metric]['ratio']*comp['rounds'][1]['workloads'][key][metric]['ratio'])
def code(root,label,stem,case):
 rs=[json.loads(x) for x in gzip.open(root/label/(stem+'.jsonl.gz'),'rt')]
 q=next(x['report']['procedures'][0] for x in rs if x['kind']=='code' and x['report']['input']==case+'-pressure')
 p=q['passes'][-1];return {'code_bytes':q['code-bytes'],'spills':p['spills'],'reloads':p['reloads'],'copies':p['copies'],'blocks':p['blocks'],'allocation':q['allocation']}
static={case:{'baseline':code(P,'baseline','final-baseline-timing-backtracking-1',case),'pre_fix':code(pre,'candidate','arm-next-candidate-timing-backtracking-1',case),'final':code(P,'candidate','final-candidate-timing-backtracking-1',case)} for case in ['ffi','branch','integer']}
summary={'source':a['sources']['candidate']['revision'],'baseline':a['sources']['baseline']['revision'],'pre_fix_source':old['sources']['candidate']['revision'],'scope':a['scope_differences'],'aggregate':c['paired_geomean'],'workloads':{case:{'final_own_baseline':{m:paired(case,m) for m in ['cpu_seconds','instructions']},'pre_fix_own_baseline':{m:paired(case,m,prior) for m in ['cpu_seconds','instructions']},'static':static[case]} for case in static}}
(P/'comparison.json').write_text(json.dumps(summary,indent=2,sort_keys=True)+'\n')
L=['# Final ARM backtracking audit','',f"Final source `{a['sources']['candidate']['revision'][:10]}`; original baseline `c1f7e4d34c`; pre-fix combined candidate `eccfc0accc`. Final production is byte-identical to `c6948a99de`; the later freeze changes one test fixture and evidence. This is a **targeted backtracking timing matrix**, not an all-four timing matrix.",'',
'## Correctness and provenance','',
'All four loaded compiler-vocabulary suites pass. This means the harness’s loaded-child vocabulary scope, not every compiler test vocabulary on the filesystem. The linear-scan pass is reused from c694 with production equality verified; greedy, backtracking and chordal pass on the final freeze. The corrected backtracking fixture is explicitly tested with rematerialization both on and off. The failed c694 greedy attempt remains under `failed-attempt-c6948a99de`, clearly excluded from accepted results.','',
'Final backtracking and chordal checked closures pass with SSA, interval and final original-value verification. Every one of 26 runtime outputs and iteration counts agrees across checked and timed runs. All 12 ordered code reports are retained and stable across timing rounds after removing timing fields. The counter audit rejects nonpositive CPU, wall-time or retired-instruction observations. Callback and moving-GC gates pass on the final source, followed by default bootstrap and image verification.','']
for label,s in a['sources'].items():L.append(f"- {label}: {s['guarded_files']} expanded core/VM/compiler hashes match; prepared-image hash matches preparation status; {s['scope_words']:,} words selected.")
L+=['',
'Exact ordered scope lists match within each source. The final dependency closure adds 13 words and removes two old phase wrappers, for a net increase of 11. Source inspection establishes the replacement: backtracking calls `assign-phase-ssa-registers-recording`, whose traversal calls `assign-phase-ssa-block-recording` directly. The old wrapper APIs remain in source but leave the dependency closure. All 26 benchmark entrypoints and the new recording/profitability helpers are selected. The full difference and source diff are archived; this report does not claim an identical compiler helper scope.','',
'## Reversed-pair measurements','',
'Four fresh timing processes ran baseline → candidate → candidate → baseline. Each has three measured samples after one warmup per workload; rematerialization and loop placement are on, GVN and timed checkers off. Ratios below are candidate / original baseline. Runtime figures are geometric means over 26 ratios of within-process sample medians; the final column combines the two reversed-round ratios geometrically.','',
'| Measurement | B→C round | C→B round | Paired ratio |','|---|---:|---:|---:|']
for kind in ['compile','runtime']:
 for metric in ['instructions','cpu_seconds','ns']:
  vs=[r[kind][metric]['ratio'] if kind=='compile' else r[kind][metric] for r in c['rounds']]
  L.append(f"| {kind} {metric} | {vs[0]:.6f} | {vs[1]:.6f} | {c['paired_geomean'][kind][metric]:.6f} |")
L+=['',f"Final runtime retired-instruction change is {pct(c['paired_geomean']['runtime']['instructions'])}; compile retired-instruction change is {pct(c['paired_geomean']['compile']['instructions'])}. Per-round CPU and wall-time results are retained because ARM hardware execution rate varies substantially. Measured compile CPU increases 9.17% and runtime CPU increases 5.48%; this run establishes no ARM CPU speedup. The mismatch between CPU and retired-instruction changes limits source-level attribution in either direction.",'',
'## FFI, branch and integer pressure','',
'| Workload | Pre-fix retired vs its baseline | Final retired B→C | Final retired C→B | Final paired retired | Final paired CPU |','|---|---:|---:|---:|---:|---:|']
for case in static:
 key='allocator-runtime-comparison:'+case+'-pressure-work';r=[x['workloads'][key]['instructions']['ratio'] for x in c['rounds']]
 L.append(f"| {case} | {pct(paired(case,'instructions',prior))} | {pct(r[0])} | {pct(r[1])} | {pct(paired(case,'instructions'))} | {pct(paired(case,'cpu_seconds'))} |")
L+=['','The pre-fix and final columns are each normalized to their own contemporary c1 baseline. They come from separate run windows and are not an isolated paired final-versus-pre-fix CPU comparison.','',
'| Workload / static metric | Original c1 | Pre-fix ecc | Final a7 |','|---|---:|---:|---:|']
for case,versions in static.items():
 for key in ['code_bytes','spills','reloads','copies','blocks']:
  L.append(f"| {case} {key} | {versions['baseline'][key]} | {versions['pre_fix'][key]} | {versions['final'][key]} |")
rank=[]
for word in c['rounds'][0]['workloads']:
 ratios=[r['workloads'][word]['instructions']['ratio'] for r in c['rounds']]
 rank.append((math.sqrt(ratios[0]*ratios[1]),word,ratios))
L+=['','Largest remaining retired-instruction increases (both rounds shown):','', '| Workload | B→C | C→B | Paired |','|---|---:|---:|---:|']
for ratio,word,rs in sorted(rank,reverse=True)[:3]:L.append(f"| {word} | {pct(rs[0])} | {pct(rs[1])} | {pct(ratio)} |")
L+=['','SIMD’s main-kernel code size and spill/reload counts are unchanged (1136 bytes, 11 spills, 11 reloads); its measured workload increase remains a reported regression rather than being attributed to an unproven mechanism. Integer’s main-kernel static output also remains unchanged despite the workload instruction reduction. These measurements include the selected workload dependencies, not just the separately reported kernel.','',
'The final profitability decision uses actual post-assignment predecessor locations. It retains one successor reload when every incoming value already has the same memory home, and delegates mixed locations to parallel edge transport. This targets the pre-fix branch duplication while preserving the FFI store/reload reduction. Raw allocation counters, including delegated entry reloads, remain in the JSONL and `comparison.json`.','',
'## Bootstrap context','']
bs={label:json.loads((P/'bootstrap'/label/'status.json').read_text()) for label in ['baseline','candidate']}
bs['historical-1m52']=json.loads((P/'bootstrap/historical-1m52/status.json').read_text())
for label,x in bs.items():
 u=x['last_process_usage'];L.append(f"- {label}: {x['seconds']:.3f} s wall; {u['cpu']:.3f} s sampled CPU; {u['instructions']:,} sampled retired instructions; {u['instructions']/u['cpu']/1e9:.3f} billion instructions per CPU-second.")
L+=['',
f"Final whole-process bootstrap is {bs['candidate']['seconds']:.3f} seconds (core reports 3:19), so the requested two-minute goal is unmet. Retired instructions change {pct(bs['candidate']['last_process_usage']['instructions']/bs['baseline']['last_process_usage']['instructions'])} against contemporary c1 and {pct(bs['candidate']['last_process_usage']['instructions']/bs['historical-1m52']['last_process_usage']['instructions'])} against the accepted historical 1:52-core run. The root image and original integration factor.image hashes still equal the recorded pre-run hash; the final image is saved separately.",'',
'The baseline bootstrap is the previously recorded contemporary c1 run, not an interleaved final bootstrap pair. PID snapshots may precede process exit. Differences in execution rate must be considered before attributing the wall-time change to compiler improvements.','',
'## Archive and reproduction','',
'`collect.py` performs read-only source/image/scope/output/counter checks and copies only completed records into this directory. `report.py` generates this report and the focused comparison JSON. `phase-dependency-change.diff` explains the selected helper replacement. `queue-driver.py` is an archived parent-owned driver, not an active workload. No compiler, VM, integration source, or benchmark driver was modified by collection, and no Factor/CPU workload was launched by the auditor.','']
(P/'RESULTS.md').write_text('\n'.join(L))
print(json.dumps(summary['aggregate'],indent=2))
