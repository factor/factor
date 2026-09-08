import json, pathlib, re
out=pathlib.Path(__file__).resolve().parent
def count(name, pattern):
 matches=re.findall(pattern,(out/(name+'.log')).read_text(errors='replace'),re.M)
 assert matches, (name,pattern)
 return int(matches[-1])
log=(out/'test-all.log').read_text(errors='replace')
paths=re.findall(r'^TEST-FILE (.*)$',log,re.M)
result={
 'source_commit':json.loads((out/'provenance.json').read_text())['source_commit'],
 'stages':{s:json.loads((out/(s+'.json')).read_text()) for s in ['bootstrap','load-all','help-lint','test-all','final-gtk']},
 'loaded_vocabularies':count('load-all',r'^LOADED VOCABS (\d+)$'),
 'load_compiler_errors':count('load-all',r'^COMPILER ERRORS (\d+)$'),
 'help_failures':count('help-lint',r'^HELP FAILURES (\d+)$'),
 'test_files':len(paths),
 'test_failures':count('test-all',r'^TEST FAILURES (\d+)$'),
 'test_compiler_errors':count('test-all',r'^COMPILER ERRORS (\d+)$'),
 'simd_test_files':[p for p in paths if '/simd/' in p],
 'vm_stack_safety':(out/'final-stack-safety.log').read_text(),
}
assert all(s['status']==0 for s in result['stages'].values())
assert all(result[k]==0 for k in ['load_compiler_errors','help_failures','test_failures','test_compiler_errors'])
(out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
