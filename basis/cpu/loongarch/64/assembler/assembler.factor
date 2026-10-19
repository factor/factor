! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators compiler.constants cpu.loongarch.64.assembler.registers
endian kernel locals make math math.bitwise sequences ;
IN: cpu.loongarch.64.assembler
ERROR: invalid-loongarch-immediate value width ;
: insns ( n -- bytes ) 4 * ; inline
: emit-insn ( n -- ) 4 >le % ;
:: signed-immediate ( value width -- bits )
    value width >signed value = [ value width bits ]
    [ value width invalid-loongarch-immediate ] if ;
:: unsigned-immediate ( value width -- bits )
    value width bits value = [ value ]
    [ value width invalid-loongarch-immediate ] if ;
: R ( reg -- n ) n>> ;
: F ( reg -- n ) n>> ;
:: r-insn ( rd rj rk opcode -- )
    rd R rj R 5 shift bitor rk R 10 shift bitor opcode bitor emit-insn ;
:: i-insn ( rd rj imm opcode -- )
    rd R rj R 5 shift bitor imm 12 signed-immediate 10 shift bitor opcode bitor emit-insn ;
:: u-insn ( rd imm opcode -- )
    rd R imm 20 bits 5 shift bitor opcode bitor emit-insn ;
:: shift-insn ( rd rj imm opcode -- )
    rd R rj R 5 shift bitor imm 6 unsigned-immediate 10 shift bitor opcode bitor emit-insn ;
:: b-insn ( rj rd imm opcode -- )
    rd R rj R 5 shift bitor imm 4 /i 16 signed-immediate 10 shift bitor opcode bitor emit-insn ;
: ADD ( rd rj rk -- ) 0x108000 r-insn ;
: SUB ( rd rj rk -- ) 0x118000 r-insn ;
: SLL ( rd rj rk -- ) 0x188000 r-insn ;
: SRL ( rd rj rk -- ) 0x190000 r-insn ;
: SRA ( rd rj rk -- ) 0x198000 r-insn ;
: SLT ( rd rj rk -- ) 0x120000 r-insn ;
: SLTU ( rd rj rk -- ) 0x128000 r-insn ;
: XOR ( rd rj rk -- ) 0x158000 r-insn ;
: OR ( rd rj rk -- ) 0x150000 r-insn ;
: AND ( rd rj rk -- ) 0x148000 r-insn ;
: MUL ( rd rj rk -- ) 0x1d8000 r-insn ;
: MULH ( rd rj rk -- ) 0x1e0000 r-insn ;
: MULHU ( rd rj rk -- ) 0x1e8000 r-insn ;
: DIV ( rd rj rk -- ) 0x220000 r-insn ;
: DIVU ( rd rj rk -- ) 0x230000 r-insn ;
: REM ( rd rj rk -- ) 0x228000 r-insn ;
: REMU ( rd rj rk -- ) 0x238000 r-insn ;
: ADDW ( rd rj rk -- ) 0x100000 r-insn ;
: SUBW ( rd rj rk -- ) 0x110000 r-insn ;
: MULW ( rd rj rk -- ) 0x1c0000 r-insn ;
: DIVW ( rd rj rk -- ) 0x200000 r-insn ;
: DIVUW ( rd rj rk -- ) 0x210000 r-insn ;
: REMW ( rd rj rk -- ) 0x208000 r-insn ;
: REMUW ( rd rj rk -- ) 0x218000 r-insn ;
: SLLW ( rd rj rk -- ) 0x170000 r-insn ;
: SRLW ( rd rj rk -- ) 0x178000 r-insn ;
: SRAW ( rd rj rk -- ) 0x180000 r-insn ;
: ADDI ( rd rj imm -- ) 0x2c00000 i-insn ;
: ADDIW ( rd rj imm -- ) 0x2800000 i-insn ;
: SLTI ( rd rj imm -- ) 0x2000000 i-insn ;
: SLTIU ( rd rj imm -- ) 0x2400000 i-insn ;
: LB ( rd rj imm -- ) 0x28000000 i-insn ;
: LH ( rd rj imm -- ) 0x28400000 i-insn ;
: LW ( rd rj imm -- ) 0x28800000 i-insn ;
: LD ( rd rj imm -- ) 0x28c00000 i-insn ;
: LBU ( rd rj imm -- ) 0x2a000000 i-insn ;
: LHU ( rd rj imm -- ) 0x2a400000 i-insn ;
: LWU ( rd rj imm -- ) 0x2a800000 i-insn ;
: SB ( rd rj imm -- ) 0x29000000 i-insn ;
: SH ( rd rj imm -- ) 0x29400000 i-insn ;
: SW ( rd rj imm -- ) 0x29800000 i-insn ;
: SD ( rd rj imm -- ) 0x29c00000 i-insn ;
: FLW ( rd rj imm -- ) 0x2b000000 i-insn ;
: FLD ( rd rj imm -- ) 0x2b800000 i-insn ;
: FSW ( rd rj imm -- ) 0x2b400000 i-insn ;
: FSD ( rd rj imm -- ) 0x2bc00000 i-insn ;
: LUI ( rd imm -- ) 0x14000000 u-insn ;
: AUIPC ( rd imm -- ) 0x1c000000 u-insn ;
: SLLI ( rd rj imm -- ) 0x410000 shift-insn ;
: SRLI ( rd rj imm -- ) 0x450000 shift-insn ;
: SRAI ( rd rj imm -- ) 0x490000 shift-insn ;
: SLLIW ( rd rj imm -- ) 0x408000 shift-insn ;
: SRLIW ( rd rj imm -- ) 0x448000 shift-insn ;
: SRAIW ( rd rj imm -- ) 0x488000 shift-insn ;
: BEQ ( rj rd imm -- ) 0x58000000 b-insn ;
: BNE ( rj rd imm -- ) 0x5c000000 b-insn ;
: BLT ( rj rd imm -- ) 0x60000000 b-insn ;
: BGE ( rj rd imm -- ) 0x64000000 b-insn ;
: BLTU ( rj rd imm -- ) 0x68000000 b-insn ;
: BGEU ( rj rd imm -- ) 0x6c000000 b-insn ;
:: JALR ( rd rj imm -- ) rj rd imm 0x4c000000 b-insn ;
:: J ( imm -- )
    imm 4 /i 26 signed-immediate :> n
    n 16 bits 10 shift n -16 shift bitor 0x50000000 bitor emit-insn ;
