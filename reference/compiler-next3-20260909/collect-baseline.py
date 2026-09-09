#!/usr/bin/env python3
from pathlib import Path
import subprocess,io,tarfile
P=Path(__file__).resolve().parent;D=P/'baseline-native';D.mkdir(exist_ok=True)
remote=r'''
from pathlib import Path
import sys,tarfile,io,gzip
R=Path('/home/erg/factor-compiler-next3-baseline-20260909');P=R/'reference/compiler-next3-20260909'
files=list(P.glob('*'))+[R/'reference/allocator-speed-crossarch-20260908/source-manifest.json']
with tarfile.open(fileobj=sys.stdout.buffer,mode='w|') as t:
 for p in files:
  if not p.is_file():continue
  b=p.read_bytes();name=p.name
  if p.suffix=='.log':b=gzip.compress(b,mtime=0);name+='.gz'
  i=tarfile.TarInfo(name);i.size=len(b);t.addfile(i,io.BytesIO(b))
'''
b=subprocess.check_output(['ssh','agent1','python3 -'],input=remote.encode())
with tarfile.open(fileobj=io.BytesIO(b)) as t:
 assert all(m.isfile() and '/' not in m.name for m in t.getmembers());t.extractall(D)
print(D)
