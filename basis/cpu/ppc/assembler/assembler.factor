! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces words io.binary math math.order
cpu.ppc.assembler.backend ;
IN: cpu.ppc.assembler

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

! D-form
D: ADDI 14
D: ADDIC 12
D: ADDIC. 13
D: ADDIS 15
D: CMPI 11
D: CMPLI 10
D: LBZ 34
D: LBZU 35
D: LFD 50
D: LFDU 51
D: LFS 48
D: LFSU 49
D: LHA 42
D: LHAU 43
D: LHZ 40
D: LHZU 41
D: LWZ 32
D: LWZU 33
D: MULI 7
D: MULLI 7
D: STB 38
D: STBU 39
D: STFD 54
D: STFDU 55
D: STFS 52
D: STFSU 53
D: STH 44
D: STHU 45
D: STW 36
D: STWU 37

! SD-form
SD: ANDI 28
SD: ANDIS 29
SD: ORI 24
SD: ORIS 25
SD: XORI 26
SD: XORIS 27

! X-form
X: AND 0 28 31
X: AND. 1 28 31
X: CMP 0 0 31
X: CMPL 0 32 31
X: EQV 0 284 31
X: EQV. 1 284 31
X: FCMPO 0 32 63
X: FCMPU 0 0 63
X: LBZUX 0 119 31
X: LBZX 0 87 31
X: LHAUX 0 375 31
X: LHAX 0 343 31
X: LHZUX 0 311 31
X: LHZX 0 279 31
X: LWZUX 0 55 31
X: LWZX 0 23 31
X: NAND 0 476 31
X: NAND. 1 476 31
X: NOR 0 124 31
X: NOR. 1 124 31
X: OR 0 444 31
X: OR. 1 444 31
X: ORC 0 412 31
X: ORC. 1 412 31
X: SLW 0 24 31
X: SLW. 1 24 31
X: SRAW 0 792 31
X: SRAW. 1 792 31
X: SRAWI 0 824 31
X: SRW 0 536 31
X: SRW. 1 536 31
X: STBUX 0 247 31
X: STBX 0 215 31
X: STHUX 0 439 31
X: STHX 0 407 31
X: STWUX 0 183 31
X: STWX 0 151 31
X: XOR 0 316 31
X: XOR. 1 316 31
X1: EXTSB 0 954 31
X1: EXTSB. 1 954 31
: FMR ( a s -- ) [ 0 ] 2dip 72 0 63 x-insn ;
: FMR. ( a s -- ) [ 0 ] 2dip 72 1 63 x-insn ;
: FCTIWZ ( a s -- ) [ 0 ] 2dip 0 15 63 x-insn ;
: FCTIWZ. ( a s -- ) [ 0 ] 2dip 1 15 63 x-insn ;

! XO-form
XO: ADD 0 0 266 31
XO: ADD. 0 1 266 31
XO: ADDC 0 0 10 31
XO: ADDC. 0 1 10 31
XO: ADDCO 1 0 10 31
XO: ADDCO. 1 1 10 31
XO: ADDE 0 0 138 31
XO: ADDE. 0 1 138 31
XO: ADDEO 1 0 138 31
XO: ADDEO. 1 1 138 31
XO: ADDO 1 0 266 31
XO: ADDO. 1 1 266 31
XO: DIVW 0 0 491 31
XO: DIVW. 0 1 491 31
XO: DIVWO 1 0 491 31
XO: DIVWO. 1 1 491 31
XO: DIVWU 0 0 459 31
XO: DIVWU. 0 1 459 31
XO: DIVWUO 1 0 459 31
XO: DIVWUO. 1 1 459 31
XO: MULHW 0 0 75 31
XO: MULHW. 0 1 75 31
XO: MULHWU 0 0 11 31
XO: MULHWU. 0 1 11 31
XO: MULLW 0 0 235 31
XO: MULLW. 0 1 235 31
XO: MULLWO 1 0 235 31
XO: MULLWO. 1 1 235 31
XO: SUBF 0 0 40 31
XO: SUBF. 0 1 40 31
XO: SUBFC 0 0 8 31
XO: SUBFC. 0 1 8 31
XO: SUBFCO 1 0 8 31
XO: SUBFCO. 1 1 8 31
XO: SUBFE 0 0 136 31
XO: SUBFE. 0 1 136 31
XO: SUBFEO 1 0 136 31
XO: SUBFEO. 1 1 136 31
XO: SUBFO 1 0 40 31
XO: SUBFO. 1 1 40 31
XO1: NEG 0 0 104 31
XO1: NEG. 0 1 104 31
XO1: NEGO 1 0 104 31
XO1: NEGO. 1 1 104 31

