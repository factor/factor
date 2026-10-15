#!/usr/bin/env python3
"""Freeze the unchanged production frame visitor and GC-info source for a gate."""
import hashlib
from pathlib import Path
import sys

source, output = map(Path, sys.argv[1:])
text = (source / "slot_visitor.hpp").read_text()
start = text.index("template <typename Fixup> struct call_frame_slot_visitor")
end = text.index("\ntemplate <typename Fixup>\nvoid slot_visitor", start)
visitor = text[start:end]
output.mkdir(parents=True, exist_ok=True)
for name, data in (("production-frame-visitor.hpp", visitor),
                   ("production-gc-info.hpp", (source / "gc_info.hpp").read_text())):
    (output / name).write_text(data)
    print(name, hashlib.sha256(data.encode()).hexdigest())
