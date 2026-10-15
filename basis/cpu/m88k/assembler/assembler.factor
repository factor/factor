! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! 88100 fixed-width big-endian instruction foundation.
! Transfers without .n do not execute a delay slot.
USING: accessors cpu.m88k.assembler.registers endian kernel locals
make math math.bitwise ;
IN: cpu.m88k.assembler
ERROR: invalid-m88k-immediate value width ;
ERROR: invalid-m88k-register reg ;
:: unsigned-immediate ( value width -- bits )
    value width bits value = [ value ] [ value width invalid-m88k-immediate ] if ;
: R ( reg -- n ) dup int-register? [ n>> 5 unsigned-immediate ] [ invalid-m88k-register ] if ;
: emit-insn ( insn -- ) 4 >be % ;
:: fields ( rd rs -- bits ) rd R 21 shift rs R 16 shift bitor ;
:: register-insn ( rd rs rt opcode -- )
    rd rs fields rt R bitor opcode bitor emit-insn ;
:: immediate-insn ( rd rs imm opcode -- )
    rd rs fields imm 16 unsigned-immediate bitor opcode bitor emit-insn ;
: ADDU ( rd rs rt -- ) 0xf4006000 register-insn ;
: SUBU ( rd rs rt -- ) 0xf4006400 register-insn ;
: AND ( rd rs rt -- ) 0xf4004000 register-insn ;
: OR ( rd rs rt -- ) 0xf4005800 register-insn ;
: XOR ( rd rs rt -- ) 0xf4005000 register-insn ;
: CMP ( rd rs rt -- ) 0xf4007c00 register-insn ;
: XMEM ( rd base index -- ) 0xf4000400 register-insn ;
: ADDUI ( rd rs imm -- ) 0x60000000 immediate-insn ;
: SUBUI ( rd rs imm -- ) 0x64000000 immediate-insn ;
: ORI ( rd rs imm -- ) 0x58000000 immediate-insn ;
: ORU ( rd rs imm -- ) 0x5c000000 immediate-insn ;
: LD ( rd base offset -- ) 0x14000000 immediate-insn ;
: ST ( rd base offset -- ) 0x24000000 immediate-insn ;
: JMP ( rs -- ) R 0xf400c000 bitor emit-insn ;
: JMP.N ( rs -- ) R 0xf400c400 bitor emit-insn ;
: JSR ( rs -- ) R 0xf400c800 bitor emit-insn ;
: RET ( -- ) RA JMP ;
:: TB0 ( bit rs vector -- )
    bit 5 unsigned-immediate 21 shift rs R 16 shift bitor
    vector 9 unsigned-immediate bitor 0xf000d000 bitor emit-insn ;
:: TB1 ( bit rs vector -- )
    bit 5 unsigned-immediate 21 shift rs R 16 shift bitor
    vector 9 unsigned-immediate bitor 0xf000d800 bitor emit-insn ;
:: LI32 ( rd value -- )
    value 32 unsigned-immediate drop
    rd ZERO value -16 shift ORU
    rd rd value 16 bits ORI ;

! 88100 double operands occupy adjacent general register pairs.
: FADD.D ( rd rs rt -- ) 0x84002aa0 register-insn ;
: FSUB.D ( rd rs rt -- ) 0x840032a0 register-insn ;
: FMUL.D ( rd rs rt -- ) 0x840002a0 register-insn ;
: FDIV.D ( rd rs rt -- ) 0x840072a0 register-insn ;

! Displacements are signed byte offsets from the branch instruction itself.
:: displacement-bits ( displacement width -- bits )
    displacement 3 bitand zero?
    [ displacement -2 shift dup width >signed =
      [ displacement -2 shift width bits ]
      [ displacement width 2 + invalid-m88k-immediate ] if ]
    [ displacement width 2 + invalid-m88k-immediate ] if ;
:: branch-insn ( displacement opcode -- )
    displacement 26 displacement-bits opcode bitor emit-insn ;
: BR ( displacement -- ) 0xc0000000 branch-insn ;
: BSR ( displacement -- ) 0xc8000000 branch-insn ;
:: bit-branch-insn ( bit rs displacement opcode -- )
    bit 5 unsigned-immediate 21 shift rs R 16 shift bitor
    displacement 16 displacement-bits bitor opcode bitor emit-insn ;
: BB0 ( bit rs displacement -- ) 0xd0000000 bit-branch-insn ;
: BB1 ( bit rs displacement -- ) 0xd8000000 bit-branch-insn ;

! 88100 scalar bitfields; width zero means all remaining source bits.
: MUL ( rd rs rt -- ) 0xf4006c00 register-insn ;
: EXT ( rd rs rt -- ) 0xf4009000 register-insn ;
: EXTU ( rd rs rt -- ) 0xf4009800 register-insn ;
: MAK ( rd rs rt -- ) 0xf400a000 register-insn ;
: EXTI ( rd rs count -- ) 5 unsigned-immediate 0xf0009000 immediate-insn ;
: EXTUI ( rd rs count -- ) 5 unsigned-immediate 0xf0009800 immediate-insn ;
: MAKI ( rd rs count -- ) 5 unsigned-immediate 0xf000a000 immediate-insn ;
: LDB ( rd base offset -- ) 0x1c000000 immediate-insn ;
: LDBU ( rd base offset -- ) 0x0c000000 immediate-insn ;
: LDH ( rd base offset -- ) 0x18000000 immediate-insn ;
: LDHU ( rd base offset -- ) 0x08000000 immediate-insn ;
: STB ( rd base offset -- ) 0x2c000000 immediate-insn ;
: STH ( rd base offset -- ) 0x28000000 immediate-insn ;
: FCMP.D ( rd rs rt -- ) 0x84003a80 register-insn ;
: FLT.D ( rd rs -- ) ZERO swap 0x84002020 register-insn ;
: TRNC.D ( rd rs -- ) ZERO swap 0x84005880 register-insn ;
:: EXTUW ( rd rs width offset -- )
    rd rs width 5 unsigned-immediate 5 shift
    offset 5 unsigned-immediate bitor 0xf0009800 immediate-insn ;
: FMUL.DSS ( rd rs rt -- ) 0x84000020 register-insn ;
: FMUL.SDS ( rd rs rt -- ) 0x84000200 register-insn ;
