#!/usr/bin/env python3
"""Decode an untimed installed-code capture; this is not a hardware branch trace."""
from pathlib import Path
import json,subprocess,re,hashlib
p=Path(__file__).resolve().parent;out=p/'native-loop-code';out.mkdir(exist_ok=True)
rows=[]
for line in (p/'native-loop-code.log').read_text().splitlines():
 try:r=json.loads(line)
 except json.JSONDecodeError:continue
 if r.get('kind')!='installed-loop-code':continue
 label=r['feature'] if r['enabled'] else 'off';b=bytes(r['code-bytes']);f=out/(label+'.bin');f.write_bytes(b)
 asm=subprocess.check_output(['objdump','-D','-b','binary','-m','i386:x86-64','--adjust-vma='+str(r['start-address']),str(f)],text=True)
 (out/(label+'.asm')).write_text(asm)
 branches=[]
 for line in asm.splitlines():
  m=re.match(r'^\s*([0-9a-f]+):\s+(?:[0-9a-f]{2}\s+)+\s*(j\w+)\s+(?:0x)?([0-9a-f]+)\b',line)
  if m:
   address,target=int(m[1],16),int(m[3],16)
   if r['start-address']<=target<address:branches.append({'instruction_offset':address-r['start-address'],'mnemonic':m[2],'target_offset':target-r['start-address'],'target_mod16':target%16,'target_mod32':target%32,'target_mod64':target%64})
 rows.append({k:v for k,v in r.items() if k!='code-bytes'}|{'code_size':len(b),'code_sha256':hashlib.sha256(b).hexdigest(),'backward_branches':branches})
assert len(rows)==3
(out/'summary.json').write_text(json.dumps({'untimed':True,'same_as_timing_addresses':False,'static_disassembly_not_branch_trace':True,'captures':rows},indent=2)+'\n')
print(json.dumps(rows,indent=2))
