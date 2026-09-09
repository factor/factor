#!/usr/bin/env python3
"""Read-only analysis after all measured processes exit; uses installed bytes."""
import json,re,statistics,subprocess
from pathlib import Path
P=Path('/home/erg/compiler-next2-integer-20260909');summary={};disasm=P/'disassembly';disasm.mkdir(exist_ok=True)
for label in ['baseline-1','candidate-1','candidate-2','baseline-2']:
 rr=list(map(json.loads,(P/(label+'.jsonl')).read_text().splitlines()));st=json.loads((P/(label+'.status.json')).read_text());assert st['ok']
 runs=[r for r in rr if r['kind']=='runtime' and r['trial']>=0];assert len(runs)==3
 shots={(r['trial'],r['phase'],r['word']):r for r in rr if r['kind']=='installed-code'}
 words=sorted({r['word'] for r in shots.values()});stable={}
 for t in [-1,0,1,2]:
  stable[str(t)]={w:{'address':shots[t,'before-batch',w]['start-address']==shots[t,'after-batch',w]['start-address'],'bytes':shots[t,'before-batch',w]['code-bytes']==shots[t,'after-batch',w]['code-bytes']} for w in words}
 normalized={};raw_sizes={}
 for w in words:
  r=shots[0,'before-batch',w];start=r['start-address'];code=bytes(r['code-bytes']);stem=label+'-'+w.replace(':','_').replace('>','_').replace('+','plus');f=disasm/(stem+'.bin');f.write_bytes(code)
  asm=subprocess.check_output(['objdump','-D','-b','binary','-m','i386:x86-64','--adjust-vma='+str(start),'--no-show-raw-insn',str(f)],text=True);(disasm/(stem+'.asm')).write_text(asm)
  # Address normalization is for comparing instruction structure; external
  # addresses are retained in raw disassembly and are not claimed equivalent.
  lines=[]
  for line in asm.splitlines():
   m=re.match(r'^\s*([0-9a-f]+):\s+(.*)$',line)
   if not m:continue
   off=int(m.group(1),16)-start;op=m.group(2).split('#')[0].strip()
   op=re.sub(r'-?0x[0-9a-f]+\(%rip\)','REL(%rip)',op)
   b=re.match(r'((?:j\w+|call)\s+)0x([0-9a-f]+)$',op)
   if b:
    dest=int(b.group(2),16)
    target=next((name for name in words if shots[0,'before-batch',name]['start-address']==dest),None)
    if target:op=b.group(1)+target
    elif start<=dest<start+len(code):op=b.group(1)+'self+'+hex(dest-start)
    else:op=b.group(1)+'EXTERNAL'
   lines.append([off,op])
  normalized[w]=lines;raw_sizes[w]=len(code)
 summary[label]={'source':st['source'],'runtime':runs,'medians':{k:statistics.median(r[k] for r in runs) for k in ['instructions','cpu_seconds','ns']},'capture_unchanged_during_batches':stable,'code_bytes':raw_sizes,'normalized_instructions':normalized,'compile':next(r for r in rr if r['kind']=='compile'),'scope_count':len(next(r for r in rr if r['kind']=='scope')['words'])}
comp={}
for b,c in [('baseline-1','candidate-1'),('baseline-2','candidate-2')]:
 comp[b+'/'+c]={'retired_delta':summary[c]['medians']['instructions']-summary[b]['medians']['instructions'],'ratios':{k:summary[c]['medians'][k]/summary[b]['medians'][k] for k in ['instructions','cpu_seconds','ns']},'normalized_equal':{w:summary[b]['normalized_instructions'][w]==summary[c]['normalized_instructions'][w] for w in summary[b]['normalized_instructions']}}
(P/'summary.json').write_text(json.dumps({'processes':summary,'pairs':comp},indent=2)+'\n');print(json.dumps(comp,indent=2))
