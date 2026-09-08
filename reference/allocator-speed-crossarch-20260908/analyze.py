#!/usr/bin/env python3
"""Check outputs, then compare each candidate allocator to its own baseline."""
import argparse,collections,gzip,importlib.util,json,math,statistics
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('--baseline',default='baseline');p.add_argument('--candidate',default='candidate');p.add_argument('--require-complete',action='store_true');a=p.parse_args()
spec=importlib.util.spec_from_file_location('original',Path(__file__).with_name('original-analysis.py'));original=importlib.util.module_from_spec(spec);spec.loader.exec_module(original)
results=collections.defaultdict(list)
scopes={}
outputs={}
failures=[]
for path in sorted(a.directory.glob('*.jsonl*')):
 name=path.name
 if not any(name.startswith(x+'-') for x in (a.baseline,a.candidate)): continue
 label=next(x for x in (a.baseline,a.candidate) if name.startswith(x+'-'))
 status_path=path.with_name(name.removesuffix('.gz').removesuffix('.jsonl')+'.status.json')
 if status_path.exists():
  status=json.loads(status_path.read_text())
  if not status.get('ok',False):
   failures.append(dict(file=name,status=status));continue
 with (gzip.open(path,'rt') if path.suffix=='.gz' else path.open()) as f: records=[json.loads(line) for line in f]
 scope=next(x for x in records if x['kind']=='scope');allocator=scope['allocator']
 # Anonymous words use a frozen object index as well as a label.
 scope_words=scope['words']
 if label in scopes: assert scopes[label]==scope_words,(name,'scope changed')
 scopes[label]=scope_words
 current={r['word']:r['output'] for r in records if r['kind']=='runtime'}
 assert len(current)==26,(name,'missing workload')
 for r in records:
  if r['kind']=='runtime':
   assert r['output']==current[r['word']],(name,r['word'],'nondeterministic output')
   if r['word'] in outputs: assert outputs[r['word']]==r['output'],(name,r['word'],'cross-run mismatch')
   outputs[r['word']]=r['output']
 original.independently_check({k:v for k,v in current.items() if k.rsplit(':',1)[-1] in original.WORKLOADS})
 if not scope['checked']:results[(label,allocator)].extend(records)
summary=dict(failed_runs=failures,scope_words={k:len(v) for k,v in scopes.items()},correctness='All captured outputs agree; original independent checks passed and six pressure checks assert in Factor.',allocators={})
metrics=('cpu_seconds','ns','instructions')
for allocator in original.ALLOCATORS:
 b=results[(a.baseline,allocator)];c=results[(a.candidate,allocator)]
 if a.require_complete:assert b and c,(allocator,'missing baseline/candidate')
 if not b or not c:continue
 report=dict(compile={},workloads={},code={})
 for metric in metrics:
  bv=statistics.median(x[metric] for x in b if x['kind']=='compile');cv=statistics.median(x[metric] for x in c if x['kind']=='compile')
  report['compile'][metric]=dict(baseline=bv,candidate=cv,ratio=cv/bv)
 for word in outputs:
  wr={}
  for metric in metrics:
   vals=[]
   for records in (b,c):
    vals.append([r[metric]/r.get('iterations',1) for r in records if r['kind']=='runtime' and r['word']==word and r['trial']>=0])
   if a.require_complete:assert all(len(v)>=3 for v in vals),(allocator,word,'fewer than3 samples')
   if not all(vals):continue
   bv,cv=map(statistics.median,vals)
   wr[metric]=dict(baseline=bv,candidate=cv,ratio=cv/bv,samples=list(map(len,vals)))
  report['workloads'][word]=wr
 report['runtime_geomean']={metric:math.exp(statistics.mean(math.log(x[metric]['ratio']) for x in report['workloads'].values())) for metric in metrics}
 for records,label in ((b,'baseline'),(c,'candidate')):
  code={}
  for code_index,r in enumerate(x for x in records if x['kind']=='code'):
   if r['kind']!='code':continue
   v=r['report'];values=collections.Counter()
   for procedure in v['procedures']:
    values['code-bytes']+=procedure['code-bytes']
    final=procedure['passes'][-1]
    for k in ('spills','reloads','copies','spill-bytes','frame-bytes','instructions','blocks'):values[k]+=final[k]
   code[f"{v['input']}|{code_index % 12}"]=dict(values)
  report['code'][label]=code
 summary['allocators'][allocator]=report
(a.directory/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps({k:v for k,v in summary.items() if k!='allocators'},indent=2))
for allocator,r in summary['allocators'].items():print(allocator,'runtime',r['runtime_geomean'],'compile',{k:v['ratio'] for k,v in r['compile'].items()})
lines=['# Same-host candidate / baseline allocator comparison','',summary['correctness'],'',
       'Ratios below1 favor the candidate. Runtime aggregates equally weight26 workloads and use per-workload medians; warmups and checked runs are excluded. Each allocator is compared with its own baseline implementation.','',
       '| Allocator | Runtime CPU | Runtime instructions | Compile CPU | Compile instructions |','|---|---:|---:|---:|---:|']
for allocator,r in summary['allocators'].items():
 lines.append(f"| {allocator} | {r['runtime_geomean']['cpu_seconds']:.4f} | {r['runtime_geomean']['instructions']:.4f} | {r['compile']['cpu_seconds']['ratio']:.4f} | {r['compile']['instructions']['ratio']:.4f} |")
if failures:
 lines+=['','Failed runs retained and excluded from ratios:']
 for failure in failures:lines.append(f"- `{failure['file']}`: exit {failure['status']['exit_code']}.")
for allocator,r in summary['allocators'].items():
 lines+=['',f'## {allocator}','', '| Workload | CPU ratio | Retired ratio | Samples before / after |','|---|---:|---:|---:|']
 for word,v in r['workloads'].items():
  lines.append(f"| {word.rsplit(':',1)[-1]} | {v['cpu_seconds']['ratio']:.4f} | {v['instructions']['ratio']:.4f} | {' / '.join(map(str,v['cpu_seconds']['samples']))} |")
 lines+=['','| Kernel / index | Code bytes before → after | Spills before → after | Reloads before → after | Copies before → after |','|---|---:|---:|---:|---:|']
 for word,b in r['code']['baseline'].items():
  c=r['code']['candidate'][word]
  lines.append('| '+word+' | '+' | '.join(f'{b[k]} → {c[k]}' for k in ('code-bytes','spills','reloads','copies'))+' |')
(a.directory/'summary.md').write_text('\n'.join(lines).replace('below1','below 1').replace('weight26','weight 26')+'\n')
