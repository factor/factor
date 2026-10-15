#!/usr/bin/env python3
"""Mark LLVM ELF output as OpenBSD wxneeded (linker -z wxneeded equivalent).

OpenBSD does not use PT_GNU_STACK; reuse that header for its W^X opt-in.
The VM's mutable code heap requires this plus a wxallowed filesystem.
"""
import argparse, pathlib, struct
p=argparse.ArgumentParser();p.add_argument('binary');a=p.parse_args()
f=pathlib.Path(a.binary);data=bytearray(f.read_bytes());assert data[:4]==b'\x7fELF' and data[5]==1
is64=data[4]==2
phoff=struct.unpack_from('<Q' if is64 else '<I',data,32 if is64 else 28)[0]
size,count=struct.unpack_from('<HH',data,54 if is64 else 42)
for i in range(count):
 off=phoff+i*size;kind=struct.unpack_from('<I',data,off)[0]
 if kind==0x65a3dbe7:break
 if kind==0x6474e551:
  data[off:off+size]=bytes(size);struct.pack_into('<I',data,off,0x65a3dbe7);f.write_bytes(data);break
else:raise SystemExit('ELF has no reusable PT_GNU_STACK header')
