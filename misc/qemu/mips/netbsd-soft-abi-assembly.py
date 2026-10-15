#!/usr/bin/env python3
"""Wrap the emitted BE N64 bytes in a soft-ABI ELF assembly source."""
import argparse
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('directory', type=Path)
args = parser.parse_args()
names = ['soft-outgoing', 'hard-outgoing', 'soft-callback', 'hard-callback',
         'soft-pair', 'hard-pair', 'soft-float-outgoing', 'soft-float-callback',
         'soft-variadic-outgoing', 'soft-float-pair', 'soft-unary-double', 'soft-unary-float']
assembly = ['.module softfloat', '.abicalls', '.option pic0', '.set noreorder', '.set mips3', '.text']
for name in names:
    data = (args.directory / (name + '.bin')).read_bytes()
    assert data and len(data) % 4 == 0, name
    symbol = name.replace('-', '_')
    assembly.extend(['.align 3', '.globl ' + symbol, '.ent ' + symbol, symbol + ':'])
    assembly.extend('.byte ' + ','.join(map(str, data[i:i+16])) for i in range(0, len(data), 16))
    assembly.append('.end ' + symbol)
(args.directory / 'netbsd-soft-abi-generated.S').write_text('\n'.join(assembly) + '\n')
