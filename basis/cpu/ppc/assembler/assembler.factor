! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces words math math.order locals
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
: FRSP ( a s -- ) [ 0 ] 2dip 0 12 63 x-insn ;
: FRSP. ( a s -- ) [ 0 ] 2dip 1 12 63 x-insn ;
: FMR ( a s -- ) [ 0 ] 2dip 0 72 63 x-insn ;
: FMR. ( a s -- ) [ 0 ] 2dip 1 72 63 x-insn ;
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
: LI ( value dst -- ) swap [ 0 ] dip ADDI ; inline
: SUBI ( dst src1 src2 -- ) neg ADDI ; inline
: LIS ( value dst -- ) swap [ 0 ] dip ADDIS ; inline
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
:: LOAD32 ( n r -- )
    n -16 shift HEX: ffff bitand r LIS
    r r n HEX: ffff bitand ORI ;
: immediate? ( n -- ? ) HEX: -8000 HEX: 7fff between? ;
: LOAD ( n r -- ) over immediate? [ LI ] [ LOAD32 ] if ;

! Altivec/VMX instructions
VA: VMHADDSHS  32 4
VA: VMHRADDSHS 33 4
VA: VMLADDUHM  34 4
VA: VMSUMUBM   36 4
VA: VMSUMMBM   37 4
VA: VMSUMUHM   38 4
VA: VMSUMUHS   39 4
VA: VMSUMSHM   40 4
VA: VMSUMSHS   41 4
VA: VSEL       42 4
VA: VPERM      43 4
VA: VSLDOI     44 4
VA: VMADDFP    46 4
VA: VNMSUBFP   47 4

VX: VADDUBM    0 4
VX: VADDUHM   64 4
VX: VADDUWM  128 4
VX: VADDCUW  384 4
VX: VADDUBS  512 4
VX: VADDUHS  576 4
VX: VADDUWS  640 4
VX: VADDSBS  768 4
VX: VADDSHS  832 4
VX: VADDSWS  896 4

VX: VSUBUBM 1024 4
VX: VSUBUHM 1088 4
VX: VSUBUWM 1152 4
VX: VSUBCUW 1408 4
VX: VSUBUBS 1536 4
VX: VSUBUHS 1600 4
VX: VSUBUWS 1664 4
VX: VSUBSBS 1792 4
VX: VSUBSHS 1856 4
VX: VSUBSWS 1920 4

VX: VMAXUB    2 4
VX: VMAXUH   66 4
VX: VMAXUW  130 4
VX: VMAXSB  258 4
VX: VMAXSH  322 4
VX: VMAXSW  386 4

VX: VMINUB  514 4
VX: VMINUH  578 4
VX: VMINUW  642 4
VX: VMINSB  770 4
VX: VMINSH  834 4
VX: VMINSW  898 4

VX: VAVGUB 1026 4
VX: VAVGUH 1090 4
VX: VAVGUW 1154 4
VX: VAVGSB 1282 4
VX: VAVGSH 1346 4
VX: VAVGSW 1410 4

VX: VRLB      4 4
VX: VRLH     68 4
VX: VRLW    132 4
VX: VSLB    260 4
VX: VSLH    324 4
VX: VSLW    388 4
VX: VSL     452 4
VX: VSRB    516 4
VX: VSRH    580 4
VX: VSRW    644 4
VX: VSR     708 4
VX: VSRAB   772 4
VX: VSRAH   836 4
VX: VSRAW   900 4

VX: VAND   1028 4
VX: VANDC  1092 4
VX: VOR    1156 4
VX: VNOR   1284 4
VX: VXOR   1220 4

VXD: MFVSCR 1540 4
VXB: MTVSCR 1604 4

VX: VMULOUB     8 4
VX: VMULOUH    72 4
VX: VMULOSB   264 4
VX: VMULOSH   328 4
VX: VMULEUB   520 4
VX: VMULEUH   584 4
VX: VMULESB   776 4
VX: VMULESH   840 4
VX: VSUM4UBS 1544 4
VX: VSUM4SBS 1800 4
VX: VSUM4SHS 1608 4
VX: VSUM2SWS 1672 4
VX: VSUMSWS  1928 4

