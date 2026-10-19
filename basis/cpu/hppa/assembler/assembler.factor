! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors cpu.hppa.assembler.registers endian kernel locals
make math math.bitwise ;
IN: cpu.hppa.assembler
ERROR: invalid-hppa-immediate value width ;
ERROR: invalid-hppa-register reg ;
:: unsigned-immediate ( value width -- bits )
    value width bits value = [ value ] [ value width invalid-hppa-immediate ] if ;
:: signed-immediate ( value width -- bits )
    value width >signed value = [ value width bits ]
    [ value width invalid-hppa-immediate ] if ;
: R ( reg -- n ) dup int-register? [ n>> 5 unsigned-immediate ] [ invalid-hppa-register ] if ;
: emit-insn ( value -- ) 4 >be % ;
:: encode-21 ( value -- field )
    value 21 unsigned-immediate :> v
    v 0x100000 bitand -20 shift v 0xffe00 bitand -8 shift bitor
    v 0x180 bitand 7 shift bitor v 0x7c bitand 14 shift bitor
    v 3 bitand 12 shift bitor ;
:: encode-14 ( value -- field )
    value 14 signed-immediate :> v
    v 0x1fff bitand 1 shift v -13 shift 1 bitand bitor ;
:: register-insn ( rd lhs rhs opcode -- )
    lhs R 16 shift rhs R 21 shift bitor rd R bitor opcode bitor emit-insn ;
: ADD ( rd lhs rhs -- ) 0x08000600 register-insn ;
: SUB ( rd lhs rhs -- ) 0x08000400 register-insn ;
: AND ( rd lhs rhs -- ) 0x08000200 register-insn ;
: OR ( rd lhs rhs -- ) 0x08000240 register-insn ;
: XOR ( rd lhs rhs -- ) 0x08000280 register-insn ;
: COPY ( rd src -- ) R0 OR ;
:: immediate-insn ( reg base imm opcode -- )
    base R 21 shift reg R 16 shift bitor imm encode-14 bitor opcode bitor emit-insn ;
: LDO ( rd base imm -- ) 0x34000000 immediate-insn ;
: LDI ( rd imm -- ) [ R0 ] dip LDO ;
: LDW ( rd base imm -- ) 0x48000000 immediate-insn ;
: STW ( src base imm -- ) 0x68000000 immediate-insn ;
: LDB ( rd base imm -- ) 0x40000000 immediate-insn ;
: STB ( src base imm -- ) 0x60000000 immediate-insn ;
: LDH ( rd base imm -- ) 0x44000000 immediate-insn ;
: STH ( src base imm -- ) 0x64000000 immediate-insn ;
:: LDIL ( rd value -- )
    rd R 21 shift value encode-21 bitor 0x20000000 bitor emit-insn ;
:: LI ( rd value -- )
    value 32 bits :> v
    rd v -11 shift LDIL rd rd v 0x7ff bitand LDO ;
: NOP ( -- ) 0x08000240 emit-insn ;
: BV ( reg -- ) R 21 shift 0xe800c000 bitor emit-insn ;
: BLE ( reg -- ) R 21 shift 0xe4002000 bitor emit-insn ;
: JUMP ( reg -- ) BV NOP ;
! BLE adds user privilege bits to its link; Factor return PCs are byte addresses.
: CALL ( reg -- ) BLE R2 R31 -3 LDO ;
: RET ( -- ) R2 JUMP ;

! Branch displacement is measured from the instruction, including the
! architectural PC+8 bias. Every caller must emit an explicit delay slot.
:: branch-bits ( displacement width -- bits )
    displacement 3 bitand zero? [ ]
    [ displacement width invalid-hppa-immediate ] if
    displacement 8 - -2 shift width signed-immediate ;
:: encode-12 ( value -- field )
    value 0x800 bitand -11 shift value 0x400 bitand -8 shift bitor
    value 0x3ff bitand 3 shift bitor ;
:: encode-17 ( value -- field )
    value 0x10000 bitand -16 shift value 0xf800 bitand 5 shift bitor
    value 0x400 bitand -8 shift bitor value 0x3ff bitand 3 shift bitor ;
:: compare-branch ( lhs rhs displacement opcode -- )
    lhs R 16 shift rhs R 21 shift bitor
    displacement 12 branch-bits encode-12 bitor opcode bitor emit-insn ;
: BEQ ( lhs rhs displacement -- ) 0x80002000 compare-branch ;
: BNE ( lhs rhs displacement -- ) 0x88002000 compare-branch ;
: BLT ( lhs rhs displacement -- ) 0x80004000 compare-branch ;
: BGE ( lhs rhs displacement -- ) 0x88004000 compare-branch ;
: BLTU ( lhs rhs displacement -- ) 0x80008000 compare-branch ;
: BGEU ( lhs rhs displacement -- ) 0x88008000 compare-branch ;
:: BL ( link displacement -- )
    link R 21 shift displacement 17 branch-bits encode-17 bitor
    0xe8000000 bitor emit-insn ;