: MV ( rd rs -- ) ZERO OR ;
: RET ( -- ) ZERO RA 0 JALR ;
: JR ( rs -- ) [ ZERO ] dip 0 JALR ;
: NOP ( -- ) ZERO ZERO ZERO OR ;
: NEG ( rd rs -- ) [ ZERO ] dip SUB ;
: NEGW ( rd rs -- ) [ ZERO ] dip SUBW ;
DEFER: LI
:: logical-immediate ( rd rs imm opcode -- )
    rd R rs R 5 shift bitor imm 12 unsigned-immediate 10 shift bitor opcode bitor emit-insn ;
:: ANDI ( rd rs imm -- )
    imm 0 < [
        imm -1 = [ rd rs MV ] [
        imm bitnot dup 1 + bitand zero? rd rs = and
        [ rd R ZERO R 5 shift bitor imm bitnot log2 16 shift bitor 0x00800000 bitor emit-insn ]
        [ IP1 imm LI rd rs IP1 AND ] if ] if
    ] [ rd rs imm 0x03400000 logical-immediate ] if ;
:: ORI ( rd rs imm -- )
    imm 0 < [ IP1 imm LI rd rs IP1 OR ] [ rd rs imm 0x03800000 logical-immediate ] if ;
:: XORI ( rd rs imm -- )
    imm 0 < [ rd rs ZERO 0x00140000 r-insn rd rd imm bitnot 0x03c00000 logical-immediate ]
    [ rd rs imm 0x03c00000 logical-immediate ] if ;
