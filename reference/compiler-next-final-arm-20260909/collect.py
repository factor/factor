#!/usr/bin/env python3
"""Read completed ARM queue artifacts; write this evidence directory only."""
import gzip, hashlib, json, math, statistics, collections, subprocess
from pathlib import Path
OUT=Path(__file__).resolve().parent
ROOTS={'baseline':Path('/Users/erg/factor.worktrees/compiler-next-comparison'), 'candidate':Path('/Users/erg/factor.worktrees/compiler-next-integration')}
REL=Path('reference/allocator-speed-crossarch-20260908'); NEXT=Path('reference/compiler-next-20260909')
REVISIONS={'baseline':'c1f7e4d34cd604bbdf22576b237406b39758896d','candidate':'a7f554b613bd763fb7fbfc520643b75b321a6e16'}
def dump(p,x):p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(x,indent=2,sort_keys=True)+'\n')
def archive(src,dst):
 if src.exists() and not dst.exists():
  dst.parent.mkdir(parents=True,exist_ok=True)
  if dst.suffix=='.gz':dst.write_bytes(gzip.compress(src.read_bytes(),mtime=0))
  else:dst.write_bytes(src.read_bytes())
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def clean(x):
 if isinstance(x,dict):return {k:clean(v) for k,v in x.items() if k not in ['nanoseconds','codegen-nanoseconds','frontend-nanoseconds']}
 if isinstance(x,list):return [clean(v) for v in x]
 return x
def geo(xs):return math.exp(statistics.mean(map(math.log,xs)))
def records(p):return [json.loads(x) for x in p.read_text().splitlines()]
audit={'scope':'Targeted final ARM backtracking timing; all-four full-compiler suites, backtracking/chordal checked closures, not all-four timing.', 'sources':{},'runs':{},'pending':[],'comparisons':{}}
data={};outputs={};scopes={};code={}
old_candidate='c6948a99de5ebfb7251c322382dba66d6f8050df'
diff=subprocess.check_output(['git','diff','--name-only',old_candidate,REVISIONS['candidate']],cwd=ROOTS['candidate'],text=True).splitlines()
production=[p for p in diff if not p.startswith('reference/') and p!='basis/compiler/cfg/register-allocation/backtracking/backtracking-tests.factor']
assert not production,('production changed; LS gate reuse invalid',production)
assert sha(ROOTS['candidate']/'basis/compiler/cfg/register-allocation/backtracking/backtracking-tests.factor')=='3bc5c4808cb2b1be9b0778b8af23891bad60fc4538706da9a1167065f98fb5ec'
for flag in ['on','off']:assert json.loads((OUT/'fixed-fixture'/flag/'status.json').read_text())['exit_code']==0
audit['reused_linear_scan_suite']={'source':old_candidate,'new_source':REVISIONS['candidate'],'production_identical':True,'changed_paths':diff,'reason':'Only test/doc/evidence changes; original c694 LS suite is reused alongside explicit fixed-fixture both-flag validation.'}

