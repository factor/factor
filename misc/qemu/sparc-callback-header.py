from pathlib import Path
import sys
probe_dir=Path(sys.argv[1])
code=(probe_dir/'callback.bin').read_bytes();rel=(probe_dir/'callback.reloc').read_bytes();records=[int.from_bytes(rel[i:i+4],'big') for i in range(0,len(rel),4)]
(probe_dir/'sparc-callback-data.h').write_text('static const unsigned char cbcode[]={'+','.join(map(str,code))+'};\nenum { cb_vm='+str(records[0]&0xffffff)+', cb_fn='+str(records[1]&0xffffff)+' };\n')
prefix=(probe_dir/'prolog.bin').read_bytes()
suffix=(probe_dir/'epilog.bin').read_bytes()+(probe_dir/'return.bin').read_bytes()
with (probe_dir/'sparc-callback-data.h').open('a') as out:
 for name,filename in [('ctfcode','c-to-factor'),('fpuget','fpu-get'),('fpuset','fpu-set')]:
  data=prefix+(probe_dir/(filename+'.bin')).read_bytes()+suffix
  out.write('static const unsigned char '+name+'[]={'+','.join(map(str,data))+'};\n')
 rel=(probe_dir/'c-to-factor.reloc').read_bytes()
 records=[int.from_bytes(rel[i:i+4],'big') for i in range(0,len(rel),4)]
 out.write('static const unsigned int ctfrel[]={'+','.join(hex(n) for n in records)+'};\n')
 out.write('enum { ctf_prefix='+str(len(prefix))+' };\n')
with (probe_dir/'sparc-callback-data.h').open('a') as out:
 for i,stem in enumerate(['call','lazy','cache','cache-tail']):
  data=prefix+(probe_dir/(stem+'.init')).read_bytes()+(probe_dir/'epilog.bin').read_bytes()+(probe_dir/(stem+'.tail')).read_bytes()
  out.write('static const unsigned char comb'+str(i)+'[]={'+','.join(map(str,data))+'};\n')
  rel=(probe_dir/(stem+'.reloc')).read_bytes()
  records=[int.from_bytes(rel[j:j+4],'big') for j in range(0,len(rel),4)]
  out.write('static const unsigned int combrel'+str(i)+'[]={'+','.join(hex(n) for n in records)+'};\n')
 out.write('struct comb_probe { const unsigned char *code; unsigned length; const unsigned int *rel; unsigned count; };\n')
 out.write('static const struct comb_probe combs[]={'+','.join('{comb'+str(i)+',sizeof comb'+str(i)+',combrel'+str(i)+',sizeof combrel'+str(i)+'/sizeof combrel'+str(i)+'[0]}' for i in range(4))+'};\n')
