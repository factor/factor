#!/usr/bin/env python3
"""Check every changed compiler-source file against the recorded Git snapshot."""
import hashlib,json
from pathlib import Path
root=Path(__file__).resolve().parents[2];out=Path(__file__).resolve().parent
expected=json.loads((out/'source-expected.json').read_text())
actual={}
for name,digest in expected['files'].items():
 p=root/name
 actual[name]=hashlib.sha256(p.read_bytes()).hexdigest() if p.exists() else None
 assert actual[name]==digest,(name,actual[name],digest)
(out/'source-manifest.json').write_text(json.dumps(dict(source_commit=expected['source_commit'],archive_base=expected['archive_base'],files=actual,all_match=True),indent=2)+'\n')
print('All',len(actual),'changed compiler-source paths match',expected['source_commit'])
