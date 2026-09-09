#!/usr/bin/env python3
"""Retain ARM evidence and executed harness, without moving raw inputs or images."""
from pathlib import Path
import gzip,hashlib,json,shutil,subprocess
P=Path(__file__).resolve().parent;R=P.parents[1];D=P/'arm';D.mkdir(exist_ok=True)
manifest=json.loads((P/'source-manifest.json').read_text())
for name,h in manifest['files'].items():assert hashlib.sha256((R/name).read_bytes()).hexdigest()==h,name
for p in P.iterdir():
 if p.is_file() and (p.name.startswith('arm-') or p.name in ['checked-validation.json','source-manifest.json']) and p.suffix in ['.log','.jsonl','.json']:
  b=p.read_bytes();name=p.name
  if p.suffix in ['.log','.jsonl']:b=gzip.compress(b,mtime=0);name+='.gz'
  (D/name).write_bytes(b)
H=D/'executed-harness';H.mkdir(exist_ok=True)
for p in P.iterdir():
 if p.suffix in ['.py','.factor']:shutil.copy2(p,H/p.name)
for p in D.glob('arm-combined-*.status.json'):
 status=json.loads(p.read_text());assert status['ok']
 for name,h in status['script_sha256'].items():assert hashlib.sha256((H/name).read_bytes()).hexdigest()==h,(p,name)
subprocess.run(['python3',str(P/'analyze.py'),str(D),'--prefix','arm-combined','--output',str(D/'results.json')],check=True,cwd=R)
subprocess.run(['python3',str(P/'render-summary.py'),str(D/'results.json'),str(D/'MEASUREMENTS.md')],check=True,cwd=R)
(D/'SHA256.json').write_text(json.dumps({str(p.relative_to(D)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(D.rglob('*')) if p.is_file() and p.name!='SHA256.json'},indent=2)+'\n')
print('Archived',D)
