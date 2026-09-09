from pathlib import Path
import subprocess,tarfile,io,json,gzip,hashlib,statistics,math
OUT=Path('/Users/erg/factor.worktrees/compiler-next-integration/reference/compiler-next-20260909')
REL='reference/allocator-speed-crossarch-20260908';NXT='reference/compiler-next-20260909'
def fetch(root,subdir,names,dest,remote=True):
 dest.mkdir(parents=True,exist_ok=True)
 if remote:
  raw=subprocess.check_output(['ssh','agent1','tar -C '+root+'/'+subdir+' -cf - '+' '.join(names)])
  with tarfile.open(fileobj=io.BytesIO(raw)) as t:
   files={m.name:t.extractfile(m).read() for m in t if m.isfile()}
  assert set(files)==set(names)
 else:files={n:(Path(root)/subdir/n).read_bytes() for n in names}
 for n,data in files.items():
  if n.endswith(('.jsonl','.log')):(dest/(n+'.gz')).write_bytes(gzip.compress(data,mtime=0))
  else:(dest/n).write_bytes(data)
 return files
def getrows(files,name):
 status=json.loads(files[name+'.status.json']);assert status.get('ok') and status['exit_code']==0,(name,status)
 return [json.loads(s) for s in files[name+'.jsonl'].splitlines()]
def gm(xs):return math.exp(statistics.mean(map(math.log,xs)))
def compile_ratios(base,cand):return {k:statistics.mean(r[k] for r in cand)/statistics.mean(r[k] for r in base) for k in ['cpu_seconds','instructions','ns']}
def strip(x):
 if isinstance(x,dict):return {k:strip(v) for k,v in x.items() if 'nanoseconds' not in k}
 if isinstance(x,list):return list(map(strip,x))
 return x
if __name__=='__main__':
 import sys
 name=sys.argv[1];base='/home/erg/factor-compiler-next-greedy-baseline-20260909';cand='/home/erg/factor-compiler-next-'+name+'-20260909';out=OUT/('native-'+name)
 results={}
 for v,root in [('baseline',base),('candidate',cand)]:
  if name in ['algebra','chordal']:
   names=['isolated-'+name+'-'+v+'-'+str(i) for i in [1,2]];sub=NXT
  else:
   names=['isolated-backtracking-'+v+'-timing-backtracking-'+str(i) for i in [1,2]];sub=REL
  files=fetch(root,sub,[n+e for n in names for e in ['.jsonl','.status.json','.log']],out/v)
  results[v]=[getrows(files,n) for n in names]
 scopes={v:[next(r for r in rs if r['kind']=='scope') for rs in runs] for v,runs in results.items()}
 for v,ss in scopes.items():assert ss[0]['words']==ss[1]['words']
 comp={v:[next(r for r in rs if r['kind']=='compile') for rs in runs] for v,runs in results.items()}
 summary=dict(accepted=True,compile=comp,compile_candidate_over_baseline=compile_ratios(comp['baseline'],comp['candidate']),scope_words={v:len(ss[0]['words']) for v,ss in scopes.items()})
 if name=='backtracking':
  runtime={v:{} for v in results};oracle={}
  for v,runs in results.items():
   for rs in runs:
    rr=[r for r in rs if r['kind']=='runtime'];assert len(rr)==104
    for r in rr:
     if r['word'] in oracle:assert oracle[r['word']]==r['output']
     oracle[r['word']]=r['output']
     if r['trial']>=0:runtime[v].setdefault(r['word'],[]).append(r)
  ratios={w:{k:statistics.mean(r[k] for r in runtime['candidate'][w])/statistics.mean(r[k] for r in runtime['baseline'][w]) for k in ['cpu_seconds','instructions','ns']} for w in runtime['baseline']}
  summary['runtime_candidate_over_baseline']=ratios
  summary['runtime_geomean']={k:gm(x[k] for x in ratios.values()) for k in ['cpu_seconds','instructions','ns']}
 (out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps(summary,indent=2))
