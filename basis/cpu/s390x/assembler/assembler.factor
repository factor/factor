! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! System z instructions are emitted big-endian, independent of host endian.
USING: accessors cpu.s390x.assembler.registers endian kernel locals
make math math.bitwise ;
IN: cpu.s390x.assembler
ERROR: invalid-s390x-immediate value width ;
ERROR: invalid-s390x-register reg ;
:: unsigned-immediate ( value width -- bits )
    value width bits value = [ value ]
    [ value width invalid-s390x-immediate ] if ;
:: signed-immediate ( value width -- bits )
    value width >signed value = [ value width bits ]
    [ value width invalid-s390x-immediate ] if ;
: R ( reg -- n ) dup int-register? [ n>> 4 unsigned-immediate ] [ invalid-s390x-register ] if ;
: F ( reg -- n ) dup fp-register? [ n>> 4 unsigned-immediate ] [ invalid-s390x-register ] if ;
: emit-2 ( value -- ) 2 >be % ;
: emit-4 ( value -- ) 4 >be % ;
:: rr ( r1 r2 opcode -- ) opcode 8 shift r1 R 4 shift bitor r2 R bitor emit-2 ;
:: rre ( r1 r2 opcode -- ) opcode 16 shift r1 R 4 shift bitor r2 R bitor emit-4 ;
:: f-rre ( f1 f2 opcode -- ) opcode 16 shift f1 F 4 shift bitor f2 F bitor emit-4 ;
:: ri ( r1 imm opcode -- )
    opcode r1 R 4 shift bitor emit-2 imm 16 signed-immediate emit-2 ;
:: ril ( r1 imm opcode -- )
    opcode r1 R 4 shift bitor emit-2 imm 32 signed-immediate emit-4 ;
:: rxy ( r1 x2 b2 displacement opcode -- )
    displacement 20 signed-immediate :> d
    opcode -8 shift , r1 R 4 shift x2 R bitor ,
    b2 R 12 shift d 12 bits bitor emit-2
    d -12 shift , opcode 8 bits , ;
: LGR ( dst src -- ) 0xb904 rre ;
: EFPC ( dst -- ) R0 0xb38c rre ;
: SFPC ( src -- ) R0 0xb384 rre ;
: AGR ( dst src -- ) 0xb908 rre ;
: SGR ( dst src -- ) 0xb909 rre ;
: MSGR ( dst src -- ) 0xb90c rre ;
: NGR ( dst src -- ) 0xb980 rre ;
: OGR ( dst src -- ) 0xb981 rre ;
: XGR ( dst src -- ) 0xb982 rre ;
: CGR ( src1 src2 -- ) 0xb920 rre ;
: CLGR ( src1 src2 -- ) 0xb921 rre ;
: LCGR ( dst src -- ) 0xb903 rre ;
: LTGR ( dst src -- ) 0xb902 rre ;
: LGHI ( dst imm -- ) 0xa709 ri ;
: AGHI ( dst imm -- ) 0xa70b ri ;
: CGHI ( src imm -- ) 0xa70f ri ;
: LGFI ( dst imm -- ) 0xc001 ril ;
: LG ( dst index base displacement -- ) 0xe304 rxy ;
: STG ( src index base displacement -- ) 0xe324 rxy ;
: LAY ( dst index base displacement -- ) 0xe371 rxy ;
: LGB ( dst index base displacement -- ) 0xe377 rxy ;
:: BCR ( mask target -- ) 0x0700 mask 4 unsigned-immediate 4 shift bitor target R bitor emit-2 ;
: BASR ( link target -- ) 0x0d rr ;
:: BRCL ( mask displacement -- )
    displacement 1 bitand zero? [ ] [ displacement 33 invalid-s390x-immediate ] if
    0xc004 mask 4 unsigned-immediate 4 shift bitor emit-2
    displacement -1 shift 32 signed-immediate emit-4 ;
:: BRASL ( link displacement -- )
    displacement 1 bitand zero? [ ] [ displacement 33 invalid-s390x-immediate ] if
    link displacement -1 shift 0xc005 ril ;
: RET ( -- ) 15 R14 BCR ;
: NOP ( -- ) 0 R0 BCR ;
:: LDR ( dst src -- ) 0x2800 dst F 4 shift bitor src F bitor emit-2 ;
: ADBR ( dst src -- ) 0xb31a f-rre ;
: SDBR ( dst src -- ) 0xb31b f-rre ;
: MDBR ( dst src -- ) 0xb31c f-rre ;
: DDBR ( dst src -- ) 0xb31d f-rre ;
: CDBR ( src1 src2 -- ) 0xb319 f-rre ;
: KDBR ( src1 src2 -- ) 0xb318 f-rre ;

