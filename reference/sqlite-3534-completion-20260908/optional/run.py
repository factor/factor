#!/usr/bin/env python3
"""Run optional SQLite tests without changing the checked-in library declaration."""
import argparse
import os
from pathlib import Path
import re
import subprocess
import tempfile

p = argparse.ArgumentParser(description=__doc__)
p.add_argument("--vm", required=True)
p.add_argument("--image", required=True)
p.add_argument("--library", required=True, type=Path)
a = p.parse_args()
root = Path(__file__).resolve().parents[3]
fixture = Path(__file__).parent
with tempfile.TemporaryDirectory(prefix="sqlite-3534-bindings-") as temporary:
    source = (root / "basis/db/sqlite/ffi/ffi.factor").read_text()
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
    command.append(str(fixture / "after.factor"))
    result = subprocess.run(command, cwd=root, env=env)
    raise SystemExit(result.returncode)
