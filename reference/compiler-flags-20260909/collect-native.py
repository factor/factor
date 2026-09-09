#!/usr/bin/env python3
"""Collect exact native harness, statuses and compressed raw evidence; never images."""
from pathlib import Path
import subprocess,tarfile,io
P=Path(__file__).resolve().parent;D=P/'native-x86';D.mkdir(exist_ok=True)
script=r'''
from pathlib import Path
import io,tarfile,gzip,sys,json
R=Path('/home/erg/factor-compiler-flags-20260909');P=R/'reference/compiler-flags-20260909';A=Path('/home/erg/factor-compiler-flags-audit-20260909/reference/compiler-flags-20260909')
files=[]
for p in P.iterdir():
 if p.name.startswith('native-') and '-timing-' in p.name and not (P/(p.name.split('.')[0]+'.status.json')).exists():continue
 if p.is_file() and p.suffix in ['.py','.factor','.json','.jsonl','.log'] and (p.name!='timing-queue.log' or 'NATIVE FLAGS TIMING COMPLETE' in p.read_text()):files.append((p,'matrix/'+p.name))
for p in (R/'reference/allocator-speed-crossarch-20260908').glob('source-*.json'):files.append((p,'source/'+p.name))
for name in ['workloads.factor','pressure.factor','counters-linux.c','ffi.c']:
 p=R/'reference/allocator-speed-crossarch-20260908'/name
 if p.exists():files.append((p,'support-source/'+name))
for p in A.rglob('*'):
 if p.is_file() and (p.parent.name=='native-audits' or p.name in ['audit-source.json','run-audits-native.py','audit-queue.log']):files.append((p,'audit/'+str(p.relative_to(A))))
for overlay in json.loads((A/'audit-source.json').read_text())['overlays']:
 for name in overlay['files']:files.append((A.parents[1]/name,'audit/executed-source/'+name))
with tarfile.open(fileobj=sys.stdout.buffer,mode='w|') as t:
 for p,name in files:
  b=p.read_bytes()
  if p.suffix in ['.log','.jsonl']:b=gzip.compress(b,mtime=0);name+='.gz'
  info=tarfile.TarInfo(name);info.size=len(b);t.addfile(info,io.BytesIO(b))
'''
b=subprocess.check_output(['ssh','agent1','python3 -'],input=script.encode())
with tarfile.open(fileobj=io.BytesIO(b)) as t:
 assert all(not m.name.startswith('/') and '..' not in Path(m.name).parts and m.isfile() for m in t.getmembers())
 t.extractall(D)
print(D,flush=True)
