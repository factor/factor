"""Run Windows-generated ABI instructions on macOS; change object syntax only."""
from pathlib import Path
import re
import subprocess
p = Path(__file__).resolve().parent
for args in [[], ['-emit-llvm']]:
    suffix = 'll' if args else 's'
    subprocess.run(['clang', '-target', 'aarch64-pc-windows-msvc', '-S', '-O2', *args,
                    str(p / 'probe.c'), '-o', str(p / ('windows.' + suffix))], check=True)
lines = []
for line in (p / 'windows.s').read_text().splitlines():
    if line.strip().startswith('.section'):
        break
    if line.strip().startswith(('.def', '.scl', '.type', '.endef', '.seh_', '.file')) or '@feat' in line:
        continue
    lines.append(re.sub(r'\balign_(named|return)\b', r'_align_\1', line))
(p / 'macho.s').write_text('\n'.join(lines) + '\n')
subprocess.run(['clang', '-dynamiclib', str(p / 'macho.s'), '-o', str(p / 'probe.dylib')], check=True)
