#!/usr/bin/env python3
"""Extract an actual stage1 word-call sequence for powerpc_long_call.c.

Usage: extract_powerpc_long_call.py ARCH IMAGE OUTPUT
ARCH is ppc.32, ppc.64, or ppc.64le. The C fixture executes the emitted
sequence after relocating its full address to a target 64MiB away.
"""
import argparse
import struct
from pathlib import Path

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--tail', action='store_true', help='extract the real tail/PIC return-address sequence')
p.add_argument('arch', choices=['ppc.32', 'ppc.64', 'ppc.64le'])
p.add_argument('image', type=Path)
p.add_argument('output', type=Path)
a = p.parse_args()
order = '<' if a.arch == 'ppc.64le' else '>'
raw = a.image.read_bytes()
words = [struct.unpack_from(order + 'I', raw, i)[0]
         for i in range(0, len(raw) - 3, 4)]
load_size = 2 if a.arch == 'ppc.32' else 5
for i in range(load_size, len(words) - 1):
    if (words[i:i + 2] == [0x7d8903a6, 0x4e800420 if a.tail else 0x4e800421]
            and words[i - load_size] & 0xffff0000 == 0x3d800000):
        emitted = words[i - load_size:i + 2]
        if load_size == 5 and emitted[2] != 0x798c07c6:
            continue
        if a.tail:
            prefix = words[i - load_size - 5:i - load_size]
            if prefix[:4] != [0x7c0802a6, 0x429f0005, 0x7cc802a6, 0x7c0803a6]:
                continue
            if prefix[4] != (0x38c6001c if load_size == 2 else 0x38c60028):
                continue
            emitted = prefix + emitted
        count = 12 if a.tail else 7
        a.output.write_bytes(struct.pack(order + str(count) + 'I',
                                        *(emitted + [0] * (count - len(emitted)))))
        print(f'{a.arch}: actual word-call at image byte {4*(i-load_size)}')
        break
else:
    raise SystemExit('image has no full-range PowerPC word-call template')
