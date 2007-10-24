! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: cpu.ppc.assembler
USING: generator.fixup generic kernel math memory namespaces
words math.bitfields io.binary ;

! See the Motorola or IBM documentation for details. The opcode
! names are standard, and the operand order is the same as in
! the docs, except a few differences, namely, in IBM/Motorola
! assembler syntax, loads and stores are written like:
!
! stw r14,10(r15)
!
! In Factor, we write:
!
! 14 15 10 STW

: insn ( operand opcode -- ) { 26 0 } bitfield , ;
: a-form ( d a b c xo rc -- n ) { 0 1 6 11 16 21 } bitfield ;
: b-form ( bo bi bd aa lk -- n ) { 0 1 2 16 21 } bitfield ;
: s>u16 ( s -- u ) HEX: ffff bitand ;
: d-form ( d a simm -- n ) s>u16 { 0 16 21 } bitfield ;
: sd-form ( d a simm -- n ) s>u16 { 0 21 16 } bitfield ;
: i-form ( li aa lk -- n ) { 0 1 0 } bitfield ;
: x-form ( a s b rc xo -- n ) { 1 0 11 21 16 } bitfield ;
: xfx-form ( d spr xo -- n ) { 1 11 21 } bitfield ;
: xo-form ( d a b oe rc xo -- n ) { 1 0 10 11 16 21 } bitfield ;

: ADDI d-form 14 insn ;   : LI 0 rot ADDI ;   : SUBI neg ADDI ;
: ADDIS d-form 15 insn ;  : LIS 0 rot ADDIS ;

: ADDIC d-form 12 insn ;  : SUBIC neg ADDIC ;

: ADDIC. d-form 13 insn ; : SUBIC. neg ADDIC. ;

: MULI d-form 7 insn ;

: (ADD) 266 xo-form 31 insn ;
: ADD 0 0 (ADD) ;  : ADD. 0 1 (ADD) ;
: ADDO 1 0 (ADD) ; : ADDO. 1 1 (ADD) ;

: (ADDC) 10 xo-form 31 insn ;
: ADDC 0 0 (ADDC) ;  : ADDC. 0 1 (ADDC) ;
: ADDCO 1 0 (ADDC) ; : ADDCO. 1 1 (ADDC) ;

: (ADDE) 138 xo-form 31 insn ;
: ADDE 0 0 (ADDE) ;  : ADDE. 0 1 (ADDE) ;
: ADDEO 1 0 (ADDE) ; : ADDEO. 1 1 (ADDE) ;

: ANDI sd-form 28 insn ;
: ANDIS sd-form 29 insn ;

: (AND) 28 x-form 31 insn ;
: AND 0 (AND) ;  : AND. 0 (AND) ;

: (DIVW) 491 xo-form 31 insn ;
: DIVW 0 0 (DIVW) ;  : DIVW. 0 1 (DIVW) ;
: DIVWO 1 0 (DIVW) ; : DIVWO. 1 1 (DIVW) ;

: (DIVWU) 459 xo-form 31 insn ;
: DIVWU 0 0 (DIVWU) ;  : DIVWU. 0 1 (DIVWU) ;
: DIVWUO 1 0 (DIVWU) ; : DIVWUO. 1 1 (DIVWU) ;

: (EQV) 284 x-form 31 insn ;
: EQV 0 (EQV) ;  : EQV. 1 (EQV) ;

: (NAND) 476 x-form 31 insn ;
: NAND 0 (NAND) ;  : NAND. 1 (NAND) ;

: (NOR) 124 x-form 31 insn ;
: NOR 0 (NOR) ;  : NOR. 1 (NOR) ;

: NOT dup NOR ;   : NOT. dup NOR. ;

: ORI sd-form 24 insn ;  : ORIS sd-form 25 insn ;

: (OR) 444 x-form 31 insn ;
: OR 0 (OR) ;  : OR. 1 (OR) ;

