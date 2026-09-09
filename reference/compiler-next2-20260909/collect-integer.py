#!/usr/bin/env python3
from pathlib import Path
import gzip,io,json,subprocess,tarfile
P=Path(__file__).resolve().parent;out=P/'integer-same-process';out.mkdir(exist_ok=True)
raw=subprocess.check_output(['ssh','agent1','tar -C /home/erg/compiler-next2-integer-20260909 -cf - .'])
with tarfile.open(fileobj=io.BytesIO(raw)) as t:
 for m in t:
  if not m.isfile():continue
  n=Path(m.name);assert not n.is_absolute() and '..' not in n.parts
  f=out/n;f.parent.mkdir(parents=True,exist_ok=True);b=t.extractfile(m).read()
  if f.suffix in ['.log','.jsonl']:f.with_name(f.name+'.gz').write_bytes(gzip.compress(b,mtime=0))
  else:f.write_bytes(b)
s=json.loads((out/'summary.json').read_text());assert len(s['processes'])==4
for n,p in s['processes'].items():
 assert len(p['runtime'])==3
 assert all(all(all(x.values()) for x in words.values()) for words in p['capture_unchanged_during_batches'].values())
print(json.dumps(s['pairs'],indent=2))
