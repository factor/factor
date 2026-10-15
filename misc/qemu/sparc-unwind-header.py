from pathlib import Path
import sys
probe_dir=Path(sys.argv[1])
wide=len((probe_dir/'unwind.bin').read_bytes())>100
bias=2047 if wide else 0
cell=8 if wide else 4
op=14 if wide else 4
store=lambda reg,off: (0xc0002000|(reg<<25)|(op<<19)|(9<<14)|off).to_bytes(4,'big')
pre=(probe_dir/'prolog.bin').read_bytes()+(0x90162000).to_bytes(4,'big')+(0x9203a000+bias).to_bytes(4,'big')+store(30,14*cell)+store(31,15*cell);post=(probe_dir/'epilog.bin').read_bytes()+(probe_dir/'return.bin').read_bytes()
code=pre+(probe_dir/'unwind.bin').read_bytes()
rel=(probe_dir/'unwind.reloc').read_bytes();rs=[int.from_bytes(rel[i:i+4],'big') for i in range(0,len(rel),4)]
(probe_dir/'sparc-unwind-data.h').write_text('static const unsigned char unwindcode[]={'+','.join(map(str,code))+'};\nstatic const unsigned unwindrel[]={'+','.join(hex(x) for x in rs)+'};\nenum{unwind_prefix='+str(len(pre))+'};\nstatic const unsigned unwind_literals[]={'+','.join((probe_dir/'unwind.here').read_text().split())+'};\n')
