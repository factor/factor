#!/usr/bin/env python3
"""Archive the final untimed capture with timing-equivalent compiler options."""
from pathlib import Path
import importlib.util,json,difflib,hashlib
P=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('c',P/'collect-isolated.py');c=importlib.util.module_from_spec(s);s.loader.exec_module(c)
out=P/'corrected-native/final-a7/timing-flags-capture';cap={};installed={};scope={}
for v,root in [('baseline','/home/erg/factor-compiler-next-greedy-baseline-20260909'),('candidate','/home/erg/factor-compiler-next-final-c6948-20260909')]:
 n='corrected-'+v+'-timing-flags-capture'
 f=c.fetch(root,c.NXT,[n+e for e in ['.log','.jsonl','.status.json']]+['capture-timing-flags.factor','capture-workload-code.factor','capture-installed.factor','capture-timing-flags-body.factor'],out/v)
 rr=c.getrows(f,n);st=json.loads(f[n+'.status.json']); assert not st['final_value_verifier'] and all(hashlib.sha256(f[k]).hexdigest()==h for k,h in st['script_sha256'].items())
 ss=next(r for r in rr if r['kind']=='scope'); assert not ss['checked'] and ss['options']=={'rematerialize_constants':True,'backtracking_loop_spills':True,'gvn':False}
 runtime=[r for r in rr if r['kind']=='runtime'];assert len(runtime)==26 and all(r['trial']==-1 for r in runtime)
 scope[v]=dict(source=ss['source'],word_count=len(ss['words']),options=ss['options'],checked=ss['checked'])
 cap[v]={r['word']:r for r in rr if r['kind']=='generated-code'}
 installed[v]={phase:{r['word']:r for r in rr if r['kind']=='installed-code' and r['phase']==phase} for phase in ['after-install','after-outputs']}
 assert len(cap[v])==5 and all(set(x)==set(cap[v]) for x in installed[v].values())
 for phase,ws in installed[v].items():
  for w,r in ws.items():
   (out/v/(phase+'-'+w.replace(':','_').replace('>','_').replace('+','plus')+'.bin')).write_bytes(bytes(r['code-bytes']))
result={}
for w,b in cap['baseline'].items():
 a=cap['candidate'][w];result[w]={'bytes':{v:len(cap[v][w]['code-bytes']) for v in cap},'equal':{k:b[k]==a[k] for k in ['code-bytes','relocations','literals','parameters','frame-bytes','physical-instructions']},'literals':b['literals'],'physical_diff':list(difflib.unified_diff(b['physical-instructions'],a['physical-instructions'])),'installed_after_outputs_unchanged':{v:{'address':installed[v]['after-install'][w]['start-address']==installed[v]['after-outputs'][w]['start-address'],'bytes':installed[v]['after-install'][w]['code-bytes']==installed[v]['after-outputs'][w]['code-bytes']} for v in installed}}
(out/'comparison.json').write_text(json.dumps({'scope':scope,'targets':result,'diagnostic_only':True,'timing_samples':0},indent=2)+'\n')
print(json.dumps(result,indent=2))

# Native x86 relocation fields: vm/instruction_operands.hpp encodes class in
# bits24..27 and end-offset in low24; instruction_operands.cpp patches the
# preceding pointer/4/2/1 bytes. Mask only those recorded operand fields.
import struct
installed_audit={}
for v in installed:
    installed_audit[v]={}
    for w,g in cap[v].items():
        def normalized(r):
            data=bytearray(r['code-bytes'])
            for value, in struct.iter_unpack('<I',bytes(g['relocations'])):
                klass=(value>>24)&15;offset=value&0xffffff
                size={0:8,1:4,2:4,10:2,11:1}[klass]
                assert size<=offset<=len(data)
                data[offset-size:offset]=b'\0'*size
            return bytes(data)
        before=installed[v]['after-install'][w];after=installed[v]['after-outputs'][w]
        installed_audit[v][w]={'relocation_masked_code_unchanged':normalized(before)==normalized(after),
            'installed_bytes':[len(before['code-bytes']),len(after['code-bytes'])]}
        assert normalized(before)==normalized(after)
    for phase,words in installed[v].items():
        wrapper=words['allocator-runtime-comparison:integer-pressure-work']
        code=bytes(wrapper['code-bytes']);calls=[]
        # Offsets independently identified in retained objdump disassembly.
        for offset,target in [(0x6e,'allocator-runtime-comparison:integer-pressure'),(0x73,'math:+')]:
            assert code[offset]==0xe8
            destination=wrapper['start-address']+offset+5+struct.unpack_from('<i',code,offset+1)[0]
            assert destination==words[target]['start-address']
            calls.append({'instruction_offset':offset,'target':target,'actual_address':destination})
        installed_audit[v][phase+'-wrapper-calls']=calls
(out/'installed-relocation-audit.json').write_text(json.dumps(installed_audit,indent=2)+'\n')
