#!/usr/bin/env python3
"""Write a concise comparison only after strict collection and ranking succeed."""
import argparse,functools,gzip,json,statistics
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__);p.add_argument('directory',type=Path)
p.add_argument('--architecture',required=True);a=p.parse_args()
def read(name):return json.loads((a.directory/name).read_text())
collection=read('collection.json');summary=read('summary.json')
rank=read('final-rank.json');diagnostics=read('diagnostics.json')
@functools.lru_cache(None)
def runtime_rows(label,allocator,ordinal):
    path=a.directory/(f'{label}-timing-{allocator}-{ordinal}.jsonl.gz')
    return [row for row in map(json.loads,gzip.open(path,'rt'))
            if row['kind']=='runtime' and row['trial']>=0]
def word_rounds(allocator,word):
    result={}
    for ordinal in [1,2]:
        pair=[]
        for label in ['baseline','candidate']:
            rows=[row for row in runtime_rows(label,allocator,ordinal) if row['word']==word]
            pair.append({metric:statistics.median(row[metric]/row['iterations'] for row in rows)
                         for metric in ['cpu_seconds','instructions']})
        result[str(ordinal)]={metric:pair[1][metric]/pair[0][metric] for metric in pair[0]}
    return result
assert collection['accepted'] and collection['measured_batches']==1248
assert not summary['failed_runs'] and len(summary['allocators'])==4
lines=[f'# Completed allocator tuning matrix: {a.architecture}', '',
       f"Compiler baseline `{collection['sources']['baseline']['source_commit']}`; candidate `{collection['sources']['candidate']['source_commit']}`.", '',
       'Six measured runtime batches per workload, revision and allocator come from two fresh processes (three batches each), with reversed source order in round two. Compilation has two observations per revision and allocator. All 26 independent workload answers match. Strict collection accepted 16 timing processes, eight checked closures, 1,248 measured batches and 208 checked outputs. Rematerialization and loop spilling are on; GVN and timing-time verification are off. Separate strict callback and moving-GC gates passed for both revisions.', '',
       f"Frozen closure sizes: baseline {collection['sources']['baseline']['frozen_words']:,}; candidate {collection['sources']['candidate']['frozen_words']:,}. Each selected allocator recompiles the complete saved word-object sequence within its revision, including newly introduced compiler helpers. Matching initial image and VM provenance is retained in `../../gates/` and the experiment's asset records.", '',
       'All ratios below are candidate/reference; lower is better. Runtime aggregates equally weight the 26 workload ratios using a geometric mean. Compile ratios use the median whole-closure observation.', '',
       '## Each allocator versus its own pre-tuning baseline', '',
       '| Allocator | Runtime CPU | Runtime retired | Compile CPU | Compile retired |',
       '|---|---:|---:|---:|---:|']
for allocator,data in summary['allocators'].items():
    values=[data['runtime_geomean'][m] for m in ['cpu_seconds','instructions']]
    values += [data['compile'][m]['ratio'] for m in ['cpu_seconds','instructions']]
    lines.append('| '+allocator+' | '+' | '.join(f'{x:.4f}' for x in values)+' |')
lines+=['','## Final allocators versus final linear scan','','| Allocator | Runtime CPU | Runtime retired | Compile CPU | Compile retired |','|---|---:|---:|---:|---:|']
for allocator,data in rank['allocators'].items():
    values=[data[k][m] for k,m in [('runtime','cpu_seconds'),('runtime','instructions'),('compile','cpu_seconds'),('compile','instructions')]]
    lines.append('| '+allocator+' | '+' | '.join(f'{x:.4f}' for x in values)+' |')
lines+=['','## Repaired pressure cases in the full matrix','','| Allocator / workload | Runtime CPU / own baseline | Retired / own baseline | Code bytes before → after |','|---|---:|---:|---:|']
for allocator,word in [('greedy','integer-pressure'),('backtracking','ffi-pressure'),('chordal','branch-pressure')]:
    data=summary['allocators'][allocator]
    workload=data['workloads']['allocator-runtime-comparison:'+word+'-work']
    keys=[k for k in data['code']['baseline'] if k.split('|',1)[0]==word]
    code='see summary.json'
    if len(keys)==1:
        key=keys[0];code=str(data['code']['baseline'][key]['code-bytes'])+' → '+str(data['code']['candidate'][key]['code-bytes'])
    lines.append(f"| {allocator} / {word} | {workload['cpu_seconds']['ratio']:.4f} | {workload['instructions']['ratio']:.4f} | {code} |")
worst={}
lines+=['','## Largest remaining own-baseline deltas','','The table includes the two highest CPU ratios and two highest retired-instruction ratios for each alternative allocator (deduplicated). Per-round CPU ratios distinguish repeatable changes from isolated execution-rate differences. These are individual workloads; the full 26-workload records remain in `summary.json`.','','| Allocator / workload | CPU / own baseline | Retired / own baseline | CPU round 1 / round 2 |','|---|---:|---:|---:|']
for allocator in ['greedy','backtracking','chordal']:
    workloads=summary['allocators'][allocator]['workloads']
    names=set()
    for metric in ['cpu_seconds','instructions']:
        names.update(sorted(workloads,key=lambda word:workloads[word][metric]['ratio'],reverse=True)[:2])
    worst[allocator]={}
    for word in sorted(names):
        values={metric:workloads[word][metric]['ratio'] for metric in ['cpu_seconds','instructions']}
        values['rounds']=word_rounds(allocator,word)
        worst[allocator][word]=values
        lines.append(f"| {allocator} / {word.split(':')[-1]} | {values['cpu_seconds']:.4f} | {values['instructions']:.4f} | {values['rounds']['1']['cpu_seconds']:.4f} / {values['rounds']['2']['cpu_seconds']:.4f} |")
(a.directory/'largest-deltas.json').write_text(json.dumps(worst,indent=2)+'\n')
lines+=['','## Execution-rate limits and retained evidence','',
    f"The host's one-minute load ranged from {diagnostics['host_load_1m_min']:.2f} to {diagnostics['host_load_1m_max']:.2f} (median {diagnostics['host_load_1m_median']:.2f}). `diagnostics.md` records per-process CPU/wall ratios and retired instructions per CPU second; `diagnostics.json` also retains final allocator/linear-scan ratios separately for each round. Small CPU-only differences require that execution-rate context. Six batches from two processes do not provide six independent process replications.", '',
    'Final machine-IR spill/reload/copy counts are static opcode counts, not emitted movement instructions or dynamic events. Equal-register copies can emit no instruction. Generated code bytes are actual machine-code bytes; retired counts measure actual execution. Targeted emitted-store provenance and disassembly are retained separately for the greedy repair.', '',
    'Raw JSONL data is gzip-compressed with exact status records. `collection.json` records source identities, roots and every accepted command; source manifests cover the compiler, architecture, alien core and VM trees. `summary.json` contains every workload and code metric, own-baseline ratios and both rounds. `final-rank.json` ranks the final source against its own linear scan. These measurements do not change default policy or establish the separate cold-bootstrap budget.']
(a.directory/'README.md').write_text('\n'.join(lines)+'\n')