! A-form
: RLWINM ( d a b c xo -- ) 0 21 a-insn ;
: RLWINM. ( d a b c xo -- ) 1 21 a-insn ;
: FADD ( d a b -- ) 0 21 0 63 a-insn ;
: FADD. ( d a b -- ) 0 21 1 63 a-insn ;
: FSUB ( d a b -- ) 0 20 0 63 a-insn ;
: FSUB. ( d a b -- ) 0 20 1 63 a-insn ;
: FMUL ( d a c -- )  0 swap 25 0 63 a-insn ;
: FMUL. ( d a c -- ) 0 swap 25 1 63 a-insn ;
: FDIV ( d a b -- ) 0 18 0 63 a-insn ;
: FDIV. ( d a b -- ) 0 18 1 63 a-insn ;
: FSQRT ( d b -- ) 0 swap 0 22 0 63 a-insn ;
: FSQRT. ( d b -- ) 0 swap 0 22 1 63 a-insn ;

! Branches
: B ( dest -- ) 0 0 (B) ;
: BL ( dest -- ) 0 1 (B) ;
BC: LT 12 0
BC: GE 4 0
BC: GT 12 1
BC: LE 4 1
BC: EQ 12 2
BC: NE 4 2
BC: O  12 3
BC: NO 4 3
B: CLR 0 8 0 0 19
B: CLRL 0 8 0 1 19
B: CCTR 0 264 0 0 19
: BLR ( -- ) 20 BCLR ;
: BLRL ( -- ) 20 BCLRL ;
: BCTR ( -- ) 20 BCCTR ;

! Special registers
MFSPR: XER 1
MFSPR: LR 8
MFSPR: CTR 9
MTSPR: XER 1
MTSPR: LR 8
MTSPR: CTR 9

! Pseudo-instructions
: LI ( value dst -- ) 0 rot ADDI ; inline
: SUBI ( dst src1 src2 -- ) neg ADDI ; inline
: LIS ( value dst -- ) 0 rot ADDIS ; inline
: SUBIC ( dst src1 src2 -- ) neg ADDIC ; inline
: SUBIC. ( dst src1 src2 -- ) neg ADDIC. ; inline
: NOT ( dst src -- ) dup NOR ; inline
: NOT. ( dst src -- ) dup NOR. ; inline
: MR ( dst src -- ) dup OR ; inline
: MR. ( dst src -- ) dup OR. ; inline
: (SLWI) ( d a b -- d a b x y ) 0 31 pick - ; inline
: SLWI ( d a b -- ) (SLWI) RLWINM ;
: SLWI. ( d a b -- ) (SLWI) RLWINM. ;
: (SRWI) ( d a b -- d a b x y ) 32 over - swap 31 ; inline
: SRWI ( d a b -- ) (SRWI) RLWINM ;
: SRWI. ( d a b -- ) (SRWI) RLWINM. ;
: LOAD32 ( n r -- ) [ w>h/h ] dip tuck LIS dup rot ORI ;
: immediate? ( n -- ? ) HEX: -8000 HEX: 7fff between? ;
: LOAD ( n r -- ) over immediate? [ LI ] [ LOAD32 ] if ;
