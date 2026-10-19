#!/usr/bin/env python3
"""Prepare a private Zig library with FreeBSD ARM entry-CFA termination."""
import errno
import os
import pathlib
import shutil
import sys

source, output = map(pathlib.Path, sys.argv[1:])
def copy_link(src, dst):
    try:
        return os.link(src, dst)
    except OSError as error:
        if error.errno != errno.EXDEV:
            raise
        return shutil.copy2(src, dst)


shutil.copytree(source, output, dirs_exist_ok=True, copy_function=copy_link)
path = output / "std/debug/Dwarf/SelfUnwinder.zig"
old = """            const ptr = try regNative(&unwinder.cpu_state, ro.register);
            break :cfa try applyOffset(@intCast(ptr.*), ro.offset);"""
new = """            const ptr = try regNative(&unwinder.cpu_state, ro.register);
            // FreeBSD ARM crt1 can restore a null entry-frame pointer while
            // its saved LR still points into __start. There is no caller.
            if (builtin.os.tag == .freebsd and builtin.cpu.arch == .arm and
                ro.register == 11 and ptr.* == 0) return 0;
            break :cfa try applyOffset(@intCast(ptr.*), ro.offset);"""
text = path.read_text()
if text.count(old) != 1:
    raise SystemExit("unsupported Zig SelfUnwinder: expected CFA rule missing")
path.unlink()  # Break the hard link before modifying the private copy.
path.write_text(text.replace(old, new))
