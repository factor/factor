from pathlib import Path
import sys
probe_dir=Path(sys.argv[1])
pre=(probe_dir/'prolog.bin').read_bytes();post=(probe_dir/'epilog.bin').read_bytes()+(probe_dir/'return.bin').read_bytes()
code=pre+(probe_dir/'callstack.bin').read_bytes()+post
rel=(probe_dir/'callstack.reloc').read_bytes();rs=[int.from_bytes(rel[i:i+4],'big') for i in range(0,len(rel),4)]
(probe_dir/'sparc-callstack-data.h').write_text('static const unsigned char callstackcode[]={'+','.join(map(str,code))+'};\nstatic const unsigned callstackrel[]={'+','.join(hex(x) for x in rs)+'};\nenum{callstack_prefix='+str(len(pre))+'};\nstatic const unsigned callstack_literals[]={'+','.join((probe_dir/'callstack.here').read_text().split())+'};\n')
