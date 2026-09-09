import json,re,pathlib
text=pathlib.Path(__file__).with_name('output.log').read_text()
summary=[]
parts=re.split(r'^\{ (f|t) ([012]) \}\n',text,flags=re.M)
for i in range(1,len(parts),3):
 single,mode,body=parts[i:i+3]
 rows=re.findall(r'^\s*\{ ([tf]) ([tf]) ([tf]) ([tf]) \}\s*$',body,re.M)
 assert len(rows)==8,(single,mode,len(rows))
 summary.append(dict(single_block=single=='t',mode=['none','local','global'][int(mode)],samples=len(rows),actual_moves=sum(r[0]=='t' for r in rows),before_matches_caller=sum(r[1]=='t' for r in rows),after_matches_caller=sum(r[2]=='t' for r in rows),snapshots_equal=sum(r[3]=='t' for r in rows)))
print(json.dumps(summary,indent=2))
