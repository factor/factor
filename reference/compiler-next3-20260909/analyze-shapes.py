#!/usr/bin/env python3
from pathlib import Path
from collections import Counter,defaultdict
import json,gzip
P=Path(__file__).resolve().parent
raw=gzip.decompress((P/'baseline-native/shape4.log.gz').read_bytes()).decode();assert 'SHAPE-DIAGNOSTIC-COMPLETE: 12 targets' in raw
rows=[]
for l in raw.splitlines():
 try:r=json.loads(l)
 except ValueError:continue
 rows.append(r)
blocks=[r for r in rows if r['kind']=='static-block'];code=[r['report'] for r in rows if r['kind']=='code'];assert len(code)==12
summary=defaultdict(lambda:defaultdict(lambda:{'blocks':0,'loop_blocks':0,'all':Counter(),'loop':Counter()}))
for b in blocks:
 d=summary[b['target']][b['phase']];d['blocks']+=1;d['loop_blocks']+=b['loop-depth']>0
 for insn in b['instructions']:
  d['all'][insn['class']]+=1
  if b['loop-depth']>0:d['loop'][insn['class']]+=1
old=P.parents[1]/'reference/compiler-flags-20260909/native-x86/matrix/native-00-check-linear-scan-1.jsonl.gz';oldrows=[json.loads(l) for l in gzip.decompress(old.read_bytes()).decode().splitlines()];oldcode=[r['report'] for r in oldrows if r['kind']=='code']
def static(report):
 return [{'code-bytes':p['code-bytes'],**{k:v for k,v in p['passes'][-1].items() if k not in ['nanoseconds','pass']}} for p in report['procedures']]
assert [static(c) for c in code]==[static(c) for c in oldcode], 'Diagnostic changed final code sizes/static metrics'
result={'source':'8780b3c0908ba06be2720c5ac0949e3c68b871e4','targets':len(summary),'phase_block_records':len(blocks),'strict_checked':True,'static_final_metrics_equal_retained_baseline':True,'counts_are_static_not_dynamic':True,'summary':summary}
(P/'baseline-shapes.json').write_text(json.dumps(result,indent=2)+'\n')
for w,phases in summary.items():
 p=phases['select-representations'];interesting={k:v for k,v in p['loop'].items() if any(x in k for x in ['box','tagged','integer>','slot','call','dispatch','check'])};print(w,p['loop_blocks'],interesting)
