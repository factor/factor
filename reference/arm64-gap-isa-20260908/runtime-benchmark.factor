USING: alien alien.c-types compiler.codegen.labels cpu.arm.64.assembler
cpu.arm.64.assembler.registers io kernel math prettyprint sequences tools.time ;
IN: arm64-gap-isa.runtime-benchmark

: fused-kernel ( seed count -- result )
    ulonglong { ulonglong ulonglong } cdecl [
        X2 3 MOV
        <label> [ resolve-label ] keep
        X0 X0 X2 MNEG
        X1 X1 1 SUBS
        BNE
    ] alien-assembly ;

: separate-kernel ( seed count -- result )
    ulonglong { ulonglong ulonglong } cdecl [
        X2 3 MOV
        <label> [ resolve-label ] keep
        X0 X0 X2 MUL
        X0 X0 NEG
        X1 X1 1 SUBS
        BNE
    ] alien-assembly ;

"Equal wrapped results:" print
1 10000000 fused-kernel 1 10000000 separate-kernel = .
"Interleaved separate/fused times, 10 million dependent multiplies (ns):" print
7 [
    [ 1 10000000 separate-kernel drop ] benchmark .
    [ 1 10000000 fused-kernel drop ] benchmark . flush
] times
