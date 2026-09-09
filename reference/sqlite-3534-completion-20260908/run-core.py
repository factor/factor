#!/usr/bin/env python3
"""Run SQLite core pointer tests without changing the checked-in library declaration."""
import argparse
import os
from pathlib import Path
import re
import subprocess
import tempfile
import sys
import time

p = argparse.ArgumentParser(description=__doc__)
p.add_argument("--vm", required=True)
p.add_argument("--image", required=True)
p.add_argument("--library", required=True, type=Path)
p.add_argument("--baseline", action="store_true")
p.add_argument("--regressions", action="store_true")
a = p.parse_args()
root = Path(__file__).resolve().parents[2]
fixture = Path(__file__).parent
with tempfile.TemporaryDirectory(prefix="sqlite-3534-bindings-") as temporary:
    source = (root / "basis/db/sqlite/ffi/ffi.factor").read_text()
    if a.baseline:
        source = (fixture / "baseline-ffi.factor").read_text()
    # A distinct library name also invalidates machine code cached in the image.
    library_path = str(a.library.resolve())
    if '"' in library_path or '\\' in library_path:
        raise ValueError("Library path must not contain quotes or backslashes")
    stanza = ('<< "sqlite3534" "' + library_path + '" cdecl add-library >>\n'
              'LIBRARY: sqlite3534')
    source, replacements = re.subn(r'C-LIBRARY: sqlite \{.*?\n\}', stanza, source, count=1, flags=re.S)
    assert replacements == 1
    source = source.replace("LIBRARY: sqlite\n", "LIBRARY: sqlite3534\n")
    bindings = Path(temporary) / "ffi.factor"
    bindings.write_text(source)
    env = dict(os.environ, SQLITE_3534_LIBRARY=library_path, SQLITE_3534_BINDINGS=str(bindings))
    command = [a.vm, "-i=" + a.image, "-resource-path=" + str(root), "-no-user-init"]
    command.append(str(fixture / ("run-baseline.factor" if a.baseline else "run-regressions.factor" if a.regressions else "run-core.factor")))
    process = subprocess.Popen(command, cwd=root, env=env)
    if sys.platform == "darwin":
        time.sleep(1)
        subprocess.run(["taskpolicy", "-B", "-p", str(process.pid)], check=False)
    raise SystemExit(process.wait())
