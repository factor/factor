from pathlib import Path
import sys
probe_dir=Path(sys.argv[1])
pre=(probe_dir/'prolog.bin').read_bytes();post=(probe_dir/'epilog.bin').read_bytes()+(probe_dir/'return.bin').read_bytes()
code=pre+(probe_dir/'reset.bin').read_bytes()+post
rel=(probe_dir/'reset.reloc').read_bytes();rs=[int.from_bytes(rel[i:i+4],'big') for i in range(0,len(rel),4)]
(probe_dir/'sparc-reset-data.h').write_text('static const unsigned char resetcode[]={'+','.join(map(str,code))+'};\nstatic const unsigned resetrel[]={'+','.join(hex(x) for x in rs)+'};\nenum{reset_prefix='+str(len(pre))+'};\nstatic const unsigned reset_literals[]={'+','.join((probe_dir/'reset.here').read_text().split())+'};\n')