: (ORC) 412 x-form 31 insn ;
: ORC 0 (ORC) ;  : ORC. 1 (ORC) ;

: MR dup OR ;  : MR. dup OR. ;

: (MULHW) 75 xo-form 31 insn ;
: MULHW 0 0 (MULHW) ;  : MULHW. 0 1 (MULHW) ;

: MULLI d-form 7 insn ;

: (MULHWU) 11 xo-form 31 insn ;
: MULHWU 0 0 (MULHWU) ;  : MULHWU. 0 1 (MULHWU) ;

: (MULLW) 235 xo-form 31 insn ;
: MULLW 0 0 (MULLW) ;  : MULLW. 0 1 (MULLW) ;
: MULLWO 1 0 (MULLW) ; : MULLWO. 1 1 (MULLW) ;

: (SLW) 24 x-form 31 insn ;
: SLW 0 (SLW) ;  : SLW. 1 (SLW) ;

: (SRAW) 792 x-form 31 insn ;
: SRAW 0 (SRAW) ;  : SRAW. 1 (SRAW) ;

: (SRW) 536 x-form 31 insn ;
: SRW 0 (SRW) ;  : SRW. 1 (SRW) ;

: SRAWI 0 824 x-form 31 insn ;

: (SUBF) 40 xo-form 31 insn ;
: SUBF 0 0 (SUBF) ;  : SUBF. 0 1 (SUBF) ;
: SUBFO 1 0 (SUBF) ; : SUBFO. 1 1 (SUBF) ;

: (SUBFC) 8 xo-form 31 insn ;
: SUBFC 0 0 (SUBFC) ;  : SUBFC. 0 1 (SUBFC) ;
: SUBFCO 1 0 (SUBFC) ; : SUBFCO. 1 1 (SUBFC) ;

: (SUBFE) 136 xo-form 31 insn ;
: SUBFE 0 0 (SUBFE) ;  : SUBFE. 0 1 (SUBFE) ;
: SUBFEO 1 0 (SUBFE) ; : SUBFEO. 1 1 (SUBFE) ;

: (EXTSB) 0 swap 954 x-form 31 insn ;
: EXTSB 0 (EXTSB) ;
: EXTSB. 1 (EXTSB) ;

: XORI sd-form 26 insn ;  : XORIS sd-form 27 insn ;

: (XOR) 316 x-form 31 insn ;
: XOR 0 (XOR) ;  : XOR. 1 (XOR) ;

: CMPI d-form 11 insn ;
: CMPLI d-form 10 insn ;

: CMP 0 0 x-form 31 insn ;
: CMPL 0 32 x-form 31 insn ;

: (RLWINM) a-form 21 insn ;
: RLWINM 0 (RLWINM) ;  : RLWINM. 1 (RLWINM) ;

: (SLWI) 0 31 pick - ;
: SLWI (SLWI) RLWINM ;  : SLWI. (SLWI) RLWINM. ;
: (SRWI) 32 over - swap 31 ;
: SRWI (SRWI) RLWINM ;  : SRWI. (SRWI) RLWINM. ;

: LBZ d-form 34 insn ;  : LBZU d-form 35 insn ;
: LHA d-form 42 insn ;  : LHAU d-form 43 insn ;
: LHZ d-form 40 insn ;  : LHZU d-form 41 insn ;
: LWZ d-form 32 insn ;  : LWZU d-form 33 insn ;

: LBZX 0  87 x-form 31 insn ; : LBZUX 0 119 x-form 31 insn ;
: LHAX 0 343 x-form 31 insn ; : LHAUX 0 375 x-form 31 insn ;
: LHZX 0 279 x-form 31 insn ; : LHZUX 0 311 x-form 31 insn ;
: LWZX 0  23 x-form 31 insn ; : LWZUX 0  55 x-form 31 insn ;

