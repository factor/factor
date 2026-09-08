#!/usr/bin/env python3
"""Compare numeric Linux binding constants/enumerators with native headers."""
import argparse
import json
import pathlib
import re
import subprocess
from signatures import FACTOR, HEADERS

FILES = [
    "basis/unix/ffi/ffi.factor", "basis/unix/ffi/linux/linux.factor",
    "basis/unix/linux/epoll/epoll.factor", "basis/unix/linux/inotify/inotify.factor",
    "basis/unix/process/process.factor", "basis/unix/scheduler/linux/linux.factor",
    "basis/unix/statvfs/linux/linux.factor", "basis/libc/linux/linux.factor",
    "basis/linux/input-events/ffi/ffi.factor", "extra/io/serial/linux/ffi/ffi.factor",
]

def main():
    p = argparse.ArgumentParser()
    p.add_argument("root", type=pathlib.Path)
    p.add_argument("output", type=pathlib.Path)
    args = p.parse_args()
    root, out = args.root.resolve(), args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    includes = "#define _GNU_SOURCE 1\n" + "".join(f"#include <{h}>\n" for h in (HEADERS + " limits.h sys/param.h errno.h termios.h linux/input.h").split())
    macros = subprocess.run(["c++", "-E", "-dM", "-x", "c++", "-"], input=includes, text=True, capture_output=True, check=True).stdout
    names = set(re.findall(r"^#define (\w+)\s", macros, re.M))
    entries = []
    for file in FILES:
        source = re.sub(r"!.*", "", (root / file).read_text())
        vocab = re.search(r"IN:\s+(\S+)", source)[1]
        words = re.findall(r"(?:CONSTANT:|ALIAS:)\s+([A-Z]\w+)", source)
        # Only this file's ENUM entries are numeric C preprocessor constants.
        if "input-events" in file:
            words += re.findall(r"\{\s+([A-Z]\w+)\s+0[xo]?[0-9a-fA-F]+\s*\}", source)
        entries += [(vocab, word, file) for word in words]
    entries = list(dict.fromkeys(entries))
    available = [e for e in entries if e[1] in names]
    missing = [e for e in entries if e[1] not in names]
    cpp = includes + "#include <iostream>\nint main() {\n" + "".join(
        f'std::cout << "{name} " << (long long)({name}) << "\\n";\n' for name in sorted({e[1] for e in available})) + "}\n"
    (out / "constants.cpp").write_text(cpp)
    subprocess.run(["c++", str(out / "constants.cpp"), "-o", str(out / "constants")], check=True)
    native = subprocess.check_output([str(out / "constants")], text=True)
    (out / "native-constants.txt").write_text(native)
    factor = FACTOR + '\nUSING: alien.enums ;\n{ ' + " ".join(json.dumps(v) for v in sorted({e[0] for e in available})) + ' } [ require ] each\n'
    for vocab, word, _ in available:
        factor += f'{json.dumps(word)} {json.dumps(vocab)} lookup-word execute( -- value ) enum>number >json print\n'
    (out / "constants.factor").write_text(factor)
    result = subprocess.run([str(root / "factor"), "-q", "-no-user-init", str(out / "constants.factor")], cwd=root, text=True, capture_output=True)
    (out / "factor-constants.log").write_text(result.stdout + result.stderr)
    if result.returncode:
        raise SystemExit("Factor constants probe failed")
    c = {name: int(value) for name, value in map(str.split, native.splitlines())}
    rows = [json.loads(line) for line in result.stdout.splitlines() if re.fullmatch(r"-?\d+", line)]
    mismatches = [{"vocab": v, "word": w, "factor": row, "native": c[w], "file": f} for (v, w, f), row in zip(available, rows, strict=True) if row != c[w]]
    report = {"checked": len(rows), "mismatches": mismatches, "not_in_headers": missing}
    (out / "constant-results.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))
    raise SystemExit(bool(mismatches))

if __name__ == "__main__":
    main()
