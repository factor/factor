#!/usr/bin/env python3
from pathlib import Path
import json,math
P=Path(__file__).resolve().parent;r=json.loads((P/'native-analysis.json').read_text())
def pct(x):return f'{100*(x-1):+.4f}%'
lines=['# Native x86 GVN × rematerialization results','',
'Both features work in the exercised compiler paths. Their correctness and positive activity gates pass, but this corpus does not establish a broad runtime speedup. Defaults remain unchanged.','',
'Production source: `ad0fc337de5ce51816f8251fa490f7aee9b74074`. The matrix uses LS, GVN/rematerialization settings `00`, `10`, `01`, `11`, and loop spilling off. The balanced order is `00,10,11,01 / 01,11,10,00`. Four checked closures and eight fresh timing processes pass: identical 28,500 selected word objects, all 26 language outputs equal, 624 measured batches, six samples per workload/configuration, and two compiler observations per configuration. No failed run or performance-based sample exclusion occurred.','',
'Each round uses the median of three runtime samples per case. Tables combine the two paired ratios geometrically; runtime corpus figures also use an unweighted geometric mean over 26 cases. Negative percentages mean less work/time. `native-analysis.json` retains every case, round, raw observation, arithmetic compiler-ratio mean, geometric compiler-ratio mean, and factorial interaction. Hardware instructions are main-thread user-space retired instructions, excluding kernel and hypervisor. CPU time is main-thread CPU time.','',
'| Configuration versus both off | Compiler retired | Compiler CPU | Runtime retired | Runtime CPU |','|---|---:|---:|---:|---:|']
for key,label in [('10_vs_00','GVN only'),('01_vs_00','Rematerialization only'),('11_vs_00','Both')]:
 v=r['comparisons'][key];lines.append('| '+label+' | '+' | '.join(pct(v[k][m]) for k,m in [('compile_geomean','instructions'),('compile_geomean','cpu_seconds'),('runtime_geomean','instructions'),('runtime_geomean','cpu_seconds')])+' |')
lines += ['', '## Direction across both rounds','', '| Comparison | Round | Compiler retired | Compiler CPU | Runtime retired | Runtime CPU |','|---|---:|---:|---:|---:|---:|']
for key in ['10_vs_00','01_vs_00','11_vs_00','11_vs_10']:
 for i,v in enumerate(r['comparisons'][key]['rounds'],1):lines.append('| '+key+' | '+str(i)+' | '+' | '.join(pct(v[k][m]) for k,m in [('compile','instructions'),('compile','cpu_seconds'),('runtime_geomean','instructions'),('runtime_geomean','cpu_seconds')])+' |')
lines += ['', '## Workload attribution','', '| Workload | Setting vs 00 | Retired round 1 | Retired round 2 | CPU round 1 | CPU round 2 |','|---|---|---:|---:|---:|---:|']
for word in ['struct-work','base64-work','nbody-work','nbody-simd-work','base32-work']:
 for c in ['10','01','11']:
  vs=[v['per_case']['allocator-runtime-comparison:'+word] for v in r['comparisons'][c+'_vs_00']['rounds']];lines.append('| '+word+' | '+c+' | '+' | '.join(pct(vs[i][m]) for m,i in [('instructions',0),('instructions',1),('cpu_seconds',0),('cpu_seconds',1)])+' |')
lines += ['',
'GVN consistently reduces retired instructions for struct (about 0.675%), base64 (0.324%), and SIMD nbody (0.123%). Scalar nbody is effectively flat. CPU changes on these small cases do not consistently follow the instruction changes: even paths with nearly unchanged retired work shift in CPU time. These measurements establish modest work reductions, not persuasive runtime CPU wins.','',
'Both enabled produces a repeatable base32 increase of about 3.419% retired instructions in each round, accompanied by increased CPU time. Neither feature alone shows that retired increase. This is retained as a measured interaction, not dismissed as timing noise. The 12 static metric targets do not include base32, and this experiment does not establish whether its cause is emitted code, dispatch/runtime state, or another effect. No detached code capture or speculative cause is presented.','',
'## Interaction','',
'Adding rematerialization to GVN changes compiler retired work by '+pct(r['comparisons']['11_vs_10']['compile_geomean']['instructions'])+' and runtime corpus retired work by '+pct(r['comparisons']['11_vs_10']['runtime_geomean']['instructions'])+'. The latter is dominated by the base32 interaction. The multiplicative factorial interaction is `11 × 00 / (10 × 01)`; a value of one would mean multiplicatively independent effects.','']
i=r['multiplicative_interaction_11_times_00_over_10_times_01'];lines += ['| Metric | Compiler interaction | Runtime interaction round 1 | Runtime interaction round 2 |','|---|---:|---:|---:|']
for m in ['instructions','cpu_seconds']:lines.append('| '+m+' | '+pct(i[m]['compiler_geomean'])+' | '+pct(i[m]['runtime_rounds'][0])+' | '+pct(i[m]['runtime_rounds'][1])+' |')
lines += ['', '## Static code and activity','',
'Of the 12 static metric targets, nbody and struct change; the other ten do not. Counts below are final machine IR stores/reloads and generated code size. Copy counts in the complete JSON are IR copies, not necessarily emitted moves.','',
'| Target | 00 bytes / spills / reloads | 10 | 01 | 11 |','|---|---:|---:|---:|---:|',
'| nbody | 4368 / 36 / 21 | 4304 / 33 / 18 | 4336 / 33 / 18 | 4304 / 33 / 18 |',
'| struct | 1584 / 15 / 16 | 1568 / 14 / 15 | 1584 / 15 / 16 | 1568 / 14 / 15 |','',
'Both-on static reports equal GVN-only reports, consistent with overlapping transformations on these targets. The separate pressure witness proves actual rematerialization emission for all four allocators: LS 736→512 bytes and 28 stores/reloads→zero; greedy 720→480; backtracking 704→480; chordal 736→512. The ordinary GVN gate reports 17 pass invocations and 11 changed graphs, with independent native outputs. See `NATIVE-AUDIT.md` for all callback/GC and mutation checks.','',
'## Reproduction and limits','',
'`native-x86/matrix/` preserves compressed raw logs/JSONL, exact executed scripts, source/image/VM hashes, counter guards, host load snapshots, and all statuses. `native-x86/source/` contains the 1,589-path manifests; `native-x86/support-source/` contains the unchanged workload and counter sources. The machine is native x86 Linux, not Rosetta. Measured processes use CPU2 at nice0 with the original capability-bearing VM. `native-x86/audit/` is separately labeled test-only source overlays; it never replaces the timed image or canonical closure.','',
'Reproduce analysis with:','',
'```','python3 reference/compiler-flags-20260909/analyze.py reference/compiler-flags-20260909/native-x86/matrix --prefix native --output reference/compiler-flags-20260909/native-analysis.json','```','',
'Two rounds provide limited CPU confidence, and these 26 workloads are not exhaustive. The positive allocation witness is not a runtime speed claim. No additional chordal timing or bootstrap is included in this factorial experiment.']
(P/'NATIVE-RESULTS.md').write_text('\n'.join(lines)+'\n')
