#!/usr/bin/env python3
"""Set OpenBSD's required JIT marker on an ELF32 big-endian PA executable.

Upstream GNU hppaobsd ld lacks -z wxneeded. Link with an empty GNU-stack
note (the VM trampoline already supplies one), then reuse that empty program
header for PT_OPENBSD_WXNEEDED. OpenBSD defines this tag in sys/exec_elf.h;
its stack protection does not use the GNU-stack tag. No load segment,
section, instruction, address or relocation changes.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct

GNU_STACK = 0x6474E551
OPENBSD_WXNEEDED = 0x65A3DBE7


def mark(data):
    result = bytearray(data)
    if len(result) < 52 or result[:6] != b"\x7fELF\x01\x02":
        raise ValueError("requires ELF32 big-endian input")
    file_type, machine = struct.unpack_from(">HH", result, 16)
    if machine != 15 or file_type not in (2, 3):
        raise ValueError("requires a PA-RISC executable or PIE")
    offset = struct.unpack_from(">I", result, 28)[0]
    size, count = struct.unpack_from(">HH", result, 42)
    if size != 32 or offset < 52 or offset + size * count > len(result):
        raise ValueError("invalid program header table")
    rows = [(offset + i * size, struct.unpack_from(">8I", result, offset + i * size))
            for i in range(count)]
    if any(row[0] == OPENBSD_WXNEEDED for _, row in rows):
        return bytes(result)
    slots = [(where, row) for where, row in rows if row[0] == GNU_STACK]
    if len(slots) != 1 or any(slots[0][1][i] != 0 for i in range(1, 6)):
        raise ValueError("requires exactly one empty GNU-stack program header")
    struct.pack_into(">8I", result, slots[0][0], OPENBSD_WXNEEDED, 0, 0, 0, 0, 0, 0, 1)
    return bytes(result)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    original = args.input.read_bytes()
    updated = mark(original)
    args.output.write_bytes(updated)
    args.output.chmod(args.input.stat().st_mode & 0o777)
    print(json.dumps({"input": str(args.input), "output": str(args.output),
                      "input_sha256": hashlib.sha256(original).hexdigest(),
                      "output_sha256": hashlib.sha256(updated).hexdigest(),
                      "code_and_data_unchanged": True}))


if __name__ == "__main__":
    main()
