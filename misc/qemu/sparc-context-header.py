from pathlib import Path
import sys
probe_dir=Path(sys.argv[1])
code=(probe_dir/'prolog.bin').read_bytes()+(probe_dir/'context.bin').read_bytes()+(probe_dir/'epilog.bin').read_bytes()+(probe_dir/'return.bin').read_bytes()
rel=(probe_dir/'context.reloc').read_bytes()
items=[int.from_bytes(rel[i:i+4],'big') for i in range(0,len(rel),4)]
prefix=len((probe_dir/'prolog.bin').read_bytes())
(probe_dir/'sparc-context-data.h').write_text('static const unsigned char ctxcode[]={'+','.join(map(str,code))+'};\n'+'enum { ctx_prefix='+str(prefix)+', ctx_here='+str((items[0]&0xffffff)+prefix)+', ctx_fn='+str((items[1]&0xffffff)+prefix)+', ctx_literal='+(probe_dir/'context.here').read_text()+' };\n')

tail=(probe_dir/'tail.bin').read_bytes()
rel=(probe_dir/'tail.reloc').read_bytes()
assert len(rel)==4 and int.from_bytes(rel,'big')>>24==0x3f
with (probe_dir/'sparc-context-data.h').open('a') as out:
 out.write('static const unsigned char tailcode[]={'+','.join(map(str,tail))+'};\n')
 out.write('enum { tail_fn='+str(int.from_bytes(rel,'big')&0xffffff)+' };\n')
