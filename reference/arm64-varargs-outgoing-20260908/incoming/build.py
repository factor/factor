from pathlib import Path
import re
import subprocess
out = Path(__file__).resolve().parent
subprocess.run(['clang','-target','aarch64-pc-windows-msvc','-S','-O2',str(out/'callers.c'),'-o',str(out/'callers-windows.s')],check=True)
source=(out/'callers-windows.s').read_text()
source=re.sub(r'"__(?:xmm|real)@([0-9a-f]+)"',r'Lconst_\1',source)
lines=[]
for line in source.splitlines():
    if '.debug$' in line: break
    if line.strip().startswith(('.def','.scl','.type','.endef','.seh_','.file','.linkonce')) or '@feat' in line: continue
    if line.strip().startswith('.section'):
        assert '.rdata' in line, line
        lines.append('\t.section __TEXT,__const')
        continue
    if line.strip().startswith('.globl') and 'Lconst_' in line: continue
    line=re.sub(r'\bincoming_(\w+)\b',r'_incoming_\1',line)
    line=re.sub(r'(adrp\s+x\d+,\s*)(\w+)',r'\1\2@PAGE',line)
    line=re.sub(r':lo12:(\w+)',r'\1@PAGEOFF',line)
    lines.append(line)
(out/'callers-macho.s').write_text('\n'.join(lines)+'\n')
subprocess.run(['clang','-dynamiclib',str(out/'callers-macho.s'),'-o',str(out/'callers.dylib')],check=True)
