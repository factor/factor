#!/usr/bin/env python3
"""Extract the production frame visitor for a gate with mocked dependencies."""
import hashlib
from pathlib import Path
import sys

source, output = map(Path, sys.argv[1:])
text = (source / "slot_visitor.hpp").read_text()
start = text.index("template <typename Fixup> struct call_frame_slot_visitor")
end = text.index("\ntemplate <typename Fixup>\nvoid slot_visitor", start)
visitor = text[start:end]
output.mkdir(parents=True, exist_ok=True)
name = "production-frame-visitor.hpp"
(output / name).write_text(visitor)
print(name, hashlib.sha256(visitor.encode()).hexdigest())
