! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors cpu.arm.32.assembler cpu.arm.32.assembler.private
endian kernel locals make math math.bitwise namespaces parser sequences
words words.symbol ;
IN: cpu.arm.32.compiler-assembler

TUPLE: vfp-register number single? ;
C: <vfp-register> vfp-register

CONSTANT: D0 T{ vfp-register f 0 f }
CONSTANT: D1 T{ vfp-register f 1 f }
CONSTANT: D2 T{ vfp-register f 2 f }
CONSTANT: D3 T{ vfp-register f 3 f }
CONSTANT: D4 T{ vfp-register f 4 f }
CONSTANT: D5 T{ vfp-register f 5 f }
CONSTANT: D6 T{ vfp-register f 6 f }
CONSTANT: D7 T{ vfp-register f 7 f }
CONSTANT: D8 T{ vfp-register f 8 f }
CONSTANT: D9 T{ vfp-register f 9 f }
CONSTANT: D10 T{ vfp-register f 10 f }
CONSTANT: D11 T{ vfp-register f 11 f }
CONSTANT: D12 T{ vfp-register f 12 f }
CONSTANT: D13 T{ vfp-register f 13 f }
CONSTANT: D14 T{ vfp-register f 14 f }
CONSTANT: D15 T{ vfp-register f 15 f }
CONSTANT: S0 T{ vfp-register f 0 t }
CONSTANT: S1 T{ vfp-register f 1 t }
CONSTANT: S2 T{ vfp-register f 2 t }
CONSTANT: S3 T{ vfp-register f 3 t }
CONSTANT: S4 T{ vfp-register f 4 t }
CONSTANT: S5 T{ vfp-register f 5 t }
CONSTANT: S6 T{ vfp-register f 6 t }
CONSTANT: S7 T{ vfp-register f 7 t }
CONSTANT: S8 T{ vfp-register f 8 t }
CONSTANT: S9 T{ vfp-register f 9 t }
CONSTANT: S10 T{ vfp-register f 10 t }
CONSTANT: S11 T{ vfp-register f 11 t }
CONSTANT: S12 T{ vfp-register f 12 t }
CONSTANT: S13 T{ vfp-register f 13 t }
CONSTANT: S14 T{ vfp-register f 14 t }
CONSTANT: S15 T{ vfp-register f 15 t }
CONSTANT: S16 T{ vfp-register f 16 t }
CONSTANT: S17 T{ vfp-register f 17 t }
CONSTANT: S18 T{ vfp-register f 18 t }
CONSTANT: S19 T{ vfp-register f 19 t }
CONSTANT: S20 T{ vfp-register f 20 t }
CONSTANT: S21 T{ vfp-register f 21 t }
CONSTANT: S22 T{ vfp-register f 22 t }
CONSTANT: S23 T{ vfp-register f 23 t }
CONSTANT: S24 T{ vfp-register f 24 t }
CONSTANT: S25 T{ vfp-register f 25 t }
CONSTANT: S26 T{ vfp-register f 26 t }
CONSTANT: S27 T{ vfp-register f 27 t }
CONSTANT: S28 T{ vfp-register f 28 t }
CONSTANT: S29 T{ vfp-register f 29 t }
CONSTANT: S30 T{ vfp-register f 30 t }
CONSTANT: S31 T{ vfp-register f 31 t }

: >S ( reg -- reg' )
    dup single?>> [ ] [ number>> 2 * t <vfp-register> ] if ;
: >D ( reg -- reg' )
    dup single?>> [ number>> f <vfp-register> ] when ;

<PRIVATE
: vd ( reg -- bits )
    dup single?>> [ number>> dup 1 bitand 22 shift swap -1 shift 12 shift bitor ]
    [ number>> dup 15 bitand 12 shift swap -4 shift 22 shift bitor ] if ;
: vn ( reg -- bits )
    dup single?>> [ number>> dup 1 bitand 7 shift swap -1 shift 16 shift bitor ]
    [ number>> dup 15 bitand 16 shift swap -4 shift 7 shift bitor ] if ;
: vm ( reg -- bits )
    dup single?>> [ number>> dup 1 bitand 5 shift swap -1 shift bitor ]
    [ number>> dup 15 bitand swap -4 shift 5 shift bitor ] if ;
:: vfp3 ( dst src1 src2 opcode -- )
    dst vd src1 vn bitor src2 vm bitor opcode bitor (insn) ;
:: vfp2 ( dst src opcode -- )
    dst vd src vm bitor opcode bitor (insn) ;
:: vfp-memory ( reg base offset opcode -- )
    reg vd base register 16 shift bitor
    offset abs 4 /i bitor opcode bitor
    offset 0 >= [ 23 2^ bitor ] when (insn) ;
PRIVATE>

: VADD ( dst src1 src2 -- ) 0x0e300b00 vfp3 ;
: VSUB ( dst src1 src2 -- ) 0x0e300b40 vfp3 ;
: VMUL ( dst src1 src2 -- ) 0x0e200b00 vfp3 ;
: VDIV ( dst src1 src2 -- ) 0x0e800b00 vfp3 ;
: VSQRT ( dst src -- ) 0x0eb10bc0 vfp2 ;
:: VMOV ( dst src -- ) dst src dst single?>> 0x0eb00a40 0x0eb00b40 ? vfp2 ;
:: VLDR ( dst base offset -- ) dst base offset dst single?>> 0x0d100a00 0x0d100b00 ? vfp-memory ;
:: VSTR ( src base offset -- ) src base offset src single?>> 0x0d000a00 0x0d000b00 ? vfp-memory ;
: VCMP ( src1 src2 -- ) 0x0eb40b40 vfp2 ;
: VCVT-F64-F32 ( dst src -- ) 0x0eb70ac0 vfp2 ;
: VCVT-F32-F64 ( dst src -- ) 0x0eb70bc0 vfp2 ;
: VCVT-F64-S32 ( dst src -- ) 0x0eb80bc0 vfp2 ;
: VCVT-S32-F64 ( dst src -- ) 0x0ebd0bc0 vfp2 ;
:: VMOV-TO-S ( dst src -- )
    dst >S vn src register 12 shift bitor 0x0e000a10 bitor (insn) ;
:: VMOV-FROM-S ( dst src -- )
    src >S vn dst register 12 shift bitor 0x0e100a10 bitor (insn) ;
: VCMPE ( src1 src2 -- ) 0x0eb40bc0 vfp2 ;
! AAPCS native callees preserve the upper half of the baseline VFP bank.
: VPUSH-D8-D15 ( -- ) 0x0d2d8b10 (insn) ;
: VPOP-D8-D15 ( -- ) 0x0cbd8b10 (insn) ;
:: VMOV-DOUBLE-TO-CORE ( low high src -- )
    low register 12 shift high register 16 shift bitor
    src vm bitor 0x0c500b10 bitor (insn) ;
:: VMOV-CORE-TO-DOUBLE ( dst low high -- )
    low register 12 shift high register 16 shift bitor
    dst vm bitor 0x0c400b10 bitor (insn) ;