: B ( displacement -- ) R0 swap BL ;
:: extract ( rd src position length opcode -- )
    src R 21 shift rd R 16 shift bitor
    position 5 unsigned-immediate 5 shift bitor
    32 length - 5 unsigned-immediate bitor opcode bitor emit-insn ;
: EXTRU ( rd src position length -- ) 0xd0001800 extract ;
: EXTRS ( rd src position length -- ) 0xd0001c00 extract ;
:: ZDEP ( rd src position length -- )
    rd R 21 shift src R 16 shift bitor
    31 position - 5 unsigned-immediate 5 shift bitor
    32 length - 5 unsigned-immediate bitor 0xd4000800 bitor emit-insn ;
:: SLLI ( rd src count -- )
    count 5 unsigned-immediate drop rd src 31 count - 32 count - ZDEP ;
:: SRLI ( rd src count -- )
    count 5 unsigned-immediate drop rd src 31 count - 32 count - EXTRU ;
:: SRAI ( rd src count -- )
    count 5 unsigned-immediate drop rd src 31 count - 32 count - EXTRS ;
: MTSAR ( src -- ) R 16 shift 0x01601840 bitor emit-insn ;
:: VSHD ( rd lhs rhs -- )
    lhs R 16 shift rhs R 21 shift bitor rd R bitor 0xd0000000 bitor emit-insn ;
: F ( reg -- n ) dup fp-register? [ n>> 5 unsigned-immediate ] [ invalid-hppa-register ] if ;
:: float-insn ( rd lhs rhs opcode -- )
    lhs F 21 shift rhs F 16 shift bitor rd F bitor opcode bitor emit-insn ;
: FADD.D ( rd lhs rhs -- ) 0x30000e00 float-insn ;
: FSUB.D ( rd lhs rhs -- ) 0x30002e00 float-insn ;
: FMUL.D ( rd lhs rhs -- ) 0x30004e00 float-insn ;
: FDIV.D ( rd lhs rhs -- ) 0x30006e00 float-insn ;
:: FCOPY.D ( rd src -- ) src F 21 shift rd F bitor 0x30004800 bitor emit-insn ;

:: float-memory ( reg base offset opcode -- )
    offset 5 signed-immediate :> v
    base R 21 shift v 15 bitand 1 shift v -4 shift 1 bitand bitor
    16 shift bitor reg F bitor opcode bitor emit-insn ;
: FLDD ( reg base offset -- ) 0x2c001000 float-memory ;
: FSTD ( reg base offset -- ) 0x2c001200 float-memory ;
: FLDW ( reg base offset -- ) 0x24001000 float-memory ;
: FSTW ( reg base offset -- ) 0x24001200 float-memory ;
: FLDW.R ( reg base offset -- ) 0x24001040 float-memory ;
: FSTW.R ( reg base offset -- ) 0x24001240 float-memory ;
:: float-unary ( rd src opcode -- ) src F 21 shift rd F bitor opcode bitor emit-insn ;
: FCNV-I32.D ( rd src -- ) 0x3000a200 float-unary ;
: FCNV-D.I32 ( rd src -- ) 0x30018a00 float-unary ;
: FCNV-S.D ( rd src -- ) 0x30002200 float-unary ;
: FCNV-D.S ( rd src -- ) 0x30000a00 float-unary ;
: FABS.D ( rd src -- ) 0x30006800 float-unary ;
: XMPYU ( rd lhs rhs -- ) 0x38004700 float-insn ;
:: FCMP.D ( lhs rhs condition -- )
    lhs F 21 shift rhs F 16 shift bitor condition 5 unsigned-immediate bitor
    0x30000c00 bitor emit-insn ;
: FTEST ( -- ) 0x30002420 emit-insn ;

:: variable-extract ( rd src length opcode -- )
    src R 21 shift rd R 16 shift bitor
    32 length - 5 unsigned-immediate bitor opcode bitor emit-insn ;
: VEXTRU ( rd src length -- ) 0xd0001000 variable-extract ;
: VEXTRS ( rd src length -- ) 0xd0001400 variable-extract ;
:: ZVDEP ( rd src length -- )
    rd R 21 shift src R 16 shift bitor
    32 length - 5 unsigned-immediate bitor 0xd4000000 bitor emit-insn ;
: MFSAR ( rd -- ) R 0x016008a0 bitor emit-insn ;
