from pathlib import Path
import sys
probe_dir=Path(sys.argv[1])
tag=(probe_dir/'tag.bin').read_bytes()
hit=(probe_dir/'hit.bin').read_bytes()
code=tag+hit+bytes.fromhex('9010200081c3e00801000000')
rel=(probe_dir/'hit.reloc').read_bytes()
assert len(rel)==4
r=int.from_bytes(rel,'big')
assert r>>24==0x1f
(probe_dir/'sparc-pic-data.h').write_text('static const unsigned char piccode[]={'+','.join(map(str,code))+'};\nenum{pic_offset='+str(len(tag)+(r&0xffffff))+'};\n')
