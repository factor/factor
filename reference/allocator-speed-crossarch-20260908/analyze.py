#!/usr/bin/env python3
"""Check outputs, then compare each candidate allocator to its own baseline."""
import argparse,collections,gzip,importlib.util,json,math,statistics
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('--baseline',default='baseline');p.add_argument('--candidate',default='candidate');a=p.parse_args()
spec=importlib.util.spec_from_file_location('original',Path(__file__).with_name('original-analysis.py'));original=importlib.util.module_from_spec(spec);spec.loader.exec_module(original)
results=collections.defaultdict(list)
scopes={}
outputs={}
for path in sorted(a.directory.glob('*.jsonl*')):
 name=path.name
 if not any(name.startswith(x+'-') for x in (a.baseline,a.candidate)): continue
 label=next(x for x in (a.baseline,a.candidate) if name.startswith(x+'-'))
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
summary=dict(scope_words={k:len(v) for k,v in scopes.items()},correctness='All captured outputs agree; original independent checks passed and six pressure checks assert in Factor.',allocators={})
metrics=('cpu_seconds','ns','instructions')
for allocator in original.ALLOCATORS:
 b=results[(a.baseline,allocator)];c=results[(a.candidate,allocator)]
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
