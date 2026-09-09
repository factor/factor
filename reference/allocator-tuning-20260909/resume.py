#!/usr/bin/env python3
"""Resume after an orchestration failure, verifying every skipped accepted run."""
import argparse,json,subprocess
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('plan',type=Path);p.add_argument('--completed',type=int,required=True)
a=p.parse_args();plan=[json.loads(x) for x in a.plan.read_text().splitlines()]
assert len(plan)==16 and 0<=a.completed<16
for index,run in enumerate(plan):
 command=run['command'];root=Path(run['cwd'])
 if index<a.completed:
  allocator=command[command.index('--allocator')+1]
  ordinal=int(command[command.index('--round-offset')+1])+1
  name=command[2]+'-timing-'+allocator+'-'+str(ordinal)
  out=root/'reference/allocator-speed-crossarch-20260908'
  status=json.loads((out/(name+'.status.json')).read_text())
  source=(root/'.allocator-source-commit').read_text().strip()
  assert status['ok'] and status['exit_code']==0 and status['source_commit']==source
  rows=[json.loads(x) for x in (out/(name+'.jsonl')).read_text().splitlines()]
  scope=next(x for x in rows if x['kind']=='scope')
  assert scope['source']==source and scope['allocator']==allocator and not scope['checked']
  assert scope['options']=={'rematerialize_constants':True,'backtracking_loop_spills':True,'gvn':False}
  assert len(rows)==118
  print('RETAIN',name,flush=True)
 else:subprocess.run(command,cwd=root,check=True)
