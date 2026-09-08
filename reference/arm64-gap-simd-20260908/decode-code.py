#!/usr/bin/env python3
"""Decode the exact bytes dumped from the live compiled benchmark words.

LLVM continues beyond inline literal data, unlike the default Capstone decoder.
The synthetic object changes addresses, not instruction bytes; inline constants
are also decoded as instructions, so only executable regions are meaningful.
"""
import pathlib
import shutil
import subprocess
import sys
import tempfile

artifact = pathlib.Path(__file__).resolve().parent
prefix = sys.argv[1]
objdump = shutil.which('llvm-objdump') or '/opt/homebrew/opt/llvm/bin/llvm-objdump'
for name in ('signed-loop', 'unsigned-loop', 'conversion-loop'):
    raw = artifact / (name + '.bin')
    destination = artifact / (prefix + '-' + name + '.bin')
    shutil.copyfile(raw, destination)
    with tempfile.TemporaryDirectory() as tmp:
        src, obj = pathlib.Path(tmp) / 'code.s', pathlib.Path(tmp) / 'code.o'
        data = raw.read_bytes()
        src.write_text('.text\n.globl _compiled_word\n.p2align 2\n_compiled_word:\n'
                       + '\n'.join('.byte ' + ','.join(str(b) for b in data[i:i+16])
                                   for i in range(0, len(data), 16)) + '\n')
        subprocess.run(['clang', '-c', '-target', 'arm64-apple-macos', str(src), '-o', str(obj)], check=True)
        result = subprocess.check_output([objdump, '-d', str(obj)], text=True)
        result = result.replace(str(obj), 'live-compiled-word.o')
        (artifact / (prefix + '-' + name + '.disasm')).write_text(result)
    raw.unlink()
