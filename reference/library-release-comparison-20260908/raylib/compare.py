#!/usr/bin/env python3
"""Compare Factor's raylib declarations with the tagged upstream API inventory.

The upstream JSON has unescaped quotation marks in documentation fields; only
those fields are discarded. Declaration data is unchanged. Header function
names are independently cross-checked to catch a stale generated inventory.
This is a source-level comparison, not a proof of runtime ABI correctness.
"""
import argparse, hashlib, json, re
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument('upstream',type=Path)
p.add_argument('factor_root',type=Path)
a=p.parse_args()
header=(a.upstream/'src/raylib.h').read_text()
raw=(a.upstream/'tools/rlparser/output/raylib_api.json').read_text()
raw='\n'.join(re.sub(r'"description":.*','"description": ""'+(',' if l.rstrip().endswith(',') else ''),l) if '"description":' in l else l for l in raw.splitlines())
api=json.loads(raw)
source=(a.factor_root/'extra/raylib/raylib.factor').read_text()
source=re.sub(r'!.*','',source)
header_names=set(re.findall(r'^RLAPI\s+.*?\b(\w+)\s*\(',header,re.M))
json_names={f['name'] for f in api['functions']}
assert header_names==json_names,(header_names-json_names,json_names-header_names)
# Unify synonyms from both declarations; Factor sometimes chooses the alias as
# its primary struct name (Texture2D/Texture and RenderTexture2D/RenderTexture).
parents={}
def root(x):
    if parents.get(x,x)!=x: parents[x]=root(parents[x])
    return parents.get(x,x)
def union(x,y):
    x,y=root(x),root(y)
    if x!=y: parents[max(x,y)]=min(x,y)
for x in api['aliases']:
    # rlparser emits ModelAnimPose as name '*ModelAnimPose', type 'Transform'.
    # Its pointer typedef is read from the actual header below instead.
    if '*' not in x['name'] and '*' not in x['type']:union(x['name'],x['type'])
for typ,name in re.findall(r'^TYPEDEF:\s+(\S+)\s+(\S+)',source,re.M): union(typ,name)
pointer_aliases=dict((name,typ.strip()) for typ,name in re.findall(r'^typedef\s+(\w+\s*\*+)\s*(\w+)\s*;',header,re.M))
enums={e['name'] for e in api['enums']}|set(re.findall(r'^ENUM:\s+(\w+)',source,re.M))
scalar={'unsigned int':'uint','unsigned char':'uchar','unsigned short':'ushort','unsigned long':'ulong','long long':'longlong','unsigned long long':'ulonglong','c-string':'char*'}
def norm(typ):
    typ=re.sub(r'\bconst\b','',typ).strip()
    typ=re.sub(r'\s*\*\s*','*',typ)
    typ=re.sub(r'\s+',' ',typ)
    base=re.match(r'[^*\[]+',typ).group().strip()
    suffix=typ[len(base):].replace(' ','')
    if base in pointer_aliases: return norm(pointer_aliases[base]+suffix)
    base=scalar.get(base,base)
    base='int' if base in enums else root(base)
    return base+suffix
# Cross-check declaration types as well as names against the real header.
header_signatures={}
for ret,name,args in re.findall(r'^RLAPI\s+(.+?)\s*(\w+)\s*\(([^;]*)\);',header,re.M):
    params=[]
    for arg in args.split(','):
        arg=arg.strip()
        if not arg or arg=='void':continue
        if arg=='...':params.append('...');continue
        match=re.fullmatch(r'(.+?)([A-Za-z_]\w*)(\[[^]]+\])?',arg)
        assert match,(name,arg)
        params.append(norm(match.group(1).strip()+(match.group(3) or '')))
    header_signatures[name]=[norm(ret.strip()),params]
assert set(header_signatures)==json_names
for function in api['functions']:
    inventory=[norm(function['returnType']),[norm(x['type']) for x in function.get('params',[])]]
    assert inventory==header_signatures[function['name']],(function['name'],inventory,header_signatures[function['name']])
functions={}
for kind,decl in re.findall(r'^FUNCTION(-ALIAS)?:\s*([^\n]*\([^)]*\))',source,re.M):
    prefix,args=decl.split('(',1)
    words=prefix.split(); name=words[-1]; ret=words[-2]
    params=[]
    for arg in args[:-1].split(','):
        arg=arg.strip()
        if not arg: continue
        if arg.startswith('...'):
            params.append('...');arg=arg[3:].strip()
        if arg:
            words=arg.split()
            # Factor's parse-pointers accepts C-style stars on the name.
            params.append(words[0]+('*'*(len(words[1])-len(words[1].lstrip('*')))))
    functions[name]={'return':ret,'params':params}