for label,root in ROOTS.items():
 expected=json.loads((root/REL/'source-expected.json').read_text())
 assert expected['source_commit']==REVISIONS[label]
 mismatches=[name for name,digest in expected['files'].items() if not (root/name).exists() or sha(root/name)!=digest]
 assert not mismatches,mismatches
 prepdir=NEXT if label=='baseline' else Path('reference/compiler-next-final-20260909')
 prepname='arm-next-prepare' if label=='baseline' else 'final-prepare'
 prepfile=root/prepdir/(prepname+'.status.json')
 if not prepfile.exists():audit['pending'].append(label+' preparation');continue
 prep=json.loads(prepfile.read_text())
 assert prep['status']==0 and prep['source_commit']==REVISIONS[label]
 assert sha(root/prepdir/'prepared.image')==prep['prepared_image_sha256']
 audit['sources'][label]={'revision':REVISIONS[label], 'guarded_files':len(expected['files']), 'all_hashes_match':True,'prepared_image_hash_matches':True,'prepared_image_sha256':prep['prepared_image_sha256']}
 for src,dest in [(root/REL/'source-expected.json',OUT/label/'source-expected.json.gz'),(root/REL/'source-manifest.json',OUT/label/'source-manifest.json.gz'),(prepfile,OUT/label/'prepare.status.json'),(root/prepdir/(prepname+'.log'),OUT/label/'prepare.log.gz')]:archive(src,dest)
 names=[f'final-{label}-timing-{a}-{r}' for a in ['backtracking'] for r in [1,2]]
 if label=='candidate':names += [f'final-check-{a}-1' for a in ['backtracking','chordal']]
 for name in names:
  statusfile=root/REL/(name+'.status.json')
  if not statusfile.exists():audit['pending'].append(name);continue
  status=json.loads(statusfile.read_text());assert status['ok'] and status['exit_code']==0,(name,status)
  assert status['source_commit']==REVISIONS[label]
  rows=records(root/REL/(name+'.jsonl'));kinds=collections.Counter(r['kind'] for r in rows)
  checked='-check-' in name
  assert kinds=={'scope':1,'compile':1,'code':12,'runtime':26 if checked else 104},(name,kinds)
  scope=next(r for r in rows if r['kind']=='scope');assert scope['source']==REVISIONS[label] and scope['checked']==checked
  assert scope['options']=={'backtracking_loop_spills':True,'gvn':False,'rematerialize_constants':True}
  if checked:assert status['final_value_verifier']
  runtime=[r for r in rows if r['kind']=='runtime'];words=sorted(set(r['word'] for r in runtime));assert len(words)==26
  for word in words:
   rs=[r for r in runtime if r['word']==word]
   assert len(set(r['output'] for r in rs))==1
   assert len(set(r['iterations'] for r in rs))==1
   assert sorted(r['trial'] for r in rs)==([-1] if checked else [-1,0,1,2])
   if word in outputs:assert outputs[word]==rs[0]['output'],(name,word)
   outputs[word]=rs[0]['output']
   for r in rs:assert r['instructions']>0 and r['cpu_seconds']>0 and r['ns']>0
  scopes[name]=scope['words']
  code[name]=[clean(r['report']) for r in rows if r['kind']=='code']
  assert len(code[name])==12
  alloc=scope.get('allocator',status['command'][-6])
  audit['runs'][name]={'checked':checked,'seconds':status['seconds'],'scope_words':len(scope['words']),'scope_sha256':hashlib.sha256(json.dumps(scope['words']).encode()).hexdigest(),'outputs':len(words),'code_reports':12,'counts':dict(kinds),'scope_metadata':{k:v for k,v in scope.items() if k!='words'}}
  data[name]=rows
  for suffix in ['.status.json','.jsonl','.log']:
   archive(root/REL/(name+suffix),OUT/label/(name+suffix+('' if suffix=='.status.json' else '.gz')))
# Printed ordinals shift when new helpers are inserted; compare semantic
# word identities separately, while requiring exact within-source lists.
audit['scope_differences']={}
for label in ROOTS:
 matching=[(n,v) for n,v in scopes.items() if ('baseline' in n)==(label=='baseline')]
 if matching:
  refname,reference=matching[0]
  assert all(v==reference for n,v in matching),('within-source scope changed',label)
  audit['sources'][label]['scope_words']=len(reference)
if scopes:
 b=next((v for n,v in scopes.items() if 'baseline' in n),None)
 c=next((v for n,v in scopes.items() if 'baseline' not in n),None)
 if b is not None and c is not None:
  bn={x.rsplit('|',1)[0] for x in b};cn={x.rsplit('|',1)[0] for x in c}
  added=sorted(cn-bn);removed=sorted(bn-cn)
  assert not removed,('semantic scope entries removed',removed)
  audit['scope_differences']={'candidate':{'baseline_count':len(b),'candidate_count':len(c),'removed':removed,'added':added,'note':'Semantic identities strip only trailing printed ordinal; exact lists match within each source.'}}
