import collections,json,re
from pathlib import Path
b=Path(__file__).resolve().parent
s=(b/'test-all.log').read_text(errors='replace')
files=re.findall(r'^TEST-FILE (.*)$',s,re.M)
failures=[]
for m in re.finditer(r'^FAILURE-DETAIL ([^\n]*)\n([^\n]*)\n(.*?)(?=^(?:Unit Test:|Must Fail|Must Infer|TEST-FILE |FAILURE-DETAIL |TEST-ALL COMPLETE)|\Z)',s,re.M|re.S):
 path,line,detail=m.groups()
 failures.append({'path':path,'line':line,'detail':detail.strip()})
(b/'failure-details.json').write_text(json.dumps(failures,indent=2)+'\n')
print('TEST FILES',len(files),'LATEST',files[-1] if files else '')
print('FAILURES',len(failures))
for path,n in collections.Counter(f['path'] for f in failures).most_common():
 print(n,path)
print('\n'.join(s.splitlines()[-5:]))
