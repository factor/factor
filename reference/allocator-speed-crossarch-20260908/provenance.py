#!/usr/bin/env python3
import argparse,hashlib,json,os,platform,subprocess
from pathlib import Path
root=Path(__file__).resolve().parents[2]
out=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--source',default='233db947df');a=p.parse_args()

def digest(path):
 h=hashlib.sha256()
 with path.open('rb') as f:
  for chunk in iter(lambda:f.read(1048576),b''):h.update(chunk)
 return h.hexdigest()

def command(*args):
 p=subprocess.run(args,capture_output=True,text=True)
 return dict(status=p.returncode,stdout=p.stdout,stderr=p.stderr)
report=dict(platform=platform.platform(),machine=platform.machine(),processor=platform.processor(),source_commit=a.source,mode='native',artifacts={})
for p in [root/'factor',root/'seed.image',root/'boot.unix-x86.64.image',root/'factor.image',out/'prepared.image',out/'counters']:
 if p.exists(): report['artifacts'][p.name]=dict(bytes=p.stat().st_size,sha256=digest(p))
if platform.system()=='Linux':
 for name,args in [('cpu',['lscpu']),('load',['uptime']),('perf_permissions',['cat','/proc/sys/kernel/perf_event_paranoid']),('vm_capabilities',['getcap',str(root/'factor')]),('compiler',['gcc','--version'])]:report[name]=command(*args)
else:
 for name,args in [('cpu',['sysctl','machdep.cpu.brand_string']),('load',['uptime']),('compiler',['clang','--version'])]:report[name]=command(*args)
(out/'environment.json').write_text(json.dumps(report,indent=2)+'\n')
