#!/usr/bin/env python3
"""Cross-configuration gate: exact selected scope and language outputs."""
from pathlib import Path
import hashlib,json
P=Path(__file__).resolve().parent;ROOT=P.parents[1]
source=(ROOT/'.allocator-source-commit').read_text().strip();image=hashlib.sha256((P/'prepared.image').read_bytes()).hexdigest()
scopes=[];outputs=[];inputs={}
for config in ['00','10','01','11']:
 label='native-'+config+'-check-linear-scan-1';status=json.loads((P/(label+'.status.json')).read_text());assert status['ok'] and status['exit_code']==0 and status['final_value_verifier'] and status['source_commit']==source and status['image_sha256']==image
 rr=list(map(json.loads,(P/(label+'.jsonl')).read_text().splitlines()));scope,=[r for r in rr if r['kind']=='scope'];assert scope['checked'] and scope['allocator']=='linear-scan' and scope['source']==source and scope['options']=={'gvn':config[0]=='1','rematerialize_constants':config[1]=='1','backtracking_loop_spills':False}
 run=[r for r in rr if r['kind']=='runtime'];assert len(run)==26 and all(r['trial']==-1 for r in run)
 scopes.append(scope['words']);outputs.append([(r['word'],r['output']) for r in run]);inputs[label]={e:hashlib.sha256((P/(label+e)).read_bytes()).hexdigest() for e in ['.status.json','.jsonl']}
assert all(s==scopes[0] for s in scopes) and all(o==outputs[0] for o in outputs)
required=['compiler.cfg.value-numbering:value-numbering','compiler.cfg.value-numbering.global:global-value-numbering','compiler.cfg.register-allocation.rematerialization:emit-rematerialization']
names={w.rsplit('|',1)[0] for w in scopes[0]};assert all(w in names for w in required)
result={'ok':True,'source':source,'image_sha256':image,'scope_count':len(scopes[0]),'language_outputs':outputs[0],'required_selected_helpers':required,'inputs':inputs}
(P/'checked-validation.json').write_text(json.dumps(result,indent=2)+'\n');print('CHECKED CONFIGURATIONS MATCH',len(scopes[0]),len(outputs[0]))
