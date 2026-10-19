#!/usr/bin/env python3
"""Execute Factor-emitted s390x machine code; this is not full port acceptance."""
import argparse
import contextlib
import json
from pathlib import Path
import subprocess
import tempfile


def run(argv, cwd=None):
    subprocess.run(argv, cwd=cwd, check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--factor', type=Path, required=True, help='Working host Factor VM')
    parser.add_argument('--image', type=Path, required=True, help='Matching host boot image')
    parser.add_argument('--cc', default='s390x-linux-gnu-gcc')
    parser.add_argument('--qemu', default='qemu-s390x')
    parser.add_argument('--cxx', default='s390x-linux-gnu-g++')
    parser.add_argument('--zig', type=Path, help='Also verify Zig instruction fields and native bridge')
    parser.add_argument('--output', type=Path, help='Preserve executables and generated programs for native guest checks')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[2]
    factor = [str(args.factor.resolve()), '-i=' + str(args.image.resolve()), '-no-user-init', '-no-monitors']
    setup = 'USING: arrays namespaces sequences vocabs.loader io.files ; ' + json.dumps(str(root / 'basis')) + ' 1array vocab-roots get append vocab-roots set-global ' + json.dumps(str(root / 'core/system/system.factor')) + ' run-file \"cpu.architecture\" reload \"compiler.cfg.builder.alien.params\" reload \"compiler.cfg.builder.alien.boxing\" reload \"classes.struct\" reload '
    tests = root / 'basis/cpu/s390x/assembler/assembler-tests.factor'
    run(factor + ['-e=' + setup + json.dumps(str(tests)) + ' run-file'])
    run(factor + ['-e=' + setup + '\"cpu.architecture\" reload \"cpu.s390x\" require \"compiler.cfg.builder.alien.params\" reload \"compiler.cfg.builder.alien.boxing\" reload \"classes.struct\" reload \"compiler.cfg.builder.alien\" reload ' + json.dumps(str(root / 'basis/compiler/cfg/builder/alien/alien.factor')) + ' run-file ' + json.dumps(str(root / 'basis/cpu/s390x/s390x-tests.factor')) + ' run-file'])
    run(factor + ['-e=' + setup + '\"cpu.s390x\" require ' + json.dumps(str(root / 'basis/cpu/s390x/abi/abi-tests.factor')) + ' run-file'])
    if args.output:
        args.output.mkdir(parents=True, exist_ok=True)
    workspace = contextlib.nullcontext(str(args.output.resolve())) if args.output else tempfile.TemporaryDirectory(prefix='factor-s390x-')
    with workspace as directory:
        out = Path(directory)
        code = 'USING: alien.c-types arrays byte-arrays cpu.architecture compiler.cfg.comparisons cpu.s390x cpu.s390x.assembler cpu.s390x.assembler.registers compiler.codegen.relocation compiler.codegen.labels namespaces math.parser sequences io.encodings.ascii io.encodings.binary io.files kernel make system ;\n'
        programs = {
            'integer': 'R2 R3 AGR R2 R4 MSGR RET',
            'float': 'F0 F2 ADBR F0 F4 MDBR RET',
            'optimizer-integer': 'R2 R2 R3 M\\ s390x %add execute R2 R2 R4 M\\ s390x %mul execute M\\ s390x %return execute',
            'optimizer-float': 'F0 F0 F2 M\\ s390x %add-float execute F0 F0 F4 M\\ s390x %mul-float execute M\\ s390x %return execute',
            'optimizer-min': 'R2 R2 R3 M\\ s390x %min execute RET',
            'optimizer-max': 'R2 R3 R2 M\\ s390x %max execute RET',
            'optimizer-signed-byte': 'R2 R2 0 int-rep \\ char lookup-c-type M\\ s390x %load-memory-imm execute RET',
            'optimizer-unsigned-byte': 'R2 R2 0 int-rep \\ uchar lookup-c-type M\\ s390x %load-memory-imm execute RET',
            'optimizer-slot': 'R2 R2 R3 3 0 M\\ s390x %slot execute RET',
            'optimizer-indexed': 'R2 R2 R3 3 0 int-rep \\ long lookup-c-type M\\ s390x %load-memory execute RET',
            'optimizer-integer-float': 'F0 R2 M\\ s390x %integer>float execute RET',
            'optimizer-displaced-alien': 'R9 R2 LGR R2 R3 0 load-cell R3 R3 8 load-cell R2 R2 R3 R4 f M\\ s390x %box-displaced-alien execute RET',
            'optimizer-displaced-alien-base-alias': 'R9 R2 LGR R2 R3 0 load-cell R3 R3 8 load-cell R3 R2 R3 R4 f M\\ s390x %box-displaced-alien execute R2 R3 LGR RET',
            'optimizer-compare-tagged': '<label> dup R2 5 cc< M\\ s390x %compare-imm-branch execute R2 0 LGHI RET resolve-label R2 1 LGHI RET',
            'optimizer-compare-false': '<label> dup R2 f cc= M\\ s390x %compare-imm-branch execute R2 0 LGHI RET resolve-label R2 1 LGHI RET',
            'optimizer-log2': 'R2 R2 M\\ s390x %log2 execute RET',
            'optimizer-bit-count': 'R2 R2 M\\ s390x %bit-count execute RET',
            'optimizer-float-integer': 'R2 F0 M\\ s390x %float>integer execute RET',
            'optimizer-integer-scalar': 'F0 R2 double-rep M\\ s390x %integer>scalar execute RET',
            'optimizer-scalar-integer': 'R2 F0 double-rep M\\ s390x %scalar>integer execute RET',
            'optimizer-aggregate-integer': 'R15 R0 R15 -16 LAY R14 R0 R15 8 STG \"aggregate-gp\" f f M\\ s390x %c-invoke execute R14 R0 R15 8 LG R15 R0 R15 16 LAY RET',
            'optimizer-aggregate-float': 'R15 R0 R15 -16 LAY R14 R0 R15 8 STG F0 -3.5 M\\ s390x %load-float execute \"aggregate-fp\" f f M\\ s390x %c-invoke execute R14 R0 R15 8 LG R15 R0 R15 16 LAY RET',
            'optimizer-checked-add': '<label> dup R5 R2 R3 cc/o M\\ s390x %fixnum-add execute R5 R0 R4 0 STG R2 0 LGHI RET resolve-label R5 R0 R4 0 STG R2 1 LGHI RET',
            'optimizer-checked-sub': '<label> dup R5 R2 R3 cc/o M\\ s390x %fixnum-sub execute R5 R0 R4 0 STG R2 0 LGHI RET resolve-label R5 R0 R4 0 STG R2 1 LGHI RET',
            'optimizer-checked-mul': '<label> dup R5 R2 R3 cc/o M\\ s390x %fixnum-mul execute R5 R0 R4 0 STG R2 0 LGHI RET resolve-label R5 R0 R4 0 STG R2 1 LGHI RET',
            'optimizer-compare-integer': '<label> dup R2 R3 cc< M\\ s390x %compare-branch execute R2 0 LGHI RET resolve-label R2 1 LGHI RET',
            'optimizer-compare-float': '<label> dup F0 F2 cc< M\\ s390x %compare-float-ordered-branch execute R2 0 LGHI RET resolve-label R2 1 LGHI RET',
            'optimizer-compare-unordered': '<label> dup F0 F2 cc/<>= M\\ s390x %compare-float-unordered-branch execute R2 0 LGHI RET resolve-label R2 1 LGHI RET',
            'optimizer-compare-equal': '<label> dup F0 F2 cc= M\\ s390x %compare-float-unordered-branch execute R2 0 LGHI RET resolve-label R2 1 LGHI RET',
            'optimizer-unbox-pointer': 'R2 R2 M\\ s390x %unbox-any-c-ptr execute RET',
            'optimizer-box-pointer': 'R9 R2 LGR R2 R3 R4 M\\ s390x %box-alien execute RET',
            'optimizer-callback-r6': 'R2 int-rep R6 load-callback-reg RET',
            'optimizer-callback-stack-input': 'R2 int-rep 0 8 load-stack-param RET',
            'optimizer-callback-stack': 'R2 M\\ s390x %callback-stack execute RET',
            'optimizer-variadic-invoke': 'init-relocation R15 R0 R15 -224 LAY R14 R0 R15 216 STG R4 3 LGHI R5 5 LGHI R6 7 LGHI R0 11 LGHI R0 R0 R15 160 STG R0 13 LGHI R0 R0 R15 168 STG F0 0.5 M\\ s390x %load-double execute F2 -3.25 M\\ s390x %load-double execute F4 7.75 M\\ s390x %load-double execute F6 4.5 M\\ s390x %load-double execute F1 8.0 M\\ s390x %load-double execute F1 R0 R15 176 STDY 208 \"oracle-variadic-target\" f f c-invoke-stack R14 R0 R15 216 LG R15 R0 R15 224 LAY RET',
            'optimizer-stack-invoke': 'init-relocation R15 R0 R15 -208 LAY R14 R0 R15 200 STG R4 3 LGHI R5 5 LGHI R6 7 LGHI R0 11 LGHI R0 R0 R15 160 STG R0 13 LGHI R0 R0 R15 168 STG 192 \"oracle-stack-target\" f f c-invoke-stack R14 R0 R15 200 LG R15 R0 R15 208 LAY RET',
            'optimizer-load-double': 'F0 -1.25 M\\ s390x %load-double execute RET',
            'optimizer-load-float': 'F0 3.5 M\\ s390x %load-float execute RET',
            'optimizer-c-invoke': 'init-relocation R15 R0 R15 -16 LAY R14 R0 R15 8 STG \"oracle-target\" f f M\\ s390x %c-invoke execute R14 R0 R15 8 LG R15 R0 R15 16 LAY RET',
            'optimizer-offset-r0': 'R0 R2 LGR R2 R0 19 M\\ s390x %add-imm execute RET',
            'optimizer-offset-r1': 'R1 R2 LGR R2 R1 1048576 M\\ s390x %add-imm execute RET',
            'optimizer-barrier': 'R15 R0 R15 -32 LAY R9 R0 R15 16 STG R9 R2 LGR R3 0 0 R4 R5 M\\ s390x %write-barrier-imm execute R9 R0 R15 16 LG R15 R0 R15 32 LAY RET',
            'optimizer-allot': 'R15 R0 R15 -32 LAY R9 R0 R15 16 STG R9 R2 LGR R2 33 byte-array R3 M\\ s390x %allot execute R9 R0 R15 16 LG R15 R0 R15 32 LAY RET',
            'memory': 'R0 R0 R2 0 LG R0 R3 AGR R0 R0 R2 0 STG R2 R0 LGR RET',
            'branch': 'R2 R3 CGR 10 12 BRCL R2 -1 LGHI RET R2 1 LGHI RET',
        }
        for name, program in programs.items():
            code += 'init-relocation V{ } clone label-table set [ ' + program + ' ] B{ } make ' + json.dumps(str(out / (name + '.bin'))) + ' binary set-file-contents label-table get compute-labels [ number>string ] map \" \" join ' + json.dumps(str(out / (name + '.labels'))) + ' ascii set-file-contents\n'
        script = out / 'generate.factor'
        script.write_text(code)
        run(factor + ['-e=' + setup + json.dumps(str(script)) + ' run-file'])
        run([args.cc, '-O2', '-static', '-o', str(out / 'smoke'), str(root / 'vm/tests/s390x_generated_code.c')])
        run([args.qemu, str(out / 'smoke')], cwd=out)
        run([args.cxx, '-O2', '-static', '-Wall', '-Wextra', '-o', str(out / 'runtime'),
             str(root / 'vm/tests/s390x_runtime.cpp'), str(root / 'vm/tests/s390x_native_call.S'),
             str(root / 'vm/cpu-s390x-trampoline.S')])
        run([args.qemu, str(out / 'runtime')], cwd=out)
        if args.zig:
            zig = str(args.zig.resolve())
            cache = ['--cache-dir', str(out / 'zig-local'), '--global-cache-dir', str(out / 'zig-global')]
            run([zig, 'test', str(root / 'src/s390x.zig'), '-target', 's390x-linux-gnu', '-lc',
                 '--test-no-exec', '-femit-bin=' + str(out / 'zig-fields')] + cache)
            run([args.qemu, '-L', '/usr/s390x-linux-gnu', str(out / 'zig-fields')])
            run([zig, 'build-obj', '-O', 'ReleaseFast', '-target', 's390x-linux-gnu',
                 '-femit-bin=' + str(out / 'zig-bridge.o'), '--dep', 'trampolines', '--dep', 's390x',
                 '-Mroot=' + str(root / 'vm/tests/s390x_zig_bridge.zig'),
                 '-Mtrampolines=' + str(root / 'src/trampolines.zig'),
                 '-Ms390x=' + str(root / 'src/s390x.zig')] + cache)
            run([args.cxx, '-O2', '-static', '-DS390X_ZIG_BRIDGE', '-o', str(out / 'zig-runtime'),
                 str(root / 'vm/tests/s390x_runtime.cpp'), str(root / 'vm/tests/s390x_native_call.S'),
                 str(out / 'zig-bridge.o')])
            run([args.qemu, str(out / 'zig-runtime')], cwd=out)


if __name__ == '__main__':
    main()
