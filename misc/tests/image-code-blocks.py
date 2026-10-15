#!/usr/bin/env python3
"""Exercise real image loading with a native, uncompressed image.

Usage: python3 misc/tests/image-code-blocks.py VM IMAGE
The supplied image is read-only; each negative uses a temporary copy with its
original header. VM and IMAGE must have the host's native cell width/endian.
"""
import hashlib
import pathlib
import resource
import shutil
import struct
import subprocess
import sys
import tempfile

resource.setrlimit(resource.RLIMIT_CORE, (0, 0))

vm, image = map(lambda p: pathlib.Path(p).resolve(), sys.argv[1:])
cell = struct.Struct('@P')
with image.open('rb') as stream:
    fields = [cell.unpack(stream.read(cell.size))[0] for _ in range(10)]
assert fields[:2] == [0x0F0E0D0C, 5]
data_size = fields[6] if fields[3] == 0 else fields[3]
code_size = fields[5]
assert fields[3] != 0 or (fields[7] == data_size and fields[8] == code_size), 'uncompressed image required'
# The image header has ten metadata cells and 83 special object cells.
code_offset = (10 + 83) * cell.size + data_size
assert code_size > 64
original_hash = hashlib.sha256(image.read_bytes()).hexdigest()


def run(path, expected=None):
    result = subprocess.run([str(vm), '-i=' + str(path), '-no-user-init',
                             '-e="loader-valid" print'],
                            stdin=subprocess.DEVNULL, capture_output=True,
                            timeout=30)
    output = (result.stdout + result.stderr).decode(errors='replace')
    if expected is None:
        assert result.returncode == 0 and 'loader-valid' in output, output
    else:
        assert result.returncode != 0, output
        assert any(message in output for message in expected), output
    print(path.name, 'PASS', result.returncode)
    if expected:
        print(output.strip())


run(image)
with tempfile.TemporaryDirectory(prefix='factor-image-code-') as directory:
    for name, header, length in [
        ('zero-block', 0, code_size),
        ('oversized-free-block', ((1 << (8 * cell.size)) - 16) | 1, code_size),
        ('short-allocated-block', 16, code_size),
        ('unaligned-block', 40, code_size),
        ('truncated-block', code_size + 16 | 1, code_size),
        ('truncated-payload', None, code_size - 1),
    ]:
        fixture = pathlib.Path(directory) / (name + '.image')
        shutil.copyfile(image, fixture)
        with fixture.open('r+b') as stream:
            if header is not None:
                stream.seek(code_offset)
                stream.write(cell.pack(header))
            else:
                stream.truncate(code_offset + length)
        run(fixture, ('Invalid code block in image', 'InvalidSize') if header is not None
            else ('load_code_heap failed', 'ReadError'))
assert hashlib.sha256(image.read_bytes()).hexdigest() == original_hash
print('Original image unchanged:', original_hash)
