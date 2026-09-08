"""Independent Clang oracle for baseline A64 integer instruction encodings."""
import pathlib
import struct
import subprocess

root = pathlib.Path(__file__).resolve().parent
cases = []

def add(factor, asm):
    cases.append((factor, asm))

def reg(width, n):
    return ('X' if width == 64 else 'W') + ('ZR' if n == 31 else str(n))

for width in (32, 64):
    for nums in ((0, 1, 2, 3), (30, 17, 29, 11), (31, 31, 31, 31)):
        d, n, m, a = [reg(width, i) for i in nums]
        for op in 'ADC ADCS SBC SBCS UDIV SDIV ADD ADDS SUB SUBS AND BIC ORR ORN EOR EON ANDS BICS'.split():
            add(f'{d} {n} {m} {op}', f'{op.lower()} {d}, {n}, {m}')
        for op in 'NGC NGCS NEG NEGS MVN RBIT REV16 REV CLZ CLS'.split():
            add(f'{d} {n} {op}', f'{op.lower()} {d}, {n}')
        if width == 64:
            add(f'{d} {n} REV32', f'rev32 {d}, {n}')
        for op in 'MADD MSUB'.split():
            add(f'{d} {n} {m} {a} {op}', f'{op.lower()} {d}, {n}, {m}, {a}')
        for op in 'MUL MNEG'.split():
            add(f'{d} {n} {m} {op}', f'{op.lower()} {d}, {n}, {m}')
        for op in 'LSL LSR ASR ROR'.split():
            add(f'{d} {n} {m} {op}', f'{op.lower()} {d}, {n}, {m}')
            for shift in (0, 1, width - 1):
                add(f'{d} {n} {shift} {op}', f'{op.lower()} {d}, {n}, #{shift}')
        for shift in (0, 1, width - 1):
            add(f'{d} {n} {m} {shift} EXTR', f'extr {d}, {n}, {m}, #{shift}')
        for op in 'SBFM BFM UBFM'.split():
            for immr in (0, 1, width - 1):
                for imms in (0, 1, width - 1):
                    add(f'{d} {n} {immr} {imms} {op}', f'{op.lower()} {d}, {n}, #{immr}, #{imms}')
        for op in 'SBFX UBFX BFXIL SBFIZ UBFIZ BFI'.split():
            for lsb, bits in ((0, width), (0, 1), (1, width - 1), (width - 1, 1)):
                add(f'{d} {n} {lsb} {bits} {op}', f'{op.lower()} {d}, {n}, #{lsb}, #{bits}')
        for op in 'CSEL CSINC CSINV CSNEG'.split():
            for cond in ('EQ', 'NE', 'LT', 'GT', 'AL', 'NV'):
                add(f'{d} {n} {m} {cond} {op}', f'{op.lower()} {d}, {n}, {m}, {cond}')
        for op in 'CCMN CCMP'.split():
            for cond in ('EQ', 'NE', 'LT', 'GT', 'AL', 'NV'):
                for flags in (0, 5, 15):
                    add(f'{n} {m} {flags} {cond} {op}', f'{op.lower()} {n}, {m}, #{flags}, {cond}')
                    for imm in (0, 1, 31):
                        add(f'{n} {imm} {flags} {cond} {op}', f'{op.lower()} {n}, #{imm}, #{flags}, {cond}')
        for op in 'MOVN MOVZ MOVK'.split():
            for hw in range(width // 16):
                for imm in (0, 1, 65535):
                    add(f'{d} {imm} {hw} {op}', f'{op.lower()} {d}, #{imm}, lsl #{hw * 16}')
        for op in 'AND ORR EOR ANDS'.split():
            for imm in (1, 0xff, 0xff00ff00 if width == 32 else 0xff00ff00ff00ff00, -2, -16):
                # Logical-immediate destinations use SP rather than ZR (except ANDS).
                dest = d if nums[0] != 31 or op == 'ANDS' else ('SP' if width == 64 else 'WSP')
                add(f'{dest} {n} {imm} {op}', f'{op.lower()} {dest}, {n}, #{imm & ((1 << width) - 1)}')
        for op in 'ADD ADDS SUB SUBS AND BIC ORR ORN EOR EON ANDS BICS'.split():
            for shiftkind in ('LSL', 'LSR', 'ASR', 'ROR'):
                if op in ('ADD', 'ADDS', 'SUB', 'SUBS') and shiftkind == 'ROR':
                    continue
                for shift in (0, 1, width - 1):
                    add(f'{d} {n} {m} {shift} <{shiftkind}> {op}', f'{op.lower()} {d}, {n}, {m}, {shiftkind} #{shift}')
    for op in 'ADD ADDS SUB SUBS'.split():
        for ext in 'UXTB UXTH UXTW SXTB SXTH SXTW UXTX SXTX'.split():
            if width == 32 and ext.endswith('X'):
                continue
            for shift in (0, 4):
                for dest in (reg(width, 0), 'SP' if width == 64 else 'WSP'):
                    if op.endswith('S') and dest in ('SP', 'WSP'):
                        dest = reg(width, 31)
                    src = 'SP' if width == 64 else 'WSP'
                    m = reg(64 if ext.endswith('X') else 32, 2)
                    add(f'{dest} {src} {m} {shift} <{ext}> {op}', f'{op.lower()} {dest}, {src}, {m}, {ext} #{shift}')
for nums in ((0, 1, 2, 3), (30, 17, 29, 11), (31, 31, 31, 31)):
    d, a = [reg(64, nums[i]) for i in (0, 3)]
    n, m = [reg(32, nums[i]) for i in (1, 2)]
    for op in 'SMADDL SMSUBL UMADDL UMSUBL'.split():
        add(f'{d} {n} {m} {a} {op}', f'{op.lower()} {d}, {n}, {m}, {a}')
    for op in 'SMULLs SMNEGL UMULLs UMNEGL'.split():
        add(f'{d} {n} {m} {op}', f'{op.rstrip("s").lower()} {d}, {n}, {m}')
    for op in ('SMULH', 'UMULH'):
        n, m = [reg(64, nums[i]) for i in (1, 2)]
        add(f'{d} {n} {m} {op}', f'{op.lower()} {d}, {n}, {m}')

# Every distinct encodable logical immediate at each register width.
for width in (32, 64):
    masks = set()
    for bits in (2, 4, 8, 16, 32, 64):
        if bits > width:
            continue
        for ones in range(1, bits):
            for rotation in range(bits):
                element = (1 << ones) - 1
                element = ((element >> rotation) | (element << (bits - rotation))) & ((1 << bits) - 1)
                masks.add(sum(element << i for i in range(0, width, bits)))
    for mask in sorted(masks):
        d, n = reg(width, 13), reg(width, 27)
        add(f'{d} {n} {mask} AND', f'and {d}, {n}, #{mask}')

for width in (32, 64):
    for bit in (0, 5, 31) + ((32, 63) if width == 64 else ()):
        for offset in (-32768, -4, 0, 4, 32764):
            for op in ('TBZ', 'TBNZ'):
                r = reg(width, 30)
                add(f'{r} {bit} {offset} {op}', f'{op.lower()} {r}, #{bit}, #{offset}')
for cond in ('EQ', 'NE', 'HS', 'LO', 'MI', 'PL', 'VS', 'VC', 'HI', 'LS', 'GE', 'LT', 'GT', 'LE', 'AL', 'NV'):
    for offset in (-1048576, -4, 0, 4, 1048572):
        add(f'{offset} {cond} B.cond', f'b.{cond.lower()} #{offset}')

(root / 'oracle.s').write_text('.text\n' + '\n'.join(a for _, a in cases) + '\n')
subprocess.run(['clang', '-target', 'aarch64-linux-gnu', '-c', str(root / 'oracle.s'), '-o', str(root / 'oracle.o')], check=True)
b = (root / 'oracle.o').read_bytes()
shoff = struct.unpack_from('<Q', b, 40)[0]
ents, num, strings = struct.unpack_from('<HHH', b, 58)
headers = [struct.unpack_from('<IIQQQQIIQQ', b, shoff + i * ents) for i in range(num)]
h = headers[strings]
names = b[h[4]:h[4] + h[5]]
for h in headers:
    if names[h[0]:].split(b'\0')[0] == b'.text':
        code = b[h[4]:h[4] + h[5]]
assert len(code) == len(cases) * 4
lines = ['USING: arrays cpu.arm.64.assembler cpu.arm.64.assembler.registers endian kernel make tools.test namespaces sequences prettyprint system vocabs.loader locals math ;', 'IN: arm64-audit.encodings', 'f restartable-tests? set-global', '<< "cpu.arm.64.assembler" reload >>', 'SYMBOL: mismatches', '0 mismatches set', ':: check-insn ( n quot -- ) [ quot call( -- ) ] { } make be> n = [ quot . mismatches [ 1 + ] change ] unless ;']
selected = []
seen = set()
new = set('ADC ADCS SBC SBCS NGC NGCS REV16 REV32 REV EXTR ROR BFXIL BFI CCMN CCMP MNEG SMADDL SMSUBL UMADDL UMSUBL SMULLs SMNEGL UMULLs UMNEGL'.split())
for i, (f, a) in enumerate(cases):
    literal = f'0x{code[i*4:i*4+4].hex()}'
    lines += [f'! {a}', f'{literal} [ {f} ] check-insn']
    op = f.split()[-1]
    key = (op, f[0], 'imm' if op in ('CCMN', 'CCMP', 'ROR') and f.split()[1 if op.startswith('CC') else 2].isdigit() else 'reg')
    if op in new and key not in seen:
        selected.append(f'{literal} [ {f} ] test-insn')
        seen.add(key)
lines += ['mismatches get .', 'mismatches get zero? 0 1 ? exit']
(root / 'encodings.factor').write_text('\n'.join(lines) + '\n')
(root / 'selected-tests.factor').write_text('\n'.join(selected) + '\n')
print(f'{len(cases)} independently assembled cases; {len(set(f.split()[-1] for f, _ in cases))} assembler words')