: STB d-form 38 insn ;  : STBU d-form 39 insn ;
: STH d-form 44 insn ;  : STHU d-form 45 insn ;
: STW d-form 36 insn ;  : STWU d-form 37 insn ;

: STBX 0 215 x-form 31 insn ; : STBUX 247 x-form 31 insn ;
: STHX 0 407 x-form 31 insn ; : STHUX 439 x-form 31 insn ;
: STWX 0 151 x-form 31 insn ; : STWUX 183 x-form 31 insn ;

GENERIC# (B) 2 ( dest aa lk -- )
M: integer (B) i-form 18 insn ;
M: word (B) 0 -rot (B) rc-relative-ppc-3 rel-word ;
M: label (B) 0 -rot (B) rc-relative-ppc-3 label-fixup ;

: B 0 0 (B) ; : BL 0 1 (B) ;

GENERIC: BC ( a b c -- )
M: integer BC 0 0 b-form 16 insn ;
M: word BC >r 0 BC r> rc-relative-ppc-2 rel-word ;
M: label BC >r 0 BC r> rc-relative-ppc-2 label-fixup ;

: BLT 12 0 rot BC ;  : BGE 4 0 rot BC ;
: BGT 12 1 rot BC ;  : BLE 4 1 rot BC ;
: BEQ 12 2 rot BC ;  : BNE 4 2 rot BC ;
: BO  12 3 rot BC ;  : BNO 4 3 rot BC ;

: BCLR 0 8 0 0 b-form 19 insn ;
: BLR 20 BCLR ;
: BCLRL 0 8 0 1 b-form 19 insn ;
: BLRL 20 BCLRL ;
: BCCTR 0 264 0 0 b-form 19 insn ;
: BCTR 20 BCCTR ;

: MFSPR 5 shift 339 xfx-form 31 insn ;
: MFXER 1 MFSPR ;  : MFLR 8 MFSPR ;  : MFCTR 9 MFSPR ;

: MTSPR 5 shift 467 xfx-form 31 insn ;
: MTXER 1 MTSPR ;  : MTLR 8 MTSPR ;  : MTCTR 9 MTSPR ;

: LOAD32 >r w>h/h r> tuck LIS dup rot ORI ;

: LOAD ( n r -- )
    #! PowerPC cannot load a 32 bit literal in one instruction.
   >r dup -32768 32767 between? [ r> LI ] [ r> LOAD32 ] if ;

! Floating point
: LFS d-form 48 insn ;  : LFSU d-form 49 insn ;
: LFD d-form 50 insn ;  : LFDU d-form 51 insn ;
: STFS d-form 52 insn ; : STFSU d-form 53 insn ;
: STFD d-form 54 insn ; : STFDU d-form 55 insn ;

: (FMR) >r 0 -rot 72 r> x-form 63 insn ;
: FMR 0 (FMR) ;  : FMR. 1 (FMR) ;

: (FCTIWZ) >r 0 -rot r> 15 x-form 63 insn ;
: FCTIWZ 0 (FCTIWZ) ;  : FCTIWZ. 1 (FCTIWZ) ;

: (FADD) >r 0 21 r> a-form 63 insn ;
: FADD 0 (FADD) ;  : FADD. 1 (FADD) ;

: (FSUB) >r 0 20 r> a-form 63 insn ;
: FSUB 0 (FSUB) ;  : FSUB. 1 (FSUB) ;

: (FMUL) >r 0 swap 25 r> a-form 63 insn ;
: FMUL 0 (FMUL) ;  : FMUL. 1 (FMUL) ;

: (FDIV) >r 0 18 r> a-form 63 insn ;
: FDIV 0 (FDIV) ;  : FDIV. 1 (FDIV) ;

: (FSQRT) >r 0 swap 0 22 r> a-form 63 insn ;
: FSQRT 0 (FSQRT) ;  : FSQRT. 1 (FSQRT) ;

: FCMPU 0 0 x-form 63 insn ;
: FCMPO 0 32 x-form 63 insn ;
