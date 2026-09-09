#!/usr/bin/env python3
"""Require common frozen source/image/scope and all 30 outputs before timing."""
from pathlib import Path
import argparse,json,gzip,hashlib
p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('--prefix',required=True);a=p.parse_args()
features=['loops','representations','memory','slp'];identities=[];scopes=[];outputs=[];metrics=[];hashes={}
for feature,enabled,label in [('all',False,a.prefix+'-off'),('all',True,a.prefix+'-on')]:
 stem=a.directory/(label+'-check-linear-scan-1');status=json.loads(stem.with_suffix('.status.json').read_text());assert status['ok'] and status['exit_code']==0 and status['final_value_verifier']
 path=stem.with_suffix('.jsonl');raw=path.read_bytes() if path.exists() else gzip.decompress(stem.with_suffix('.jsonl.gz').read_bytes());rows=[json.loads(l) for l in raw.splitlines()]
 assert len(rows)==48
 scope,=[r for r in rows if r['kind']=='scope'];assert scope['allocator']=='linear-scan' and scope['checked']
 expected=dict(gvn=False,rematerialize_constants=False,backtracking_loop_spills=False,features={f:enabled for f in features});assert scope['options']==expected
 identities.append(tuple(status[k] for k in ['source_commit','image_sha256','vm_sha256']));assert scope['source']==status['source_commit']
 scopes.append(scope['words']);run=[r for r in rows if r['kind']=='runtime'];assert len(run)==30 and all(r['trial']==-1 for r in run)
 outputs.append([(r['word'],r['output']) for r in run]);metric=[r for r in rows if r['kind']=='code'];assert len(metric)==16;metrics.append([r['metric-word'] for r in metric]);assert sum(r['kind']=='compile' for r in rows)==1
 hashes[label]=hashlib.sha256(raw).hexdigest()
for values in [identities,scopes,outputs,metrics]:assert all(v==values[0] for v in values)
result={'ok':True,'source_commit':identities[0][0],'image_sha256':identities[0][1],'vm_sha256':identities[0][2],'scope_count':len(scopes[0]),'runtime_cases':30,'metric_targets':16,'checks':2,'outputs':outputs[0],'metric_words':metrics[0],'record_sha256':hashes}
(a.directory/'checked-validation.json').write_text(json.dumps(result,indent=2)+'\n');print('BOTH CONFIGURATIONS MATCH',len(scopes[0]),30,16)
