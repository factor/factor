! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Motorola 68020 instruction encoding. Numeric register indices are 0..7.
USING: endian kernel locals make math math.bitwise ;
IN: cpu.m68k.assembler
ERROR: invalid-m68k-register register ;
ERROR: invalid-m68k-immediate value width ;
:: register-number ( reg -- n )
    reg 0 >= reg 8 < and [ reg ] [ reg invalid-m68k-register ] if ;
:: signed-immediate ( value width -- bits )
    value width >signed value = [ value width bits ]
    [ value width invalid-m68k-immediate ] if ;
: emit-word ( n -- ) 2 >be % ;
: emit-long ( n -- ) 4 >be % ;
: NOP ( -- ) 0x4e71 emit-word ;
: RTS ( -- ) 0x4e75 emit-word ;
:: MOVEQ ( value dn -- )
    value 8 signed-immediate dn register-number 9 shift bitor
    0x7000 bitor emit-word ;
:: MOVE.L ( src dst -- )
    src register-number dst register-number 9 shift bitor
    0x2000 bitor emit-word ;
:: MOVEI.L ( value dn -- )
    dn register-number 9 shift 0x203c bitor emit-word value emit-long ;
:: ADD.L ( src dst -- )
    src register-number dst register-number 9 shift bitor
    0xd080 bitor emit-word ;
:: SUB.L ( src dst -- )
    src register-number dst register-number 9 shift bitor
    0x9080 bitor emit-word ;
:: AND.L ( src dst -- )
    src register-number dst register-number 9 shift bitor
    0xc080 bitor emit-word ;
:: OR.L ( src dst -- )
    src register-number dst register-number 9 shift bitor
    0x8080 bitor emit-word ;
:: CMP.L ( src dst -- )
    src register-number dst register-number 9 shift bitor
    0xb080 bitor emit-word ;
:: JSR ( address -- ) 0x4eb9 emit-word address emit-long ;
:: JMP ( address -- ) 0x4ef9 emit-word address emit-long ;
:: LINK ( an displacement -- )
    an register-number 0x4e50 bitor emit-word
    displacement 16 signed-immediate emit-word ;
: UNLK ( an -- ) register-number 0x4e58 bitor emit-word ;
! Always emit word-displacement branches, avoiding byte zero/ff sentinels.
:: Bcc ( displacement condition -- )
    condition 0 >= condition 16 < and [ ]
    [ condition 4 invalid-m68k-immediate ] if
    condition 8 shift 0x6000 bitor emit-word
    displacement 16 signed-immediate emit-word ;
: BRA ( displacement -- ) 0 Bcc ;
: BSR ( displacement -- ) 1 Bcc ;
: BEQ ( displacement -- ) 7 Bcc ;
: BNE ( displacement -- ) 6 Bcc ;
:: LOAD.L ( an displacement dn -- )
    an register-number dn register-number 9 shift bitor
    0x2028 bitor emit-word displacement 16 signed-immediate emit-word ;
:: STORE.L ( dn an displacement -- )
    an register-number 9 shift dn register-number bitor
    0x2140 bitor emit-word displacement 16 signed-immediate emit-word ;
:: MOVEA.L ( dn an -- )
    dn register-number an register-number 9 shift bitor
    0x2040 bitor emit-word ;
:: MOVEAI.L ( value an -- )
    an register-number 9 shift 0x207c bitor emit-word value emit-long ;
:: LEA ( src displacement dst -- )
    src register-number dst register-number 9 shift bitor
    0x41e8 bitor emit-word displacement 16 signed-immediate emit-word ;
: JSRA ( an -- ) register-number 0x4e90 bitor emit-word ;
: JMPA ( an -- ) register-number 0x4ed0 bitor emit-word ;
: PUSH.L ( dn -- ) register-number 0x2f00 bitor emit-word ;
: POP.L ( dn -- ) register-number 9 shift 0x201f bitor emit-word ;
:: immediate-op ( value dn opcode -- )
    dn register-number opcode bitor emit-word value emit-long ;
