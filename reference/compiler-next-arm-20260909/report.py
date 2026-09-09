#!/usr/bin/env python3
"""Render the audited ARM records without rerunning any compiler workload."""
import json,math,gzip
from pathlib import Path
P=Path(__file__).resolve().parent; a=json.loads((P/'audit.json').read_text());assert not a['pending']
lines=['# Targeted ARM compiler-next audit','',
'Baseline `c1f7e4d34c`; combined candidate `eccfc0accc`. This is an **LS/backtracking timing matrix**, not an all-four timing matrix. All four allocators have separate checked-closure and full compiler-suite gates. These are combined-source results; they do not isolate one patch.','',
'All 12 final runs pass: four checked closures plus eight timing processes (LS and backtracking, baseline → candidate → candidate → baseline). Each timing process has three measured samples after one warmup for each of 26 workloads. Every output, iteration count, positive instruction counter and record count passes the audit. Callback and moving-GC matrices also pass. Timing processes have checks off; the four separate checked closures have SSA/interval/final-value verification enabled. Every run uses rematerialization on, loop placement on and GVN off.','',
'## Scope and source provenance','']
for label,s in a['sources'].items():lines.append(f"- {label}: {s['guarded_files']} expanded core/VM/compiler source hashes match the expected revision; prepared-image hash matches preparation status; {s['scope_words']:,} selected words.")
lines+=['','Exact ordered scope lists match across allocators and rounds within each source. Candidate adds only `backtracking-edge-entry-reloads`, `edge-entry-reload?`, `reify-entry-transports`, and chordal `preferred-free-color`; no original semantic word is omitted. Printed ordinal suffixes shift after inserted names and are excluded only from cross-source semantic-set comparison. All 12 ordered kernel reports are stable across timing rounds after removing timing fields (two different kernels share the printed name `nbody`, so order is preserved).','',
'## Own-baseline ratios','',
'Ratios below are candidate / baseline. Each runtime ratio is the geometric mean over 26 per-workload ratios of three-sample medians. The last column is the geometric mean of the two reversed-round ratios; compile ratios use the one selected-closure compile measurement per process.','',
'| Allocator / measurement | B→C round | C→B round | Paired geometric mean |','|---|---:|---:|---:|']
for allocator in ['linear-scan','backtracking']:
 c=a['comparisons'][allocator]
 for kind in ['compile','runtime']:
  for metric in ['instructions','cpu_seconds']:
   values=[r[kind][metric]['ratio'] if kind=='compile' else r[kind][metric] for r in c['rounds']]
   lines.append(f"| {allocator} {kind} {metric} | {values[0]:.6f} | {values[1]:.6f} | {c['paired_geomean'][kind][metric]:.6f} |")
lines+=['','Backtracking runtime retired instructions are essentially flat (+0.0119%); compile retired instructions decrease 0.284%. LS runtime retired instructions increase 0.0868%, and compile instructions increase 0.0653%. The apparent CPU improvements are much larger than the instruction changes, including LS, and should not be interpreted as broad allocator CPU wins. Backtracking compile CPU even changes direction between rounds (+3.88%, then −4.74%).','',
'## Backtracking workload tradeoffs','',
'| Workload / metric | B→C round | C→B round | Paired geometric mean |','|---|---:|---:|---:|']
for case in ['ffi','branch','integer']:
 key='allocator-runtime-comparison:'+case+'-pressure-work'
 for metric in ['instructions','cpu_seconds']:
  vs=[r['workloads'][key][metric]['ratio'] for r in a['comparisons']['backtracking']['rounds']]
  lines.append(f"| {case}-pressure {metric} | {vs[0]:.6f} | {vs[1]:.6f} | {math.sqrt(vs[0]*vs[1]):.6f} |")
lines+=['','FFI consistently retires fewer instructions (−1.56% paired). Branch pressure consistently increases (+0.439% paired). Integer pressure is nearly flat (+0.0569%), with opposite round signs; its main-kernel static code and transport counts do not change. These measured regressions remain visible rather than being hidden by pooled CPU improvements.','',
'| Backtracking static metric | Baseline | Candidate |','|---|---:|---:|',
'| FFI code bytes | 1344 | 1312 |','| FFI spills / reloads | 60 / 57 | 56 / 55 |','| FFI IR copies / blocks | 20 / 8 | 20 / 6 |','| FFI frame / spill bytes | 304 / 280 | 304 / 280 |',
'| Branch code bytes | 1264 | 1280 |','| Branch spills / reloads / blocks | 31 / 31 / 8 | 31 / 32 / 10 |',
'| Integer code bytes | 576 | 576 |','| Integer spills / reloads | 25 / 25 | 25 / 25 |','',
'FFI reports exactly two delegated entry reloads; other allocation counters agree. The change removes four stores, two reloads and two edge blocks without changing register allocation. The branch case instead adds one reload and two edge blocks; this is a genuine transport-placement tradeoff requiring separate policy judgment.','',
'## Default bootstrap context','',
'Contemporary baseline wall time is 190.485 s; candidate is 161.490 s. Last sampled retired instructions are 1,801,823,263,167 and 1,798,440,724,358 respectively (only about −0.188%). Execution rate rises from 9.535 to 11.241 billion instructions per CPU-second. The large wall-time difference is therefore predominantly an execution-rate difference, not evidence of a comparable compiler-work reduction. PID counter snapshots can slightly precede process exit. Default bootstrap and image verification are separate from the selected allocator timings.','',
'## Reproduction and archive','',
'`collect.py` reads only completed artifacts from the original two worktrees, asserts provenance/scope/output/counter invariants, and writes only this evidence directory. `report.py` renders this report from `audit.json`. `queue-driver.py` is an archived copy of the parent-owned queue, not an active driver. The compressed JSONL/logs preserve raw scope, timing, code and allocator counters; statuses retain commands, source revisions and policy results. Source guards and preparation records are archived separately. No Factor process, compiler source change, or benchmark-driver change was made by this audit.','']
(P/'RESULTS.md').write_text('\n'.join(lines))
