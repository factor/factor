#!/usr/bin/env python3
import argparse,gzip,hashlib,io,json,statistics,subprocess,tarfile
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('case',choices=['residency','class-info']);a=p.parse_args()
HERE=Path(__file__).resolve().parent;OUT=HERE/a.case;BASE='/home/erg/factor-compiler-next-final-c6948-20260909';CAND='/home/erg/factor-compiler-next2-'+a.case+'-20260909';REL='reference/allocator-speed-crossarch-20260908';NEXT='reference/compiler-next-20260909'
def fetch(root,names,out):
 out.mkdir(parents=True,exist_ok=True)
 raw=subprocess.check_output(['ssh','agent1','tar -C '+root+' -cf - '+' '.join(names)])
 with tarfile.open(fileobj=io.BytesIO(raw)) as t:
  files={m.name:t.extractfile(m).read() for m in t if m.isfile()}
 for n,b in files.items():
  f=out/n;f.parent.mkdir(parents=True,exist_ok=True)
  if f.suffix in ['.log','.jsonl']:f.with_name(f.name+'.gz').write_bytes(gzip.compress(b,mtime=0))
  else:f.write_bytes(b)
 return files
labels=['baseline-1','candidate-1','candidate-2','baseline-2'];f=fetch('/home/erg/compiler-next2-'+a.case+'-20260909',[n+e for n in labels+['focused-unit'] for e in ['.jsonl','.log','.status.json']]+['queue.log','static-equivalence.json','run-'+a.case+'.py'],OUT/'runs')
rows={};scopes={};cost={}
for n in labels:
 st=json.loads(f[n+'.status.json']);assert st['ok'] and st['exit_code']==0 and st['nice']==0 and st['command'][:3]==['taskset','-c','2'] and 'cap_perfmon=ep' in st['capability']
 rows[n]=list(map(json.loads,f[n+'.jsonl'].splitlines()));assert [x['kind'] for x in rows[n]]==['scope','compile'];scopes[n],cost[n]=rows[n]
 assert scopes[n]['checked'] is False and scopes[n]['options']=={'rematerialize_constants':a.case=='residency','backtracking_loop_spills':a.case=='residency','gvn':False}
assert all(scopes[n]['words']==scopes['baseline-1']['words'] for n in labels)
helper=':pressure-victims' if a.case=='residency' else ':<class-info>'
selected=[w for w in scopes['baseline-1']['words'] if w.split('|')[0].endswith(helper)];assert len(selected)==1
static=json.loads(f['static-equivalence.json']);assert static['static_reports_identical'] and static['scope_identical']
for v,root in [('baseline',BASE),('candidate',CAND)]:
 fetch(root+'/'+REL,['source-expected.json','source-manifest.json'],OUT/v/'source')
 checked='corrected-check-chordal-1' if v=='baseline' and a.case=='residency' else a.case+'-check-'+('chordal' if a.case=='residency' else 'linear-scan')+'-1'
 checkedf=fetch(root+'/'+REL,[checked+e for e in ['.log','.jsonl','.status.json']],OUT/v/'checked')
 st=json.loads(checkedf[checked+'.status.json']);assert st['ok'] and st['exit_code']==0
 cr=list(map(json.loads,checkedf[checked+'.jsonl'].splitlines()));assert len([r for r in cr if r['kind']=='runtime'])==26 and next(r for r in cr if r['kind']=='scope')['words']==scopes['baseline-1']['words']
 fetch(root+'/'+NEXT,[a.case+'-compile-only.factor'],OUT/v/'scripts')
 if v=='candidate':fetch(root+'/'+NEXT,['prepare-'+a.case+'.factor',a.case+'-prepare.status.json',a.case+'-prepare.log',a.case+'-unit.factor'],OUT/v/'preparation')
ratios={k:statistics.mean(cost[n][k] for n in ['candidate-1','candidate-2'])/statistics.mean(cost[n][k] for n in ['baseline-1','baseline-2']) for k in ['instructions','cpu_seconds','ns']}
pairs=[{k:cost['candidate-'+str(i)][k]/cost['baseline-'+str(i)][k] for k in ratios} for i in [1,2]]
summary={'case':a.case,'source':{v:scopes[v+'-1']['source'] for v in ['baseline','candidate']},'scope_count':len(scopes['baseline-1']['words']),'scope_identical':True,'selected_helper':selected,'static_reports_identical':True,'compile':cost,'candidate_over_baseline':ratios,'per_round':pairs,'runtime_timing_samples':0}
(OUT/'summary.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps(summary,indent=2))