: ADDI.L ( value dn -- ) 0x0680 immediate-op ;
: SUBI.L ( value dn -- ) 0x0480 immediate-op ;
: XORI.L ( value dn -- ) 0x0a80 immediate-op ;
: ANDI.L ( value dn -- ) 0x0280 immediate-op ;
: ORI.L ( value dn -- ) 0x0080 immediate-op ;
: NEG.L ( dn -- ) register-number 0x4480 bitor emit-word ;
: NOT.L ( dn -- ) register-number 0x4680 bitor emit-word ;
:: shift-immediate ( count dn opcode -- )
    count 1 >= count 8 <= and [ ]
    [ count 3 invalid-m68k-immediate ] if
    count 7 bitand 9 shift dn register-number bitor opcode bitor emit-word ;
: LSL.L ( count dn -- ) 0xe188 shift-immediate ;
: LSR.L ( count dn -- ) 0xe088 shift-immediate ;
: ASR.L ( count dn -- ) 0xe080 shift-immediate ;
! 68881/68882 register operations. These must not be emitted for soft-float.
:: fp-op ( src dst opcode -- )
    0xf200 emit-word src register-number 10 shift
    dst register-number 7 shift bitor opcode bitor emit-word ;
: FMOVE.X ( src dst -- ) 0x00 fp-op ;
: FADD.X ( src dst -- ) 0x22 fp-op ;
: FSUB.X ( src dst -- ) 0x28 fp-op ;
: FMUL.X ( src dst -- ) 0x23 fp-op ;
: FDIV.X ( src dst -- ) 0x20 fp-op ;
: FCMP.X ( src dst -- ) 0x38 fp-op ;
: FNEG.X ( src dst -- ) 0x1a fp-op ;
: FSQRT.X ( src dst -- ) 0x04 fp-op ;
:: FLOAD.D ( an displacement fp -- )
    an register-number 0xf228 bitor emit-word
    fp register-number 7 shift 0x5400 bitor emit-word
    displacement 16 signed-immediate emit-word ;
:: FSTORE.D ( fp an displacement -- )
    an register-number 0xf228 bitor emit-word
    fp register-number 7 shift 0x7400 bitor emit-word
    displacement 16 signed-immediate emit-word ;
:: fp-control-op ( dn extension -- )
    dn register-number 0xf200 bitor emit-word extension emit-word ;
: GET-FPCR ( dn -- ) 0xb000 fp-control-op ;
: SET-FPCR ( dn -- ) 0x9000 fp-control-op ;
: GET-FPSR ( dn -- ) 0xa800 fp-control-op ;
: SET-FPSR ( dn -- ) 0x8800 fp-control-op ;
! Address-register forms preserve the distinction between Dn and An.
:: MOVEAD.L ( an dn -- )
    an register-number dn register-number 9 shift bitor
    0x2008 bitor emit-word ;
:: MOVEAA.L ( src dst -- )
    src register-number dst register-number 9 shift bitor
    0x2048 bitor emit-word ;
:: LOADA.L ( src displacement dst -- )
    src register-number dst register-number 9 shift bitor
    0x2068 bitor emit-word displacement 16 signed-immediate emit-word ;
:: STOREA.L ( src dst displacement -- )
    dst register-number 9 shift src register-number bitor
    0x2148 bitor emit-word displacement 16 signed-immediate emit-word ;
: PUSHA.L ( an -- ) register-number 0x2f08 bitor emit-word ;
: POPA.L ( an -- ) register-number 9 shift 0x205f bitor emit-word ;
:: LOAD.B ( an displacement dn -- )
    an register-number dn register-number 9 shift bitor
    0x1028 bitor emit-word displacement 16 signed-immediate emit-word ;
: CMPI.L ( value dn -- ) 0x0c80 immediate-op ;
:: XOR.L ( src dst -- )
    src register-number 9 shift dst register-number bitor
    0xb180 bitor emit-word ;
:: shift-register ( count dn opcode -- )
    count register-number 9 shift dn register-number bitor
    opcode bitor emit-word ;