VX: VADDFP        10 4
VX: VSUBFP        74 4

VXDB: VREFP      266 4
VXDB: VRSQRTEFP  330 4
VXDB: VEXPTEFP   394 4
VXDB: VLOGEFP    458 4
VXDB: VRFIN      522 4
VXDB: VRFIZ      586 4
VXDB: VRFIP      650 4
VXDB: VRFIM      714 4

VX: VCFUX        778 4
VX: VCFSX        842 4
VX: VCTUXS       906 4
VX: VCTSXS       970 4

VX: VMAXFP      1034 4
VX: VMINFP      1098 4

VX: VMRGHB        12 4
VX: VMRGHH        76 4
VX: VMRGHW       140 4
VX: VMRGLB       268 4
VX: VMRGLH       332 4
VX: VMRGLW       396 4

VX: VSPLTB       524 4
VX: VSPLTH       588 4
VX: VSPLTW       652 4

VXA: VSPLTISB    780 4
VXA: VSPLTISH    844 4
VXA: VSPLTISW    908 4

VX: VSLO       1036 4
VX: VSRO       1100 4

VX: VPKUHUM      14 4 
VX: VPKUWUM      78 4 
VX: VPKUHUS     142 4 
VX: VPKUWUS     206 4 
VX: VPKSHUS     270 4 
VX: VPKSWUS     334 4 
VX: VPKSHSS     398 4 
VX: VPKSWSS     462 4 
VX: VPKPX       782 4 

VXDB: VUPKHSB   526 4 
VXDB: VUPKHSH   590 4 
VXDB: VUPKLSB   654 4 
VXDB: VUPKLSH   718 4 
VXDB: VUPKHPX   846 4 
VXDB: VUPKLPX   974 4 

: -T ( strm a b -- strm-t a b ) [ 16 bitor ] 2dip ;

XD: DST 0 342 31
: DSTT ( strm a b -- ) -T DST ;

XD: DSTST 0 374 31
: DSTSTT ( strm a b -- ) -T DSTST ;

XD: (DSS) 0 822 31
: DSS ( strm -- ) 0 0 (DSS) ;
: DSSALL ( -- ) 16 0 0 (DSS) ;

XD: LVEBX 0    7 31
XD: LVEHX 0   39 31
XD: LVEWX 0   71 31
XD: LVSL  0    6 31
XD: LVSR  0   38 31
XD: LVX   0  103 31
XD: LVXL  0  359 31

XD: STVEBX 0  135 31
XD: STVEHX 0  167 31
XD: STVEWX 0  199 31
XD: STVX   0  231 31
XD: STVXL  0  487 31

VXR: VCMPBFP   0  966 4
VXR: VCMPEQFP  0  198 4
VXR: VCMPEQUB  0    6 4
VXR: VCMPEQUH  0   70 4
VXR: VCMPEQUW  0  134 4
VXR: VCMPGEFP  0  454 4
VXR: VCMPGTFP  0  710 4
VXR: VCMPGTSB  0  774 4
VXR: VCMPGTSH  0  838 4
VXR: VCMPGTSW  0  902 4
VXR: VCMPGTUB  0  518 4
VXR: VCMPGTUH  0  582 4
VXR: VCMPGTUW  0  646 4

VXR: VCMPBFP.  1  966 4
VXR: VCMPEQFP. 1  198 4
VXR: VCMPEQUB. 1    6 4
VXR: VCMPEQUH. 1   70 4
VXR: VCMPEQUW. 1  134 4
VXR: VCMPGEFP. 1  454 4
VXR: VCMPGTFP. 1  710 4
VXR: VCMPGTSB. 1  774 4
VXR: VCMPGTSH. 1  838 4
VXR: VCMPGTSW. 1  902 4
VXR: VCMPGTUB. 1  518 4
VXR: VCMPGTUH. 1  582 4
VXR: VCMPGTUW. 1  646 4

