#!/usr/bin/env python3
"""Copy exact combined native evidence without images or earlier datasets."""
from pathlib import Path
import io,subprocess,tarfile
P=Path(__file__).resolve().parent;out=P/'native-x86';out.mkdir(exist_ok=True)
remote=r'''
from pathlib import Path
import gzip,io,sys,tarfile
r=Path('/home/erg/factor-compiler-combined-20260909');p=r/'reference/compiler-combined-20260909'
files=[(f,'matrix/'+f.name) for f in p.iterdir() if f.is_file() and f.suffix in ['.py','.factor','.json','.jsonl','.log','.md']]
files += [(f,'source/'+f.name) for f in (r/'reference/allocator-speed-crossarch-20260908').glob('source-*.json')]
with tarfile.open(fileobj=sys.stdout.buffer,mode='w|') as t:
 for f,name in files:
  data=f.read_bytes()
  if f.suffix in ['.log','.jsonl']:data=gzip.compress(data,mtime=0);name+='.gz'
  item=tarfile.TarInfo(name);item.size=len(data);t.addfile(item,io.BytesIO(data))
'''
data=subprocess.check_output(['ssh','agent1','python3 -'],input=remote.encode())
with tarfile.open(fileobj=io.BytesIO(data)) as t:
 assert all(m.isfile() and not m.name.startswith('/') and '..' not in Path(m.name).parts for m in t.getmembers())
 t.extractall(out)
print(out)