missing=[];differences=[];string_views=[]
for f in api['functions']:
    name=f['name']; ct=[p['type'] for p in f.get('params',[])]
    if name not in functions: missing.append(name);continue
    ff=functions[name]
    expected=[norm(f['returnType'])]+[norm(t) for t in ct]
    actual=[norm(ff['return'])]+[norm(t) for t in ff['params']]
    if actual!=expected: differences.append({'name':name,'C':[f['returnType'],ct],'Factor':ff})
    if f['returnType'].replace(' ','')=='char*' and ff['return']=='c-string': string_views.append(name)
structs={}
for name,body in re.findall(r'^STRUCT:\s+(\w+)\s+(.*?);',source,re.M|re.S):
    fields=re.findall(r'\{\s*(\S+)\s+([^}]+?)\s*\}',body)
    structs[root(name)]=[(field,typ) for field,typ in fields]
struct_diffs=[];missing_structs=[]
for s in api['structs']:
    local=structs.get(root(s['name']))
    if local is None:missing_structs.append(s['name']);continue
    expected=[norm(x['type']) for x in s['fields']]
    actual=[norm(t) for _,t in local]
    if actual!=expected:struct_diffs.append({'name':s['name'],'C':[(f['name'],f['type']) for f in s['fields']],'Factor':local})
# Extract enum values, including implicit increments. Factor enum bodies here
# contain integer literals only; reject anything more complex rather than guess.
local_values={};enum_parse_errors=[]
for name,body in re.findall(r'^ENUM:\s+(\w+)\s+(.*?);',source,re.M|re.S):
    value=-1
    for token in re.findall(r'\{[^}]*\}|\S+',body):
        if token.startswith('{'):
            key,val=token.strip('{} ').split()
            try:value=int(val,0)
            except ValueError:enum_parse_errors.append([name,key,val]);continue
        else:key=token;value+=1
        local_values[key]=value
missing_enum=[];enum_diffs=[]
for e in api['enums']:
    for v in e['values']:
        if v['name'] not in local_values:missing_enum.append(v['name'])
        elif local_values[v['name']]!=v['value']:enum_diffs.append([v['name'],v['value'],local_values[v['name']]])
callbacks={}
for ret,name,args in re.findall(r'^CALLBACK:\s+(\S+)\s+(\w+)\s*\(([^)]*)\)',source,re.M):
    callbacks[name]=[norm(ret),[norm(x.strip().split()[0]) for x in args.split(',') if x.strip()]]
callback_diffs=[]
for f in api['callbacks']:
    expected=[norm(f['returnType']),[norm(p['type']) for p in f.get('params',[])]]
    if callbacks.get(f['name'])!=expected:callback_diffs.append({'name':f['name'],'C':expected,'Factor':callbacks.get(f['name'])})
color_diffs=[]
color_count=0
for define in api['defines']:
    if define['type']!='COLOR':continue
    color_count+=1
    expected=[int(x) for x in re.findall(r'\d+',define['value'])]
    match=re.search(r'^CONSTANT:\s+'+define['name']+r'\s+S\{ Color f ([^}]+)\}',source,re.M)
    actual=[int(x) for x in match.group(1).split()] if match else None
    if actual!=expected:color_diffs.append([define['name'],expected,actual])
# Ignore pointee naming when checking field ABI shapes; preserve pointer depth.
def shape(typ):
    typ=norm(typ)
    return 'pointer'+('*'*typ.count('*')) if '*' in typ else typ
struct_shape_diffs=[]
for st in api['structs']:
    local=structs.get(root(st['name']))
    if local is not None and [shape(t) for _,t in local]!=[shape(f['type']) for f in st['fields']]:
        struct_shape_diffs.append(st['name'])
print(json.dumps({'header_sha256':hashlib.sha256(header.encode()).hexdigest(),'counts':{'upstream_functions':len(json_names),'factor_functions':len(functions),'matched_names':len(json_names&functions.keys()),'upstream_structs':len(api['structs']),'upstream_enum_members':sum(len(e['values']) for e in api['enums']),'upstream_callbacks':len(api['callbacks']),'upstream_colors':color_count},'color_differences':color_diffs,'struct_field_abi_shape_differences':struct_shape_diffs,'missing_functions':missing,'extra_functions':sorted(functions.keys()-json_names),'signature_differences':differences,'missing_structs':missing_structs,'struct_differences':struct_diffs,'missing_enum_members':missing_enum,'enum_value_differences':enum_diffs,'enum_parse_errors':enum_parse_errors,'callback_differences':callback_diffs,'mutable_string_returns_copied_by_factor':string_views},indent=2))