for allocator in ['backtracking']:
 rounds=[]
 for ordinal in [1,2]:
  b=f'final-baseline-timing-{allocator}-{ordinal}';c=f'final-candidate-timing-{allocator}-{ordinal}'
  if b not in data or c not in data:continue
  entry={'round':ordinal,'order':'baseline→candidate' if ordinal==1 else 'candidate→baseline','compile':{},'runtime':{},'workloads':{}}
  for metric in ['cpu_seconds','instructions','ns']:
   bv=next(r[metric] for r in data[b] if r['kind']=='compile');cv=next(r[metric] for r in data[c] if r['kind']=='compile')
   entry['compile'][metric]={'baseline':bv,'candidate':cv,'ratio':cv/bv}
  for word in sorted(outputs):
   per={}
   for metric in ['cpu_seconds','instructions','ns']:
    bv=statistics.median(r[metric] for r in data[b] if r['kind']=='runtime' and r['trial']>=0 and r['word']==word)
    cv=statistics.median(r[metric] for r in data[c] if r['kind']=='runtime' and r['trial']>=0 and r['word']==word)
    per[metric]={'baseline':bv,'candidate':cv,'ratio':cv/bv}
   entry['workloads'][word]=per
  for metric in ['cpu_seconds','instructions','ns']:entry['runtime'][metric]=geo(x[metric]['ratio'] for x in entry['workloads'].values())
  entry['ffi_static']={}
  for label,name in [('baseline',b),('candidate',c)]:
   report=next(r for r in code[name] if r['input']=='ffi-pressure');p=report['procedures'][0];entry['ffi_static'][label]={'code_bytes':p['code-bytes'],'allocation':p['allocation'],'final_pass':p['passes'][-1]}
  rounds.append(entry)
 audit['comparisons'][allocator]={'rounds':rounds}
 if len(rounds)==2:
  audit['comparisons'][allocator]['paired_geomean']={kind:{metric:geo(r[kind][metric]['ratio'] if kind=='compile' else r[kind][metric] for r in rounds) for metric in ['cpu_seconds','instructions','ns']} for kind in ['compile','runtime']}
  for label in ROOTS:
   names=[f'final-{label}-timing-{allocator}-{r}' for r in [1,2]]
   assert code[names[0]]==code[names[1]],('static differs across rounds',names)
for allocator in ['linear-scan','greedy','backtracking','chordal']:
 p=Path('/tmp/compiler-next-final-compiler-'+allocator)
 if (p/'status.json').exists():
  st=json.loads((p/'status.json').read_text());assert st['exit_code']==0 and st['source']==(old_candidate if allocator=='linear-scan' else REVISIONS['candidate'])
  for fname in ['status.json','output.log']:archive(p/fname,OUT/'full-compiler'/allocator/(fname+('.gz' if fname.endswith('.log') else '')))
 else:audit['pending'].append('full compiler '+allocator)
for label,dirname in [('candidate','compiler-next-final-bootstrap'),('baseline','compiler-next-baseline-bootstrap')]:
 p=Path('/tmp')/dirname
 if (p/'status.json').exists():
  for fname in ['status.json','output.log']:archive(p/fname,OUT/'bootstrap'/label/(fname+('.gz' if fname.endswith('.log') else '')))
for script,marker in [('callback-matrix.factor','CALLBACK-MATRIX-COMPLETE'),('moving-gc.factor','MOVING-GC-MATRIX-COMPLETE')]:
 p=ROOTS['candidate']/'reference/allocator-tuning-20260909';status=p/(script+'.status.json')
 if status.exists() and json.loads(status.read_text()).get('source_commit')==REVISIONS['candidate']:
  st=json.loads(status.read_text());assert st['ok'] and st['exit_code']==0 and marker in (p/(script+'.log')).read_text()
  for suffix in ['.status.json','.log']:archive(p/(script+suffix),OUT/'gates'/(script+suffix+('.gz' if suffix=='.log' else '')))
 else:audit['pending'].append(script)
for label,dirname in [('candidate','compiler-next-final-bootstrap'),('candidate-image','compiler-next-final-image-check')]:
 p=Path('/tmp')/dirname
 if not (p/'status.json').exists():audit['pending'].append(dirname)
 else:
  st=json.loads((p/'status.json').read_text());assert st['exit_code']==0 and st['source']==REVISIONS['candidate']
  for fname in ['status.json','output.log']:archive(p/fname,OUT/'bootstrap'/label/(fname+('.gz' if fname.endswith('.log') else '')))
archive(Path('/tmp/compiler-next-final-arm.py'),OUT/'queue-driver.py')
dump(OUT/'audit.json',audit)
print(json.dumps({'completed':len(audit['runs']),'pending':audit['pending'],'scope_differences':{k:{x:y for x,y in v.items() if x!='removed' and x!='added'} for k,v in audit['scope_differences'].items()},'comparisons':{k:v.get('paired_geomean') for k,v in audit['comparisons'].items()}},indent=2))
