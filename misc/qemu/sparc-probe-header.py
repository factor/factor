#!/usr/bin/env python3
"""Pack emitted SPARC probe instructions and relocations as C data."""
import argparse
from pathlib import Path


KINDS = ('callback', 'callstack', 'context', 'delete', 'native-return',
         'pic', 'reset', 'start', 'unwind')


def array(name, values, c_type='unsigned char'):
    return f'static const {c_type} {name}[]={{' + ','.join(map(str, values)) + '};\n'


def records(directory, stem):
    data = (directory / (stem + '.reloc')).read_bytes()
    if len(data) % 4:
        raise ValueError(f'incomplete relocation record: {stem}')
    return [int.from_bytes(data[i:i + 4], 'big') for i in range(0, len(data), 4)]


def header(kind, directory):
    def read(stem):
        return (directory / (stem + '.bin')).read_bytes()

    def wrapped(stem):
        return read('prolog') + read(stem) + read('epilog') + read('return')

    if kind in ('callstack', 'delete', 'reset', 'start', 'unwind'):
        prefix = read('prolog')
        if kind == 'unwind':
            wide = len(read(kind)) > 100
            bias, cell, op = (2047, 8, 14) if wide else (0, 4, 4)

            def store(reg, offset):
                return (0xc0002000 | (reg << 25) | (op << 19) |
                        (9 << 14) | offset).to_bytes(4, 'big')

            prefix += ((0x90162000).to_bytes(4, 'big') +
                       (0x9203a000 + bias).to_bytes(4, 'big') +
                       store(30, 14 * cell) + store(31, 15 * cell))
            code = prefix + read(kind)
        else:
            code = wrapped(kind)
        literals = ','.join((directory / (kind + '.here')).read_text().split())
        return (array(kind + 'code', code) +
                array(kind + 'rel', map(hex, records(directory, kind)), 'unsigned') +
                f'enum{{{kind}_prefix={len(prefix)}}};\n' +
                f'static const unsigned {kind}_literals[]={{' + literals + '};\n')

    if kind == 'context':
        prefix = len(read('prolog'))
        items = records(directory, 'context')
        literal = (directory / 'context.here').read_text()
        tail = records(directory, 'tail')
        assert len(tail) == 1 and tail[0] >> 24 == 0x3f
        return (array('ctxcode', wrapped('context')) +
                f'enum {{ ctx_prefix={prefix}, ctx_here={(items[0] & 0xffffff) + prefix}, '
                f'ctx_fn={(items[1] & 0xffffff) + prefix}, ctx_literal={literal} }};\n' +
                array('tailcode', read('tail')) +
                f'enum {{ tail_fn={tail[0] & 0xffffff} }};\n')

    if kind == 'pic':
        reloc = records(directory, 'hit')
        assert len(reloc) == 1 and reloc[0] >> 24 == 0x1f
        tag = read('tag')
        code = tag + read('hit') + bytes.fromhex('9010200081c3e00801000000')
        return (array('piccode', code) +
                f'enum{{pic_offset={len(tag) + (reloc[0] & 0xffffff)}}};\n')

    if kind == 'native-return':
        prefix = read('prolog')
        code = prefix + read('primitive') + read('observe') + read('epilog') + read('return')
        return (array('gate_code', code) +
                array('gate_rel', records(directory, 'primitive'), 'unsigned') +
                f'enum {{ gate_prefix={len(prefix)} }};\n')

    reloc = records(directory, 'callback')
    result = (array('cbcode', read('callback')) +
              f'enum {{ cb_vm={reloc[0] & 0xffffff}, cb_fn={reloc[1] & 0xffffff} }};\n')
    for name, stem in (('ctfcode', 'c-to-factor'), ('fpuget', 'fpu-get'), ('fpuset', 'fpu-set')):
        result += array(name, wrapped(stem))
    result += array('ctfrel', map(hex, records(directory, 'c-to-factor')), 'unsigned int')
    result += f'enum {{ ctf_prefix={len(read("prolog"))} }};\n'
    for i, stem in enumerate(('call', 'lazy', 'cache', 'cache-tail')):
        code = (read('prolog') + (directory / (stem + '.init')).read_bytes() +
                read('epilog') + (directory / (stem + '.tail')).read_bytes())
        result += array(f'comb{i}', code)
        result += array(f'combrel{i}', map(hex, records(directory, stem)), 'unsigned int')
    result += ('struct comb_probe { const unsigned char *code; unsigned length; '
               'const unsigned int *rel; unsigned count; };\n')
    result += 'static const struct comb_probe combs[]={' + ','.join(
        f'{{comb{i},sizeof comb{i},combrel{i},sizeof combrel{i}/sizeof combrel{i}[0]}}'
        for i in range(4)) + '};\n'
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('kind', choices=KINDS)
    parser.add_argument('directory', type=Path)
    args = parser.parse_args()
    (args.directory / f'sparc-{args.kind}-data.h').write_text(header(args.kind, args.directory))
