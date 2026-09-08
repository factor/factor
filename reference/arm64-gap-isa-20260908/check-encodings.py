"""Independent Clang oracle for baseline A64 memory ordering and scalar FMA."""
import pathlib
import struct
import subprocess

root = pathlib.Path(__file__).resolve().parent
cases = []
def add(factor, asm):
    cases.append((factor, asm))

for width in (32, 64):
    for t, n, s in ((0, 1, 2), (30, 17, 29), (31, 31, 29)):
        rt = ('X' if width == 64 else 'W') + ('ZR' if t == 31 else str(t))
        rn = 'SP' if n == 31 else f'X{n}'
        rs = 'WZR' if s == 31 else f'W{s}'
        for op in ('LDAR', 'STLR', 'LDXR', 'LDAXR'):
            add(f'{rt} {rn} {op}', f'{op.lower()} {rt}, [{rn}]')
        for op in ('STXR', 'STLXR'):
            add(f'{rs} {rt} {rn} {op}', f'{op.lower()} {rs}, {rt}, [{rn}]')
        if width == 32:
            for suffix in ('B', 'H'):
                for op in ('LDAR', 'STLR', 'LDXR', 'LDAXR'):
                    add(f'{rt} {rn} {op}{suffix}', f'{op.lower()}{suffix.lower()} {rt}, [{rn}]')
                for op in ('STXR', 'STLXR'):
                    add(f'{rs} {rt} {rn} {op}{suffix}', f'{op.lower()}{suffix.lower()} {rs}, {rt}, [{rn}]')
for op in ('STXR', 'STLXR'):
    add(f'WZR X0 SP {op}', f'{op.lower()} wzr, x0, [sp]')
for op in ('DMB', 'DSB'):
    for option in range(16):
        add(f'{option} {op}', f'{op.lower()} #{option}')
add('ISB', 'isb')
add('CLREX', 'clrex')
for prefix in ('S', 'D'):
    for nums in ((0, 1, 2, 3), (31, 31, 31, 31), (30, 17, 29, 11)):
        regs = [f'{prefix}{n}' for n in nums]
        for op in ('FMADD', 'FMSUB', 'FNMADD', 'FNMSUB'):
            add(' '.join(regs) + f' {op}s', op.lower() + ' ' + ', '.join(regs))
# Compiler constant multiplication selection, including aliasing.
for d, n in ((0, 1), (0, 0), (30, 17)):
    for shift in range(1, 12):
        add(f'X{d} X{n} {2**shift + 1} %mul-imm', f'add x{d}, x{n}, x{n}, lsl #{shift}')

for d, n, m in ((0, 1, 2), (0, 0, 1), (0, 1, 0)):
    add(f'X{d} X{n} X{m} %mneg', f'mneg x{d}, x{n}, x{m}')

(root / 'oracle.s').write_text('.text\n' + '\n'.join(a for _, a in cases) + '\n')
subprocess.run(['clang', '-target', 'aarch64-linux-gnu', '-c', str(root / 'oracle.s'), '-o', str(root / 'oracle.o')], check=True)
b = (root / 'oracle.o').read_bytes()
shoff = struct.unpack_from('<Q', b, 40)[0]
ents, num, strings = struct.unpack_from('<HHH', b, 58)
headers = [struct.unpack_from('<IIQQQQIIQQ', b, shoff + i * ents) for i in range(num)]
h = headers[strings]
names = b[h[4]:h[4] + h[5]]
code = next(b[h[4]:h[4] + h[5]] for h in headers if names[h[0]:].split(b'\0')[0] == b'.text')
assert len(code) == len(cases) * 4
base = ['USING: arrays cpu.architecture cpu.arm.64 cpu.arm.64.assembler cpu.arm.64.assembler.registers endian kernel make tools.test namespaces sequences prettyprint system vocabs.loader locals math ;', 'IN: arm64-gap-isa.encodings', 'f restartable-tests? set-global', '<< "cpu.arm.64.assembler" reload "cpu.arm.64" reload >>', 'SYMBOL: mismatches', '0 mismatches set', ':: check-insn ( expected quot -- ) [ quot call( -- ) ] { } make be> expected = [ quot . mismatches [ 1 + ] change ] unless ;']
selected = []
seen = set()
for i, (factor, asm) in enumerate(cases):
    literal = f'0x{code[i*4:i*4+4].hex()}'
    base += [f'! {asm}', f'{literal} [ {factor} ] check-insn']
    op = factor.split()[-1]
    key = (op, factor[0])
    if key not in seen and not op.startswith('%'):
        selected.append(f'{literal} [ {factor} ] test-insn')
        seen.add(key)
base += ['mismatches get .', 'mismatches get zero? 0 1 ? exit']
(root / 'encodings.factor').write_text('\n'.join(base) + '\n')
(root / 'selected-tests.factor').write_text('\n'.join(selected) + '\n')
print(f'{len(cases)} independently assembled cases; {len(set(f.split()[-1] for f, _ in cases))} assembler/backend words')
