#!/usr/bin/env python3
"""Qualify Factor against an independent native ARM64 C compiler's fixtures."""
import argparse
from pathlib import Path
import platform
import subprocess
import sys
import tempfile


def run(command, root):
    print("+", " ".join(map(str, command)), flush=True)
    subprocess.run(list(map(str, command)), cwd=root, check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cc", required=True)
    parser.add_argument("--require-small", action="store_true")
    parser.add_argument("--factor", type=Path)
    parser.add_argument("--image", type=Path)
    args = parser.parse_args()
    root = Path(__file__).resolve().parent.parent
    windows = platform.system() == "Windows"
    macos = platform.system() == "Darwin"
    factor = (args.factor or root / ("factor.com" if windows else "factor")).resolve()
    image = (args.image or root / "factor.image").resolve()
    library = root / ("libfactor-ffi-test.dll" if windows else
                      "libfactor-ffi-test.dylib" if macos else
                      "libfactor-ffi-test.so")
    with tempfile.TemporaryDirectory(prefix="factor-varargs-") as temp:
        temp = Path(temp)
        control = temp / ("controls.exe" if windows else "controls")
        if windows:
            common = [args.cc, "/nologo", "/O2", "/TC"]
            if "clang" in Path(args.cc).name.lower():
                common += ["--target=aarch64-pc-windows-msvc"]
            run(common + ["/LD", "vm/ffi_test.c", f"/Fo{temp / 'ffi.obj'}",
                          "/link", "/DEF:vm/ffi_test.def", f"/OUT:{library}",
                          f"/IMPLIB:{temp / 'ffi.lib'}"], root)
            run(common + ["/DFACTOR_VARARGS_CONTROL_MAIN",
                          "vm/ffi_test_varargs.c", f"/Fo{temp / 'controls.obj'}",
                          f"/Fe{control}"], root)
        else:
            common = [args.cc, "-std=c11", "-O2"]
            run(common + ["-fPIC", "-dynamiclib" if macos else "-shared",
                          "vm/ffi_test.c", "-lm", "-o", library], root)
            run(common + ["-Wall", "-Wextra", "-Werror",
                          "-DFACTOR_VARARGS_CONTROL_MAIN",
                          "vm/ffi_test_varargs.c", "-o", control], root)
        run([control], root)
        flags = [f"-i={image}", f"-resource-path={root}", "-no-user-init", "-no-monitors"]
        if args.require_small:
            flags.append("-require-varargs-small")
        for portable in (False, True):
            run([factor, *flags,
                 *(["-disable-neon-extensions"] if portable else []),
                 ".github/arm64-varargs-tests.factor"], root)
        run([sys.executable, "reference/arm64-varargs-20260908/check-printf.py",
             "--factor", factor, "--image", image, "--root", root], root)


if __name__ == "__main__":
    main()