: NOT ( rd rs -- ) ZERO 0x00140000 r-insn ;
: SEQZ ( rd rs -- ) 1 SLTIU ;
: SNEZ ( rd rs -- ) [ ZERO ] dip SLTU ;
: SEXT.W ( rd rs -- ) 0 ADDIW ;
:: CSRR ( rd csr -- ) csr drop rd R 0x0114c800 bitor emit-insn ;
:: CSRW ( csr rs -- ) csr drop rs R 5 shift 0x0114c000 bitor emit-insn ;
:: LI64 ( rd value -- )
    value 64 >signed :> v
    v 12 >signed :> d0
    v d0 - -12 shift :> v1
    v1 12 >signed :> d1
    v1 d1 - -12 shift :> v2
    v2 12 >signed :> d2
    v2 d2 - -12 shift :> high
    high 12 >signed :> d3
    rd high d3 - -12 shift 20 bits LUI rd rd d3 ADDI
    rd rd 12 SLLI rd rd d2 ADDI
    rd rd 12 SLLI rd rd d1 ADDI
    rd rd 12 SLLI rd rd d0 ADDI ;
:: LI ( rd value -- )
    value 12 >signed value = [ rd ZERO value ADDI ] [ rd value LI64 ] if ;
: load-address ( rd -- class ) 0 LI64 rc-native-1 ;
: call-relative ( -- class ) temp 0 AUIPC RA temp 0 JALR rc-native-0 ;
: jump-relative ( -- class ) temp 0 AUIPC ZERO temp 0 JALR rc-native-0 ;

: FADD.D ( fd fj fk -- ) 0x1010000 r-insn ;
: FSUB.D ( fd fj fk -- ) 0x1030000 r-insn ;
: FMUL.D ( fd fj fk -- ) 0x1050000 r-insn ;
: FDIV.D ( fd fj fk -- ) 0x1070000 r-insn ;
: FMIN.D ( fd fj fk -- ) 0x10b0000 r-insn ;
: FMAX.D ( fd fj fk -- ) 0x1090000 r-insn ;
: FADD.S ( fd fj fk -- ) 0x1008000 r-insn ;
: FSUB.S ( fd fj fk -- ) 0x1028000 r-insn ;
: FMUL.S ( fd fj fk -- ) 0x1048000 r-insn ;
: FDIV.S ( fd fj fk -- ) 0x1068000 r-insn ;
: FSQRT.D ( rd rs -- ) [ R ] [ R 5 shift ] bi* bitor 0x1144800 bitor emit-insn ;
: FMV.D ( rd rs -- ) [ R ] [ R 5 shift ] bi* bitor 0x1149800 bitor emit-insn ;
: FMV.S ( rd rs -- ) [ R ] [ R 5 shift ] bi* bitor 0x1149400 bitor emit-insn ;
: FCVT.D.S ( rd rs -- ) [ R ] [ R 5 shift ] bi* bitor 0x1192400 bitor emit-insn ;
: FCVT.S.D ( rd rs -- ) [ R ] [ R 5 shift ] bi* bitor 0x1191800 bitor emit-insn ;
: FMV.D.X ( rd rs -- ) [ R ] [ R 5 shift ] bi* bitor 0x114a800 bitor emit-insn ;
: FMV.W.X ( rd rs -- ) [ R ] [ R 5 shift ] bi* bitor 0x114a400 bitor emit-insn ;
: FMV.X.D ( rd rs -- ) [ R ] [ R 5 shift ] bi* bitor 0x114b800 bitor emit-insn ;
: FMV.X.W ( rd rs -- ) [ R ] [ R 5 shift ] bi* bitor 0x114b400 bitor emit-insn ;
:: FEQ.D ( rd fj fk -- ) fj F 5 shift fk F 10 shift bitor 0xc220000 bitor emit-insn rd R 0x0114dc00 bitor emit-insn ;
:: FLT.D ( rd fj fk -- ) fj F 5 shift fk F 10 shift bitor 0xc218000 bitor emit-insn rd R 0x0114dc00 bitor emit-insn ;
:: FLE.D ( rd fj fk -- ) fj F 5 shift fk F 10 shift bitor 0xc238000 bitor emit-insn rd R 0x0114dc00 bitor emit-insn ;
:: FCVT.D.L ( fd rs rm -- ) rm drop fd rs FMV.D.X fd fd [ R ] [ R 5 shift ] bi* bitor 0x011d2800 bitor emit-insn ;
:: FCVT.L.D ( rd fs rm -- ) rm drop fp-temp fs [ R ] [ R 5 shift ] bi* bitor 0x011aa800 bitor emit-insn rd fp-temp FMV.X.D ;
