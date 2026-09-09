#!/usr/bin/env python3
"""Build the official, checksum-verified SQLite release with optional interfaces."""
import argparse
import hashlib
import io
from pathlib import Path
import subprocess
import sys
import urllib.request
import zipfile

URL = "https://www.sqlite.org/2026/sqlite-amalgamation-3530400.zip"
SHA3 = "628a44cfe82c66aed1ccbbe85a562d2e33ebe64b3288981ed76285612227934e"
OPTIONS = ("SESSION", "PREUPDATE_HOOK", "FTS5", "CARRAY", "COLUMN_METADATA",
           "STMT_SCANSTATUS", "NORMALIZE", "SNAPSHOT")
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--output", required=True, type=Path)
args = parser.parse_args()
out = args.output.resolve()
out.mkdir(parents=True, exist_ok=True)
archive = urllib.request.urlopen(URL).read()
assert hashlib.sha3_256(archive).hexdigest() == SHA3
with zipfile.ZipFile(io.BytesIO(archive)) as source:
    for name in ("sqlite3.c", "sqlite3.h"):
        (out / name).write_bytes(source.read("sqlite-amalgamation-3530400/" + name))
fixture = Path(__file__).with_name("optional.c").resolve()
flags = ["-O1", *["-DSQLITE_ENABLE_" + option for option in OPTIONS], "-I" + str(out)]
mac = sys.platform == "darwin"
# Bind fixture code and data to its SQLite even when another version is loaded.
link_flags = [] if mac else ["-Wl,-z,defs,-Bsymbolic", "-lm", "-ldl", "-pthread"]
library = out / ("libsqlite3-optional.dylib" if mac else "libsqlite3-optional.so")
subprocess.run(["clang", *flags, "-fPIC", "-dynamiclib" if mac else "-shared",
                str(out / "sqlite3.c"), str(fixture), *link_flags, "-o", str(library)], check=True)
subprocess.run(["clang", *flags, "-DOPTIONAL_MAIN", str(fixture), str(library),
                "-o", str(out / "control")], check=True)
subprocess.run([str(out / "control")], check=True)
if not mac:
    loader = out / "loader-control"
    subprocess.run(["clang", str(fixture.with_name("loader.c")), "-ldl", "-o", str(loader)], check=True)
    subprocess.run([str(loader), str(library)], check=True)
print("SQLITE_3534_LIBRARY=" + str(library))