:: ril-unsigned ( r1 imm opcode -- )
    opcode r1 R 4 shift bitor emit-2 imm 32 unsigned-immediate emit-4 ;
: IIHF ( dst imm -- ) 0xc008 ril-unsigned ;
: IILF ( dst imm -- ) 0xc009 ril-unsigned ;
: LARL ( dst displacement -- )
    dup 1 bitand zero? [ -1 shift 0xc000 ril ]
    [ 33 invalid-s390x-immediate ] if ;
:: LI64 ( dst value -- )
    dst value -32 shift 32 bits IIHF dst value 32 bits IILF ;
:: LI ( dst value -- )
    value 16 >signed value = [ dst value LGHI ] [ dst value LI64 ] if ;
:: rrf ( dst src1 src2 opcode -- )
    opcode 16 shift src2 R 12 shift bitor
    dst R 4 shift bitor src1 R bitor emit-4 ;
: AGRK ( dst src1 src2 -- ) 0xb9e8 rrf ;
: SGRK ( dst src1 src2 -- ) 0xb9e9 rrf ;
: NGRK ( dst src1 src2 -- ) 0xb9e4 rrf ;
: OGRK ( dst src1 src2 -- ) 0xb9e6 rrf ;
: XGRK ( dst src1 src2 -- ) 0xb9e7 rrf ;
: SLLG ( dst src base count -- ) 0xeb0d rxy ;
: SRLG ( dst src base count -- ) 0xeb0c rxy ;
: SRAG ( dst src base count -- ) 0xeb0a rxy ;
: LGH ( dst index base displacement -- ) 0xe315 rxy ;
: LGF ( dst index base displacement -- ) 0xe314 rxy ;
: LLGF ( dst index base displacement -- ) 0xe316 rxy ;
: LLGH ( dst index base displacement -- ) 0xe391 rxy ;
: LLGC ( dst index base displacement -- ) 0xe390 rxy ;
: STCY ( src index base displacement -- ) 0xe372 rxy ;
: STHY ( src index base displacement -- ) 0xe370 rxy ;
: STY ( src index base displacement -- ) 0xe350 rxy ;
:: fp-rxy ( f1 x2 b2 displacement opcode -- )
    displacement 20 signed-immediate :> d
    opcode -8 shift , f1 F 4 shift x2 R bitor ,
    b2 R 12 shift d 12 bits bitor emit-2
    d -12 shift , opcode 8 bits , ;
: LDY ( dst index base displacement -- ) 0xed65 fp-rxy ;
: LEY ( dst index base displacement -- ) 0xed64 fp-rxy ;
: STDY ( src index base displacement -- ) 0xed67 fp-rxy ;
: STEY ( src index base displacement -- ) 0xed66 fp-rxy ;
: SQDBR ( dst src -- ) 0xb315 f-rre ;
: LDEBR ( dst src -- ) 0xb304 f-rre ;
: LEDBR ( dst src -- ) 0xb344 f-rre ;

! Neutral target-native relocation classes are allocated centrally as 14/15.
! Offsets identify the end of the instruction or fixed-size immediate pair.
: call-relative ( -- class ) R14 0 BRASL 14 ;
: jump-relative ( -- class ) 15 0 BRCL 14 ;
: load-address ( dst -- class ) 0 LI64 15 ;

:: fr-rre ( dst src opcode -- )
    opcode 16 shift dst F 4 shift bitor src R bitor emit-4 ;
:: rf-rre ( dst src opcode -- )
    opcode 16 shift dst R 4 shift bitor src F bitor emit-4 ;
: CDGBR ( dst src -- ) 0xb3a5 fr-rre ;
: LDGR ( dst src -- ) 0xb3c1 fr-rre ;
: LGDR ( dst src -- ) 0xb3cd rf-rre ;
:: CGDBR ( dst src rounding -- )
    0xb3a9 16 shift rounding 4 unsigned-immediate 12 shift bitor
    dst R 4 shift bitor src F bitor emit-4 ;

! The first operand is an even register naming an even/odd pair.
: DSGR ( pair divisor -- ) 0xb90d rre ;
: MLGR ( pair multiplier -- ) 0xb986 rre ;
: FLOGR ( pair src -- ) 0xb983 rre ;
: POPCNT ( dst src -- ) 0xb9e1 rre ;
