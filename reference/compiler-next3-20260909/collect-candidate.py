#!/usr/bin/env python3
from pathlib import Path
import subprocess,tarfile,io
P=Path(__file__).resolve().parent;D=P/'candidate-native';D.mkdir(exist_ok=True)
remote=r'''
from pathlib import Path
import io,tarfile,gzip,sys,json
R=Path('/home/erg/factor-compiler-next3-candidate-20260909');P=R/'reference/compiler-next3-20260909'
files=[]
names=['features.factor','witnesses.factor','timing.factor','drive.py','prepare.factor','prepare.py','queue.py','validate-checks.py','combined-corpus-check.factor','run-gate.py','analyze.py','loop-code.factor','loop-code-definitions.factor','candidate-stage.json','final-harness.json','checked-validation.json','final-check-queue.log','final-gate-queue.log']
for p in P.iterdir():
 if p.is_file() and (p.name in names or p.name.startswith('native-')) and p.suffix in ['.py','.factor','.json','.jsonl','.log']:
  if p.name.startswith('native-baseline-') or p.name.startswith('native-prepare.'):continue
  if '-timing-' in p.name and p.name.startswith('native-final-') and not (P/(p.name.split('.')[0]+'.status.json')).exists():continue
  files.append((p,'matrix/'+p.name))
if (P/'timing-queue.log').exists() and 'FEATURE TIMING QUEUE COMPLETE' in (P/'timing-queue.log').read_text():files.append((P/'timing-queue.log','matrix/timing-queue.log'))
for p in (P/'initial-import-warning').iterdir():
 if p.is_file():files.append((p,'initial-import-warning/'+p.name))
for p in (R/'reference/allocator-speed-crossarch-20260908').glob('source-*.json'):files.append((p,'source/'+p.name))
stage=json.loads((P/'candidate-stage.json').read_text())
for name in stage['witness_sources']:files.append((R/name,'staged-witness-sources/'+name))
for name in ['scalar-code.bin','packed-code.bin']:files.append((R/'reference/compiler-next3-vectorization-20260909'/name,'audits/slp/'+name))
if (P/'native-loop-code').exists():
 for p in (P/'native-loop-code').iterdir():
  if p.is_file():files.append((p,'audits/loop-code/'+p.name))
with tarfile.open(fileobj=sys.stdout.buffer,mode='w|') as t:
 for p,name in files:
  if not p.exists():continue
  b=p.read_bytes()
  if p.suffix in ['.log','.jsonl']:b=gzip.compress(b,mtime=0);name+='.gz'
  i=tarfile.TarInfo(name);i.size=len(b);t.addfile(i,io.BytesIO(b))
'''
b=subprocess.check_output(['ssh','agent1','python3 -'],input=remote.encode())
with tarfile.open(fileobj=io.BytesIO(b)) as t:
 assert all(m.isfile() and not m.name.startswith('/') and '..' not in Path(m.name).parts for m in t.getmembers());t.extractall(D)
print(D)
