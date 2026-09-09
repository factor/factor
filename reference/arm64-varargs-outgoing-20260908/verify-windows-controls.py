"""Execute separately generated Windows C caller/callee controls on macOS."""
from pathlib import Path
import ctypes
import re
import subprocess
out = Path(__file__).resolve().parent
root = out.parent.parent
subprocess.run(['clang','-target','aarch64-pc-windows-msvc','-S','-O2',str(root/'vm/ffi_test_varargs_outgoing.c'),'-o',str(out/'controls-windows.s')],check=True)
source=(out/'controls-windows.s').read_text()
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
    line=re.sub(r'\bvarout_(\w+)\b',r'_varout_\1',line)
    line=re.sub(r'(adrp\s+x\d+,\s*)([.\w]+)',r'\1\2@PAGE',line)
    line=re.sub(r':lo12:([.\w]+)',r'\1@PAGEOFF',line)
    lines.append(line)
(out/'controls-macho.s').write_text('\n'.join(lines)+'\n')
subprocess.run(['clang','-dynamiclib',str(out/'controls-macho.s'),'-o',str(out/'controls.dylib')],check=True)
lib=ctypes.CDLL(str(out/'controls.dylib'))
for name, expected in [('varout_control',570.0),('varout_split_control',317.0)]:
    f=getattr(lib,name);f.restype=ctypes.c_double
    got=f()
    print(name, 'expected', expected, 'observed', got)
    if name=='varout_control': assert got==expected
print('Boundary C caller supported:',lib.varout_split_caller_supported())
