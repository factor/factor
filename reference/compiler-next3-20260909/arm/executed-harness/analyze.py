#!/usr/bin/env python3
"""Validate isolated feature records, retain all cases, and separate corpus/witnesses."""
from pathlib import Path
import argparse,gzip,json,math,statistics
p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('--prefix',required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--old-baseline-record',type=Path);p.add_argument('--protocol',choices=['shared','individual'],default='shared');a=p.parse_args()
features=['loops','representations','memory','slp'];metrics=['instructions','cpu_seconds','ns'];identity=None;scope_words=None;language=None;metric_ids=None;measured=0

def read_rows(path):
 if not path.exists():path=Path(str(path)+'.gz')
 raw=path.read_bytes();raw=gzip.decompress(raw) if path.suffix=='.gz' else raw
 return [json.loads(l) for l in raw.splitlines()]

def static(report):
 return [{'code-bytes':p['code-bytes'],'allocation':p.get('allocation',{}),'passes':[{k:v for k,v in q.items() if k!='nanoseconds'} for q in p['passes']]} for p in report['procedures']]

def final_static(report):
 return [{'code-bytes':p['code-bytes'],**{k:v for k,v in p['passes'][-1].items() if k not in ['nanoseconds','pass']}} for p in report['procedures']]

def read(label,feature,enabled,mode,ordinal):
 global identity,scope_words,language,metric_ids,measured
 stem=a.directory/f'{label}-{mode}-linear-scan-{ordinal}';status=json.loads(stem.with_suffix('.status.json').read_text());assert status['ok'] and status['exit_code']==0,stem
 current=tuple(status[k] for k in ['source_commit','image_sha256','vm_sha256'])
 if identity is None:identity=current
 assert current==identity,('source/image/VM mismatch',stem)
 rows=read_rows(stem.with_suffix('.jsonl'));assert len(rows)==(48 if mode=='check' else 138),stem
 scope,=[r for r in rows if r['kind']=='scope'];assert scope['source']==identity[0] and scope['allocator']=='linear-scan' and scope['checked']==(mode=='check')
 assert scope['options']==dict(gvn=False,rematerialize_constants=False,backtracking_loop_spills=False,features={f:enabled and f==feature for f in features})
 if scope_words is None:scope_words=scope['words']
 assert scope['words']==scope_words,('different selected words',stem)
 compile_row,=[r for r in rows if r['kind']=='compile'];runtime=[r for r in rows if r['kind']=='runtime'];code=[r for r in rows if r['kind']=='code'];assert len(code)==16 and len(runtime)==(30 if mode=='check' else 120)
 warm=[r for r in runtime if r['trial']==-1];assert len(warm)==30
 answers=[(r['word'],r['output']) for r in warm]
 if language is None:language=answers
 assert answers==language,('different language outputs',stem)
 expected=dict(language)
 for r in runtime:assert r['word'] in expected and r['output']==expected[r['word']] and r['instructions']>0 and r['cpu_seconds']>0
 ids=[r['metric-word'] for r in code]
 if metric_ids is None:metric_ids=ids
 assert ids==metric_ids and len(set(ids))==16,('metric target identity',stem)
 by_word={}
 if mode=='timing':
  for word,_ in language:
   samples=[r for r in runtime if r['word']==word and r['trial']>=0];assert sorted(r['trial'] for r in samples)==[0,1,2]
   assert len({r['iterations'] for r in samples})==1
   by_word[word]={m:statistics.median(r[m] for r in samples) for m in metrics};by_word[word]['iterations']=samples[0]['iterations'];measured+=len(samples)
 return {'status':status,'compile':compile_row,'runtime':by_word,'code':{r['metric-word']:r['report'] for r in code}}

checked={'off':read(a.prefix+'-baseline','loops',False,'check',1)}
for f in features:checked[f]=read(a.prefix+'-'+f+'-on',f,True,'check',1)
old_equal=None
if a.old_baseline_record:
 old=[r['report'] for r in read_rows(a.old_baseline_record) if r['kind']=='code'];new=list(checked['off']['code'].values())[:12];assert len(old)==12
 old_equal=[final_static(r) for r in old]==[final_static(r) for r in new];assert old_equal,'Default-off first12 final static reports changed'

def geo(values):return math.exp(statistics.mean(math.log(x) for x in values))

corpus=[w for w,_ in language[:26]];witnesses=[w for w,_ in language[26:]];assert len(set(corpus+witnesses))==30
results={};observations={}
shared_off=[read(a.prefix+'-baseline','loops',False,'timing',i) for i in [1,2]] if a.protocol=='shared' else None
for f in features:
 runs={'off':shared_off if shared_off is not None else [read(a.prefix+'-'+f+'-off',f,False,'timing',i) for i in [1,2]],'on':[read(a.prefix+'-'+f+'-on',f,True,'timing',i) for i in [1,2]]};observations[f]=runs
 equal={};checked_equal={}
 for s in ['off','on']:
  equal[s]=all(static(runs[s][0]['code'][w])==static(runs[s][1]['code'][w]) for w in metric_ids);assert equal[s],('Static metrics differ across rounds',f,s)
  expected=checked[f if s=='on' else 'off']['code']
  checked_equal[s]=all(final_static(runs[s][0]['code'][w])==final_static(expected[w]) for w in metric_ids)
  assert checked_equal[s],('Timing final static metrics differ from checked state',f,s)
 rounds=[]
 for i in [0,1]:
  off,on=runs['off'][i],runs['on'][i]
  cases={w:{m:on['runtime'][w][m]/off['runtime'][w][m] for m in metrics} for w,_ in language}
  assert all(on['runtime'][w]['iterations']==off['runtime'][w]['iterations'] for w,_ in language)
  rounds.append({'compile':{m:on['compile'][m]/off['compile'][m] for m in metrics},'corpus_geomean':{m:geo(cases[w][m] for w in corpus) for m in metrics},'per_case':cases})
 per_case={w:{m:geo(r['per_case'][w][m] for r in rounds) for m in metrics} for w,_ in language}
 results[f]={'rounds':rounds,'compile_geomean':{m:geo(r['compile'][m] for r in rounds) for m in metrics},'corpus_geomean':{m:geo(r['corpus_geomean'][m] for r in rounds) for m in metrics},'witnesses':{w:per_case[w] for w in witnesses},'per_case':per_case,'static_equal_across_rounds':equal,'final_static_matches_checked':checked_equal,'final_static':{s:{w:final_static(runs[s][0]['code'][w]) for w in metric_ids} for s in ['off','on']}}
assert measured==(900 if a.protocol=='shared' else 1440)
result={'accepted':True,'source_commit':identity[0],'image_sha256':identity[1],'vm_sha256':identity[2],'checked_processes':5,'timing_processes':10 if a.protocol=='shared' else 16,'protocol':a.protocol,'shared_off_anchors':a.protocol=='shared','comparisons_correlated':a.protocol=='shared','temporal_order':['off',*features,*reversed(features),'off'] if a.protocol=='shared' else [v for f in features for v in ['off',f,f,'off']],'measured_batches':measured,'scope_count':len(scope_words),'language_outputs_match':True,'corpus_cases':corpus,'witness_cases':witnesses,'metric_ids':metric_ids,'default_off_first12_match_old':old_equal,'all_off_groups_match_checked_baseline':True,'features':results,'observations':observations}
a.output.write_text(json.dumps(result,indent=2)+'\n')
for f,d in results.items():print(f,'compiler',d['compile_geomean'],'corpus26',d['corpus_geomean'],'witnesses',d['witnesses'])
