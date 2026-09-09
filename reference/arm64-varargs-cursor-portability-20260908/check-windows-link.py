#!/usr/bin/env python3
"""Check the UCRT import contract; this does not execute Windows code."""
import hashlib
from pathlib import Path
import re
import subprocess
import urllib.request

root = Path(__file__).resolve().parent
url = ("https://raw.githubusercontent.com/mingw-w64/mingw-w64/master/"
       "mingw-w64-crt/lib-common/ucrtbase-common.def.in")
exports = urllib.request.urlopen(url).read()
lines = exports.decode().splitlines()
assert "__stdio_common_vsprintf" in lines
assert not re.search(r"\bvsnprintf\b", exports.decode())
(root / "export-source.log").write_text(
    f"Source: {url}\nSHA256: {hashlib.sha256(exports).hexdigest()}\n"
    "vsnprintf: absent\n__stdio_common_vsprintf: present\n")
(root / "ucrt-vsnprintf.def").write_text(
    'LIBRARY "ucrtbase.dll"\nEXPORTS\n__stdio_common_vsprintf\n')
llvm = Path("/opt/homebrew/opt/llvm/bin")
subprocess.run([llvm / "llvm-dlltool", "-m", "arm64", "-d",
                root / "ucrt-vsnprintf.def", "-l", root / "ucrt.lib"], check=True)
for name in ("before", "after"):
    subprocess.run(["clang", "-target", "aarch64-pc-windows-msvc", "-O2",
                    "-c", root / f"windows-{name}.c", "-o", root / f"{name}.obj"],
                   check=True)
    result = subprocess.run(["/opt/homebrew/bin/lld-link", "/dll", "/noentry",
                             "/nodefaultlib", root / f"{name}.obj", root / "ucrt.lib",
                             f"/out:{root / (name + '.dll')}"],
                            capture_output=True, text=True)
    (root / f"windows-{name}.log").write_text(result.stdout + result.stderr)
    assert (result.returncode != 0) == (name == "before")
    if name == "before":
        assert "undefined symbol: vsnprintf" in result.stderr
imports = subprocess.check_output([llvm / "llvm-readobj", "--coff-imports",
                                  "--coff-exports", root / "after.dll"], text=True)
(root / "windows-imports.log").write_text(imports)
assert "__stdio_common_vsprintf" in imports
assert "va_vsnprintf_pointer" in imports
print("Direct symbol fails to link; exported pointer path links without vsnprintf.")