: LSLR.L ( count dn -- ) 0xe1a8 shift-register ;
: LSRR.L ( count dn -- ) 0xe0a8 shift-register ;
: ASRR.L ( count dn -- ) 0xe0a0 shift-register ;
:: MULS.L ( src dst -- )
    src register-number 0x4c00 bitor emit-word
    dst register-number 12 shift 0x0800 bitor emit-word ;
:: MULS64.L ( src low high -- )
    src register-number 0x4c00 bitor emit-word
    low register-number 12 shift high register-number bitor
    0x0c00 bitor emit-word ;
:: DIVS.L ( src dst -- )
    src register-number 0x4c40 bitor emit-word
    dst register-number dup 12 shift bitor 0x0800 bitor emit-word ;
! 32-bit dividend, quotient and remainder in separate registers.
:: DIVREM.L ( src quotient remainder -- )
    src register-number 0x4c40 bitor emit-word
    quotient register-number 12 shift remainder register-number bitor
    0x0800 bitor emit-word ;
! MOVEM masks use D0..D7,A0..A7 bits; predecrement reverses the mask.
:: MOVEM-PUSH ( mask -- )
    0x48e7 emit-word
    0 16 [| bit | 1 shift mask bit bit? [ 1 bitor ] when ] each-integer
    emit-word ;
: MOVEM-POP ( mask -- ) 0x4cdf emit-word emit-word ;
: FPU-PUSH ( -- ) 0xf227 emit-word 0xe0ff emit-word ;
: FPU-POP ( -- ) 0xf21f emit-word 0xd0ff emit-word ;
: FPU-CONTROL-PUSH ( -- ) 0xf227 emit-word 0xbc00 emit-word ;
: FPU-CONTROL-POP ( -- ) 0xf21f emit-word 0x9c00 emit-word ;
:: ADDA.L ( dn an -- )
    dn register-number an register-number 9 shift bitor
    0xd1c0 bitor emit-word ;
:: SUBA.L ( dn an -- )
    dn register-number an register-number 9 shift bitor
    0x91c0 bitor emit-word ;
:: ADDAI.L ( value an -- )
    an register-number 9 shift 0xd1fc bitor emit-word value emit-long ;
:: LOAD.W ( an displacement dn -- )
    an register-number dn register-number 9 shift bitor
    0x3028 bitor emit-word displacement 16 signed-immediate emit-word ;
:: STORE.B ( dn an displacement -- )
    an register-number 9 shift dn register-number bitor
    0x1140 bitor emit-word displacement 16 signed-immediate emit-word ;
:: STORE.W ( dn an displacement -- )
    an register-number 9 shift dn register-number bitor
    0x3140 bitor emit-word displacement 16 signed-immediate emit-word ;
: EXT.W ( dn -- ) register-number 0x4880 bitor emit-word ;
: EXT.L ( dn -- ) register-number 0x48c0 bitor emit-word ;
: EXTB.L ( dn -- ) register-number 0x49c0 bitor emit-word ;
:: FLOAD.S ( an displacement fp -- )
    an register-number 0xf228 bitor emit-word
    fp register-number 7 shift 0x4400 bitor emit-word
    displacement 16 signed-immediate emit-word ;
:: FSTORE.S ( fp an displacement -- )
    an register-number 0xf228 bitor emit-word
    fp register-number 7 shift 0x6400 bitor emit-word
    displacement 16 signed-immediate emit-word ;
:: FMOVE.L ( dn fp -- )
    dn register-number 0xf200 bitor emit-word
    fp register-number 7 shift 0x4000 bitor emit-word ;
:: FGET.L ( fp dn -- )
    dn register-number 0xf200 bitor emit-word
    fp register-number 7 shift 0x6000 bitor emit-word ;
: FINTRZ.X ( src dst -- ) 0x03 fp-op ;
:: FBcc ( displacement condition -- )
    condition 0 >= condition 32 < and [ ]
    [ condition 5 invalid-m68k-immediate ] if
    condition 0xf280 bitor emit-word
    displacement 16 signed-immediate emit-word ;
: CLR-ABS.L ( address -- ) 0x42b9 emit-word emit-long ;
: RTD ( displacement -- )
    0x4e74 emit-word 16 signed-immediate emit-word ;
