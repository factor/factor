#!/usr/bin/env python3
"""Freeze unchanged production live/saved frame walker templates for a gate."""
import hashlib
from pathlib import Path
import sys

source, output = map(Path, sys.argv[1:])
text = (source / "callstack.hpp").read_text()
parts = []
for marker in (
    "template <typename Iterator, typename Fixup>\ninline void factor_vm::iterate_callstack_object",
    "template <typename Iterator, typename Fixup>\nvoid factor_vm::iterate_callstack(",
):
    start = text.index(marker)
    end = text.index("\n// Allocates memory\ntemplate", start)
    parts.append(text[start:end])
data = "\n".join(parts) + "\n"
output.write_text(data)
print(output.name, hashlib.sha256(data.encode()).hexdigest())
