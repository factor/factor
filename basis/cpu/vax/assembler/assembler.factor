! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: byte-arrays endian kernel locals make math math.bitwise math.order ;
IN: cpu.vax.assembler

ERROR: invalid-vax-register register ;
ERROR: invalid-vax-immediate value width ;

:: register-number ( reg -- n )
    reg 0 15 between? [ reg ] [ reg invalid-vax-register ] if ;
:: checked-immediate ( value width -- bits )
    value width >signed value = value width bits value = or
    [ value width bits ] [ value width invalid-vax-immediate ] if ;
:: R ( reg -- operand )
    [ reg register-number 0x50 bitor , ] B{ } make ;
:: INDIRECT ( reg -- operand )
    [ reg register-number 0x60 bitor , ] B{ } make ;
:: PREDEC ( reg -- operand )
    [ reg register-number 0x70 bitor , ] B{ } make ;
:: POSTINC ( reg -- operand )
    [ reg register-number 0x80 bitor , ] B{ } make ;
:: LITERAL ( value -- operand )
    value 0 63 between?
    [ [ value , ] B{ } make ] [ value 6 invalid-vax-immediate ] if ;
:: immediate ( value width -- operand )
    [ 0x8f , value width checked-immediate width 8 /i >le % ] B{ } make ;
: IMM.B ( value -- operand ) 8 immediate ;
: IMM.W ( value -- operand ) 16 immediate ;
: IMM.L ( value -- operand ) 32 immediate ;
:: ABS ( address -- operand )
    [ 0x9f , address 32 checked-immediate 4 >le % ] B{ } make ;
:: MEM ( base offset -- operand )
    base register-number :> reg
    [ offset zero? reg 15 = not and [ reg 0x60 bitor , ] [
        offset -128 127 between? [ reg 0xa0 bitor , offset 8 bits , ] [
            offset -32768 32767 between?
            [ reg 0xc0 bitor , offset 16 bits 2 >le % ]
            [ offset -0x80000000 0x7fffffff between?
                [ reg 0xe0 bitor , offset 32 bits 4 >le % ]
                [ offset 32 invalid-vax-immediate ] if ] if
        ] if
    ] if ] B{ } make ;
:: INDEX ( base index -- operand )
    index register-number 15 = [ index invalid-vax-register ] when
    [ index 0x40 bitor , base % ] B{ } make ;

:: unary ( operand opcode -- ) opcode , operand % ;
:: binary ( src dst opcode -- ) opcode , src % dst % ;
:: ternary ( first second dst opcode -- ) opcode , first % second % dst % ;
: NOP ( -- ) 0x01 , ;
: RET ( -- ) 0x04 , ;
: RSB ( -- ) 0x05 , ;
: MOVB ( src dst -- ) 0x90 binary ;
: MOVW ( src dst -- ) 0xb0 binary ;
: MOVL ( src dst -- ) 0xd0 binary ;
: CVTBL ( src dst -- ) 0x98 binary ;
: CVTWL ( src dst -- ) 0x32 binary ;
: MOVZBL ( src dst -- ) 0x9a binary ;
: MOVZWL ( src dst -- ) 0x3c binary ;
: MOVQ ( src dst -- ) 0x7d binary ;
: MOVAL ( src dst -- ) 0xde binary ;
: CLRL ( dst -- ) 0xd4 unary ;
: TSTL ( src -- ) 0xd5 unary ;
: INCL ( dst -- ) 0xd6 unary ;
: DECL ( dst -- ) 0xd7 unary ;
: CMPL ( first second -- ) 0xd1 binary ;
: BITL ( mask src -- ) 0xd3 binary ;
: ADDL2 ( src dst -- ) 0xc0 binary ;
: ADDL3 ( first second dst -- ) 0xc1 ternary ;
: SUBL2 ( src dst -- ) 0xc2 binary ;
: SUBL3 ( first second dst -- ) 0xc3 ternary ;
: MULL3 ( first second dst -- ) 0xc5 ternary ;
: DIVL3 ( divisor dividend dst -- ) 0xc7 ternary ;
: BISL3 ( first second dst -- ) 0xc9 ternary ;
: BICL3 ( mask src dst -- ) 0xcb ternary ;
: XORL3 ( first second dst -- ) 0xcd ternary ;
: MNEGL ( src dst -- ) 0xce binary ;
: MCOML ( src dst -- ) 0xd2 binary ;
: ASHL ( count src dst -- ) 0x78 ternary ;
:: EXTZV ( position size src dst -- )
    0xef , position % size % src % dst % ;
: PUSHL ( src -- ) 0xdd unary ;
: MOVPSL ( dst -- ) 0xdc unary ;
: PUSHR ( mask -- ) 0xbb unary ;
: POPR ( mask -- ) 0xba unary ;
: BICPSW ( mask -- ) 0xb9 unary ;
: BISPSW ( mask -- ) 0xb8 unary ;
: JSB* ( target -- ) 0x16 unary ;
: JMP* ( target -- ) 0x17 unary ;
: JSB ( address -- ) ABS 0x16 unary ;
: JMP ( address -- ) ABS 0x17 unary ;
: CALLS ( count target -- ) 0xfb binary ;
: CALLG ( argument-list target -- ) 0xfa binary ;
:: branch-byte ( displacement opcode -- )
    displacement -128 127 between? [ opcode , displacement 8 bits , ]
    [ displacement 8 invalid-vax-immediate ] if ;
: BRB ( displacement -- ) 0x11 branch-byte ;
: BNEQ ( displacement -- ) 0x12 branch-byte ;
: BEQL ( displacement -- ) 0x13 branch-byte ;
: BGTR ( displacement -- ) 0x14 branch-byte ;
: BLEQ ( displacement -- ) 0x15 branch-byte ;
: BGEQ ( displacement -- ) 0x18 branch-byte ;
: BLSS ( displacement -- ) 0x19 branch-byte ;
: BGTRU ( displacement -- ) 0x1a branch-byte ;
: BLEQU ( displacement -- ) 0x1b branch-byte ;
: BVC ( displacement -- ) 0x1c branch-byte ;
: BVS ( displacement -- ) 0x1d branch-byte ;
: BGEQU ( displacement -- ) 0x1e branch-byte ;
: BLSSU ( displacement -- ) 0x1f branch-byte ;
