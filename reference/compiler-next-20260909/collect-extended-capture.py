from pathlib import Path
import importlib.util,json,difflib,hashlib
P=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('c',P/'collect-isolated.py');c=importlib.util.module_from_spec(s);s.loader.exec_module(c)
out=P/'corrected-native/final-a7/extended-capture'; cap={}
for v,root in [('baseline','/home/erg/factor-compiler-next-greedy-baseline-20260909'),('candidate','/home/erg/factor-compiler-next-final-c6948-20260909')]:
 n='corrected-'+v+'-callee-check'; f=c.fetch(root,c.NXT,[n+e for e in ['.log','.jsonl','.status.json']]+['capture-callees-checked.factor','capture-workload-code.factor'],out/v)
 rr=c.getrows(f,n);st=json.loads(f[n+'.status.json']); assert all(hashlib.sha256(f[k]).hexdigest()==h for k,h in st['script_sha256'].items())
 cap[v]={r['word']:r for r in rr if r['kind']=='generated-code'}
assert set(cap['baseline'])==set(cap['candidate']) and len(cap['baseline'])==3
result={}
for w,b in cap['baseline'].items():
 a=cap['candidate'][w];result[w]={'bytes':{v:len(cap[v][w]['code-bytes']) for v in cap},'equal':{k:b[k]==a[k] for k in ['code-bytes','relocations','literals','parameters','frame-bytes','physical-instructions']},'literals':b['literals'],'physical_diff':list(difflib.unified_diff(b['physical-instructions'],a['physical-instructions']))}
(out/'comparison.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
