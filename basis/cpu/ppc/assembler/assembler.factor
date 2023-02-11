! Copyright (C) 2011 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: endian kernel make math math.bitwise ;
IN: cpu.ppc.assembler

! This vocabulary implements the V2.06B Power ISA found at https://www.power.org.
! The names are standard and the operand order is the same as in the specification,
! except that displacement in d-form and ds-form instructions come after the base
! address register.
!
! For example, in assembler syntax, stores are written like:
!   stw r14,10(r15)
! In Factor, we write:
!   14 15 10 STW

: insn ( operand opcode -- )
    { 26 0 } bitfield 4 >be % ;

: a-insn ( rt ra rb rc xo rc opcode -- )
    [ { 0 1 6 11 16 21 } bitfield ] dip insn ;

: b-insn ( bo bi bd aa lk opcode -- )
    [ { 0 1 2 16 21 } bitfield ] dip insn ;

: d-insn ( rt ra d opcode -- )
    [ 0xffff bitand { 0 16 21 } bitfield ] dip insn ;

: ds-insn ( rt ra ds rc opcode -- )
    [ [ 0x3fff bitand ] dip { 0 2 16 21 } bitfield ] dip insn ;

: evx-insn ( rt ra rb xo opcode -- )
    [ { 0 11 16 21 } bitfield ] dip insn ;

: i-insn ( li aa lk opcode -- )
    [ { 0 1 2 } bitfield ] dip insn ;

: m-insn ( rs ra sh mb me rc opcode -- )
    [ { 0 1 6 11 16 21 } bitfield ] dip insn ;

:: md-insn ( rs ra sh mb xo sh5 rc opcode -- )
    mb [ 0x1f bitand 1 shift ] [ -5 shift ] bi bitor :> mb
    rs ra sh mb xo sh5 rc opcode
    [ { 0 1 2 5 11 16 21 } bitfield ] dip insn ;

:: mds-insn ( rs ra rb mb xo rc opcode -- )
    mb [ 0x1f bitand 1 shift ] [ -5 shift ] bi bitor :> mb
    rs ra rb mb xo rc opcode
    [ { 0 1 5 11 16 21 } bitfield ] dip insn ;

: sc-insn ( lev opcode -- )
    [ 1 { 1 5 } bitfield ] dip insn ;

: va-insn ( vrt vra vrb vrc xo opcode -- )
    [ { 0 6 11 16 21 } bitfield ] dip insn ;

: vc-insn ( vrt vra vrb rc xo opcode -- )
    [ { 0 10 11 16 21 } bitfield ] dip insn ;

: vx-insn ( vrt vra vrb xo opcode -- )
    [ { 0 11 16 21 } bitfield ] dip insn ;

: x-insn ( rt ra rb xo rc opcode -- )
    [ { 0 1 11 16 21 } bitfield ] dip insn ;

: xfl-insn ( l flm w frb xo rc opcode -- )
    [ { 0 1 11 16 17 25 } bitfield ] dip insn ;

: xfx-insn ( rs spr xo rc opcode -- )
    [ { 0 1 11 21 } bitfield ] dip insn ;

: xl-insn ( bo bi bb xo lk opcode -- )
    [ { 0 1 11 16 21 } bitfield ] dip insn ;

: xo-insn ( rt ra rb oe xo rc opcode -- )
    [ { 0 1 10 11 16 21 } bitfield ] dip insn ;

: xs-insn ( rs ra sh xo sh5 rc opcode -- )
    [ { 0 1 2 11 16 21 } bitfield ] dip insn ;

:: xx1-insn ( rt ra rb xo opcode -- )
    rt 0x1f bitand ra rb xo rt -5 shift
    { 0 1 11 16 21 } bitfield opcode insn ;

:: xx2-insn ( rt ra rb xo opcode -- )
    rt 0x1f bitand ra rb 0x1f bitand xo
    rb -5 shift rt -5 shift
    { 0 1 2 11 16 21 } bitfield opcode insn ;

:: xx3-insn ( rt ra rb xo opcode -- )
    rt 0x1f bitand ra 0x1f bitand rb 0x1f bitand
    xo ra -5 shift rb -5 shift rt -5 shift
    { 0 1 2 3 11 16 21 } bitfield opcode insn ;

:: xx3-rc-insn ( rt ra rb rc xo opcode -- )
    rt 0x1f bitand ra 0x1f bitand rb 0x1f bitand
    rc xo ra -5 shift rb -5 shift rt -5 shift
    { 0 1 2 3 10 11 16 21 } bitfield opcode insn ;

:: xx3-rc-dm-insn ( rt ra rb rc dm xo opcode -- )
    rt 0x1f bitand ra 0x1f bitand rb 0x1f bitand
    rc dm xo ra -5 shift rb -5 shift rt -5 shift
    { 0 1 2 3 8 10 11 16 21 } bitfield opcode insn ;

:: xx4-insn ( rt ra rb rc xo opcode -- )
    rt 0x1f bitand ra 0x1f bitand rb 0x1f bitand
    rc 0x1f bitand xo rc -5 shift ra -5 shift rb
    -5 shift rt -5 shift
    { 0 1 2 3 4 6 11 16 21 } bitfield opcode insn ;

: z22-insn ( bf fra dcm xo rc opcode -- )
    [ { 0 1 10 16 21 } bitfield ] dip insn ;

: z23-insn ( frt te frb rmc xo rc opcode -- )
    [ { 0 1 9 11 16 21 } bitfield ] dip insn ;

! 2.4 Branch Instructions
GENERIC: B ( target_addr/label -- )
M: integer B -2 shift 0 0 18 i-insn ;

GENERIC: BL ( target_addr/label -- )
M: integer BL -2 shift 0 1 18 i-insn ;

: BA  ( target_addr -- ) -2 shift 1 0 18 i-insn ;
: BLA ( target_addr -- ) -2 shift 1 1 18 i-insn ;

GENERIC: BC ( bo bi target_addr/label -- )
M: integer BC -2 shift 0 0 16 b-insn ;

: BCA  ( bo bi target_addr -- ) -2 shift 1 0 16 b-insn ;
: BCL  ( bo bi target_addr -- ) -2 shift 0 1 16 b-insn ;
: BCLA ( bo bi target_addr -- ) -2 shift 1 1 16 b-insn ;

: BCLR   ( bo bi bh -- )  16 0 19 xl-insn ;
: BCLRL  ( bo bi bh -- )  16 1 19 xl-insn ;
: BCCTR  ( bo bi bh -- ) 528 0 19 xl-insn ;
: BCCTRL ( bo bi bh -- ) 528 1 19 xl-insn ;

! 2.5.1 Condition Register Logical Instructions
: CRAND  ( bt ba bb -- ) 527 0 19 xl-insn ;
: CRNAND ( bt ba bb -- ) 225 0 19 xl-insn ;
: CROR   ( bt ba bb -- ) 449 0 19 xl-insn ;
: CRXOR  ( bt ba bb -- ) 193 0 19 xl-insn ;
: CRNOR  ( bt ba bb -- )  33 0 19 xl-insn ;
: CREQV  ( bt ba bb -- ) 289 0 19 xl-insn ;
: CRANDC ( bt ba bb -- ) 129 0 19 xl-insn ;
: CRORC  ( bt ba bb -- ) 417 0 19 xl-insn ;

! 2.5.2 Condition Register Field Instruction
: MCRF ( bf bfa -- ) [ 2 shift ] bi@ 0 0 0 19 xl-insn ;

! 2.6 System Call Instruction
: SC ( lev -- ) 17 sc-insn ;

! 3.3.2 Fixed-Point Load Instructions
: LBZ   ( rt ra  d -- ) 34 d-insn ;
: LBZU  ( rt ra  d -- ) 35 d-insn ;
: LHZ   ( rt ra  d -- ) 40 d-insn ;
: LHZU  ( rt ra  d -- ) 41 d-insn ;
: LHA   ( rt ra  d -- ) 42 d-insn ;
: LHAU  ( rt ra  d -- ) 43 d-insn ;
: LWZ   ( rt ra  d -- ) 32 d-insn ;
: LWZU  ( rt ra  d -- ) 33 d-insn ;
: LBZX  ( rt ra rb -- )  87 0 31 x-insn ;
: LBZUX ( rt ra rb -- ) 119 0 31 x-insn ;
: LHZX  ( rt ra rb -- ) 279 0 31 x-insn ;
: LHZUX ( rt ra rb -- ) 311 0 31 x-insn ;
: LHAX  ( rt ra rb -- ) 343 0 31 x-insn ;
: LHAUX ( rt ra rb -- ) 375 0 31 x-insn ;
: LWZX  ( rt ra rb -- )  23 0 31 x-insn ;
: LWZUX ( rt ra rb -- )  55 0 31 x-insn ;

! 3.3.2.1 64-bit Fixed-Point Load Instructions
: LWA   ( rt ra ds -- ) -2 shift 2 58 ds-insn ;
: LD    ( rt ra ds -- ) -2 shift 0 58 ds-insn ;
: LDU   ( rt ra ds -- ) -2 shift 1 58 ds-insn ;
: LWAX  ( rt ra rb -- ) 341 0 31 x-insn ;
: LWAUX ( rt ra rb -- ) 373 0 31 x-insn ;
: LDX   ( rt ra rb -- )  21 0 31 x-insn ;
: LDUX  ( rt ra rb -- )  53 0 31 x-insn ;

! 3.3.3 Fixed-Point Store Instructions
: STB   ( rs ra  d -- ) 38 d-insn ;
: STBU  ( rs ra  d -- ) 39 d-insn ;
: STH   ( rs ra  d -- ) 44 d-insn ;
: STHU  ( rs ra  d -- ) 45 d-insn ;
: STW   ( rs ra  d -- ) 36 d-insn ;
: STWU  ( rs ra  d -- ) 37 d-insn ;
: STBX  ( rs ra rb -- ) 215 0 31 x-insn ;
: STBUX ( rs ra rb -- ) 247 0 31 x-insn ;
: STHX  ( rs ra rb -- ) 407 0 31 x-insn ;
: STHUX ( rs ra rb -- ) 439 0 31 x-insn ;
: STWX  ( rs ra rb -- ) 151 0 31 x-insn ;
: STWUX ( rs ra rb -- ) 183 0 31 x-insn ;

! 3.3.3.1 64-bit Fixed-Point Store Instructions
: STD   ( rs ra ds -- ) -2 shift 0 62 ds-insn ;
: STDU  ( rs ra ds -- ) -2 shift 1 62 ds-insn ;
: STDX  ( rs ra rb -- ) 149 0 31 x-insn ;
: STDUX ( rs ra rb -- ) 181 0 31 x-insn ;

! 3.3.4 Fixed-Point Load and Store with Byte Reversal Instructions
: LHBRX  ( rt ra rb -- ) 790 0 31 x-insn ;
: LWBRX  ( rt ra rb -- ) 534 0 31 x-insn ;
: STHBRX ( rs ra rb -- ) 918 0 31 x-insn ;
: STWBRX ( rs ra rb -- ) 662 0 31 x-insn ;

! 3.3.4.1 64-bit Fixed-Point Load and Store with Byte Reversal Instructions
: LDBRX  ( rt ra rb -- ) 532 0 31 x-insn ;
: STDBRX ( rs ra rb -- ) 660 0 31 x-insn ;

! 3.3.5 Fixed-Point Load and Store Multiple Instructions
: LMW  ( rt ra d -- ) 46 d-insn ;
: STMW ( rs ra d -- ) 47 d-insn ;

! 3.3.6 Fixed-Point Move Assist Instructions
: LSWI  ( rt ra nb -- ) 597 0 31 x-insn ;
: LSWX  ( rt ra rb -- ) 533 0 31 x-insn ;
: STSWI ( rs ra nb -- ) 725 0 31 x-insn ;
: STSWX ( rs ra rb -- ) 661 0 31 x-insn ;

! 3.3.8 Fixed-Point Arithmetic Instructions
: ADDI     ( rt ra si -- ) 14 d-insn ;
: ADDIS    ( rt ra si -- ) 15 d-insn ;
: ADDIC    ( rt ra si -- ) 12 d-insn ;
: ADDIC.   ( rt ra si -- ) 13 d-insn ;
: SUBFIC   ( rt ra si -- )  8 d-insn ;
: MULLI    ( rt ra si -- )  7 d-insn ;
: ADD      ( rt ra rb -- ) 0 266 0 31 xo-insn ;
: ADD.     ( rt ra rb -- ) 0 266 1 31 xo-insn ;
: ADDO     ( rt ra rb -- ) 1 266 0 31 xo-insn ;
: ADDO.    ( rt ra rb -- ) 1 266 1 31 xo-insn ;
: ADDC     ( rt ra rb -- ) 0  10 0 31 xo-insn ;
: ADDC.    ( rt ra rb -- ) 0  10 1 31 xo-insn ;
: ADDCO    ( rt ra rb -- ) 1  10 0 31 xo-insn ;
: ADDCO.   ( rt ra rb -- ) 1  10 1 31 xo-insn ;
: ADDE     ( rt ra rb -- ) 0 138 0 31 xo-insn ;
: ADDE.    ( rt ra rb -- ) 0 138 1 31 xo-insn ;
: ADDEO    ( rt ra rb -- ) 1 138 0 31 xo-insn ;
: ADDEO.   ( rt ra rb -- ) 1 138 1 31 xo-insn ;
: ADDME    ( rt ra -- ) 0 0 234 0 31 xo-insn ;
: ADDME.   ( rt ra -- ) 0 0 234 1 31 xo-insn ;
: ADDMEO   ( rt ra -- ) 0 1 234 0 31 xo-insn ;
: ADDMEO.  ( rt ra -- ) 0 1 234 1 31 xo-insn ;
: ADDZE    ( rt ra -- ) 0 0 202 0 31 xo-insn ;
: ADDZE.   ( rt ra -- ) 0 0 202 1 31 xo-insn ;
: ADDZEO   ( rt ra -- ) 0 1 202 0 31 xo-insn ;
: ADDZEO.  ( rt ra -- ) 0 1 202 1 31 xo-insn ;
: SUBF     ( rt ra rb -- ) 0  40 0 31 xo-insn ;
: SUBF.    ( rt ra rb -- ) 0  40 1 31 xo-insn ;
: SUBFO    ( rt ra rb -- ) 1  40 0 31 xo-insn ;
: SUBFO.   ( rt ra rb -- ) 1  40 1 31 xo-insn ;
: SUBFC    ( rt ra rb -- ) 0   8 0 31 xo-insn ;
: SUBFC.   ( rt ra rb -- ) 0   8 1 31 xo-insn ;
: SUBFCO   ( rt ra rb -- ) 1   8 0 31 xo-insn ;
: SUBFCO.  ( rt ra rb -- ) 1   8 1 31 xo-insn ;
: SUBFE    ( rt ra rb -- ) 0 136 0 31 xo-insn ;
: SUBFE.   ( rt ra rb -- ) 0 136 1 31 xo-insn ;
: SUBFEO   ( rt ra rb -- ) 1 136 0 31 xo-insn ;
: SUBFEO.  ( rt ra rb -- ) 1 136 1 31 xo-insn ;
: SUBFME   ( rt ra -- ) 0 0 232 0 31 xo-insn ;
: SUBFME.  ( rt ra -- ) 0 0 232 1 31 xo-insn ;
: SUBFMEO  ( rt ra -- ) 0 1 232 0 31 xo-insn ;
: SUBFMEO. ( rt ra -- ) 0 1 232 1 31 xo-insn ;
: SUBFZE   ( rt ra -- ) 0 0 200 0 31 xo-insn ;
: SUBFZE.  ( rt ra -- ) 0 0 200 1 31 xo-insn ;
: SUBFZEO  ( rt ra -- ) 0 1 200 0 31 xo-insn ;
: SUBFZEO. ( rt ra -- ) 0 1 200 1 31 xo-insn ;
: NEG      ( rt ra -- ) 0 0 104 0 31 xo-insn ;
: NEG.     ( rt ra -- ) 0 0 104 1 31 xo-insn ;
: NEGO     ( rt ra -- ) 0 1 104 0 31 xo-insn ;
: NEGO.    ( rt ra -- ) 0 1 104 1 31 xo-insn ;
: MULLW    ( rt ra rb -- ) 0 235 0 31 xo-insn ;
: MULLW.   ( rt ra rb -- ) 0 235 1 31 xo-insn ;
: MULLWO   ( rt ra rb -- ) 1 235 0 31 xo-insn ;
: MULLWO.  ( rt ra rb -- ) 1 235 1 31 xo-insn ;
: MULHW    ( rt ra rb -- ) 0  75 0 31 xo-insn ;
: MULHW.   ( rt ra rb -- ) 0  75 1 31 xo-insn ;
: MULHWU   ( rt ra rb -- ) 0  11 0 31 xo-insn ;
: MULHWU.  ( rt ra rb -- ) 0  11 1 31 xo-insn ;
: DIVW     ( rt ra rb -- ) 0 491 0 31 xo-insn ;
: DIVW.    ( rt ra rb -- ) 0 491 1 31 xo-insn ;
: DIVWO    ( rt ra rb -- ) 1 491 0 31 xo-insn ;
: DIVWO.   ( rt ra rb -- ) 1 491 1 31 xo-insn ;
: DIVWU    ( rt ra rb -- ) 0 459 0 31 xo-insn ;
: DIVWU.   ( rt ra rb -- ) 0 459 1 31 xo-insn ;
: DIVWUO   ( rt ra rb -- ) 1 459 0 31 xo-insn ;
: DIVWUO.  ( rt ra rb -- ) 1 459 1 31 xo-insn ;
: DIVWE    ( rt ra rb -- ) 0 427 0 31 xo-insn ;
: DIVWE.   ( rt ra rb -- ) 0 427 1 31 xo-insn ;
: DIVWEO   ( rt ra rb -- ) 1 427 0 31 xo-insn ;
: DIVWEO.  ( rt ra rb -- ) 1 427 1 31 xo-insn ;
: DIVWEU   ( rt ra rb -- ) 0 395 0 31 xo-insn ;
: DIVWEU.  ( rt ra rb -- ) 0 395 1 31 xo-insn ;
: DIVWEUO  ( rt ra rb -- ) 1 395 0 31 xo-insn ;
: DIVWEUO. ( rt ra rb -- ) 1 395 1 31 xo-insn ;

! 3.3.8.1 64-bit Fixed-Point Arithmetic Instructions
: MULLD    ( rt ra rb -- ) 0 233 0 31 xo-insn ;
: MULLD.   ( rt ra rb -- ) 0 233 1 31 xo-insn ;
: MULLDO   ( rt ra rb -- ) 1 233 0 31 xo-insn ;
: MULLDO.  ( rt ra rb -- ) 1 233 1 31 xo-insn ;
: MULHD    ( rt ra rb -- ) 0  73 0 31 xo-insn ;
: MULHD.   ( rt ra rb -- ) 0  73 1 31 xo-insn ;
: MULHDU   ( rt ra rb -- ) 0   9 0 31 xo-insn ;
: MULHDU.  ( rt ra rb -- ) 0   9 1 31 xo-insn ;
: DIVD     ( rt ra rb -- ) 0 489 0 31 xo-insn ;
: DIVD.    ( rt ra rb -- ) 0 489 1 31 xo-insn ;
: DIVDO    ( rt ra rb -- ) 1 489 0 31 xo-insn ;
: DIVDO.   ( rt ra rb -- ) 1 489 1 31 xo-insn ;
: DIVDU    ( rt ra rb -- ) 0 457 0 31 xo-insn ;
: DIVDU.   ( rt ra rb -- ) 0 457 1 31 xo-insn ;
: DIVDUO   ( rt ra rb -- ) 1 457 0 31 xo-insn ;
: DIVDUO.  ( rt ra rb -- ) 1 457 1 31 xo-insn ;
: DIVDE    ( rt ra rb -- ) 0 425 0 31 xo-insn ;
: DIVDE.   ( rt ra rb -- ) 0 425 1 31 xo-insn ;
: DIVDEO   ( rt ra rb -- ) 1 425 0 31 xo-insn ;
: DIVDEO.  ( rt ra rb -- ) 1 425 1 31 xo-insn ;
: DIVDEU   ( rt ra rb -- ) 0 393 0 31 xo-insn ;
: DIVDEU.  ( rt ra rb -- ) 0 393 1 31 xo-insn ;
: DIVDEUO  ( rt ra rb -- ) 1 393 0 31 xo-insn ;
: DIVDEUO. ( rt ra rb -- ) 1 393 1 31 xo-insn ;

! 3.3.9 Fixed-Point Compare Instructions
: CMPI  ( bf l ra si -- ) [ [ 2 shift ] dip bitor ] 2dip 11 d-insn ;
: CMPLI ( bf l ra ui -- ) [ [ 2 shift ] dip bitor ] 2dip 10 d-insn ;
: CMP   ( bf l ra rb -- ) [ [ 2 shift ] dip bitor ] 2dip  0 0 31 x-insn ;
: CMPL  ( bf l ra rb -- ) [ [ 2 shift ] dip bitor ] 2dip 32 0 31 x-insn ;

! 3.3.10 Fixed-Point Trap Instructions
: TWI ( to ra si -- ) 3 d-insn ;
: TDI ( to ra si -- ) 2 d-insn ;
: TW  ( to ra rb -- )  4 0 31 x-insn ;
: TD  ( to ra rb -- ) 68 0 31 x-insn ;

! 3.3.11 Fixed-Point Select
: ISEL ( rt ra rb bc -- ) 15 0 31 a-insn ;

! 3.3.12 Fixed-Point Logical Instructions
: ANDI.   ( ra rs ui -- ) swapd 28 d-insn ;
: ANDIS.  ( ra rs ui -- ) swapd 29 d-insn ;
: ORI     ( ra rs ui -- ) swapd 24 d-insn ;
: ORIS    ( ra rs ui -- ) swapd 25 d-insn ;
: XORI    ( ra rs ui -- ) swapd 26 d-insn ;
: XORIS   ( ra rs ui -- ) swapd 27 d-insn ;
: AND     ( ra rs rb -- ) swapd  28 0 31 x-insn ;
: AND.    ( ra rs rb -- ) swapd  28 1 31 x-insn ;
: OR      ( ra rs rb -- ) swapd 444 0 31 x-insn ;
: OR.     ( ra rs rb -- ) swapd 444 1 31 x-insn ;
: XOR     ( ra rs rb -- ) swapd 316 0 31 x-insn ;
: XOR.    ( ra rs rb -- ) swapd 316 1 31 x-insn ;
: NAND    ( ra rs rb -- ) swapd 476 0 31 x-insn ;
: NAND.   ( ra rs rb -- ) swapd 476 1 31 x-insn ;
: NOR     ( ra rs rb -- ) swapd 124 0 31 x-insn ;
: NOR.    ( ra rs rb -- ) swapd 124 1 31 x-insn ;
: ANDC    ( ra rs rb -- ) swapd  60 0 31 x-insn ;
: ANDC.   ( ra rs rb -- ) swapd  60 1 31 x-insn ;
: EQV     ( ra rs rb -- ) swapd 284 0 31 x-insn ;
: EQV.    ( ra rs rb -- ) swapd 284 1 31 x-insn ;
: ORC     ( ra rs rb -- ) swapd 412 0 31 x-insn ;
: ORC.    ( ra rs rb -- ) swapd 412 1 31 x-insn ;
: CMPB    ( ra rs rb -- ) swapd 508 0 31 x-insn ;
: EXTSB   ( ra rs -- ) swap 0 954 0 31 x-insn ;
: EXTSB.  ( ra rs -- ) swap 0 954 1 31 x-insn ;
: EXTSH   ( ra rs -- ) swap 0 922 0 31 x-insn ;
: EXTSH.  ( ra rs -- ) swap 0 922 1 31 x-insn ;
: CNTLZW  ( ra rs -- ) swap 0  26 0 31 x-insn ;
: CNTLZW. ( ra rs -- ) swap 0  26 1 31 x-insn ;
: POPCNTB ( ra rs -- ) swap 0 122 0 31 x-insn ;
: POPCNTW ( ra rs -- ) swap 0 378 0 31 x-insn ;
: PRTYD   ( ra rs -- ) swap 0 186 0 31 x-insn ;
: PRTYW   ( ra rs -- ) swap 0 154 0 31 x-insn ;

! 3.3.12.1 64-bit Fixed-Point Logical Instructions
: EXTSW   ( ra rs -- ) swap 0 986 0 31 x-insn ;
: EXTSW.  ( ra rs -- ) swap 0 986 1 31 x-insn ;
: CNTLZD  ( ra rs -- ) swap 0  58 0 31 x-insn ;
: CNTLZD. ( ra rs -- ) swap 0  58 1 31 x-insn ;
: POPCNTD ( ra rs -- ) swap 0 506 0 31 x-insn ;
: BPERMD  ( ra rs rb -- ) swapd 252 0 31 x-insn ;

! 3.3.13.1 Fixed-Point Rotate and Shift Instructions
: RLWINM  ( ra rs sh mb me -- ) [ swap ] 3dip 0 21 m-insn ;
: RLWINM. ( ra rs sh mb me -- ) [ swap ] 3dip 1 21 m-insn ;
: RLWNM   ( ra rs rb mb me -- ) [ swap ] 3dip 0 23 m-insn ;
: RLWNM.  ( ra rs rb mb me -- ) [ swap ] 3dip 1 23 m-insn ;
: RLWIMI  ( ra rs sh mb me -- ) [ swap ] 3dip 0 20 m-insn ;
: RLWIMI. ( ra rs sh mb me -- ) [ swap ] 3dip 1 20 m-insn ;

! 3.3.13.1 64-bit Fixed-Point Rotate Instructions
: RLDICL  ( ra rs sh mb -- )
    [ swap ] 2dip over [ 0x1f bitand ] [ ] [ -5 shift ]
    tri* 0 swap 0 30 md-insn ;
: RLDICL. ( ra rs sh mb -- )
    [ swap ] 2dip over [ 0x1f bitand ] [ ] [ -5 shift ]
    tri* 0 swap 1 30 md-insn ;
: RLDICR  ( ra rs sh me -- )
    [ swap ] 2dip over [ 0x1f bitand ] [ ] [ -5 shift ]
    tri* 1 swap 0 30 md-insn ;
: RLDICR. ( ra rs sh me -- )
    [ swap ] 2dip over [ 0x1f bitand ] [ ] [ -5 shift ]
    tri* 1 swap 1 30 md-insn ;
: RLDIC   ( ra rs sh mb -- )
    [ swap ] 2dip over [ 0x1f bitand ] [ ] [ -5 shift ]
    tri* 2 swap 0 30 md-insn ;
: RLDIC.  ( ra rs sh mb -- )
    [ swap ] 2dip over [ 0x1f bitand ] [ ] [ -5 shift ]
    tri* 2 swap 1 30 md-insn ;
: RLDCL   ( ra rs rb mb -- ) [ swap ] 2dip 8 0 30 mds-insn ;
: RLDCL.  ( ra rs rb mb -- ) [ swap ] 2dip 8 1 30 mds-insn ;
: RLDCR   ( ra rs rb me -- ) [ swap ] 2dip 9 0 30 mds-insn ;
: RLDCR.  ( ra rs rb me -- ) [ swap ] 2dip 9 1 30 mds-insn ;
: RLDIMI  ( ra rs sh mb -- )
    [ swap ] 2dip over [ 0x1f bitand ] [ ] [ -5 shift ]
    tri* 3 swap 0 30 md-insn ;
: RLDIMI. ( ra rs sh mb -- )
    [ swap ] 2dip over [ 0x1f bitand ] [ ] [ -5 shift ]
    tri* 3 swap 1 30 md-insn ;

! 3.3.13.2 Fixed-Point Shift Instructions
: SLW    ( ra rs rb -- ) swapd 24  0 31 x-insn ;
: SLW.   ( ra rs rb -- ) swapd 24  1 31 x-insn ;
: SRW    ( ra rs rb -- ) swapd 536 0 31 x-insn ;
: SRW.   ( ra rs rb -- ) swapd 536 1 31 x-insn ;
: SRAWI  ( ra rs sh -- ) swapd 824 0 31 x-insn ;
: SRAWI. ( ra rs sh -- ) swapd 824 1 31 x-insn ;
: SRAW   ( ra rs rb -- ) swapd 792 0 31 x-insn ;
: SRAW.  ( ra rs rb -- ) swapd 792 1 31 x-insn ;

! 3.3.13.2.1 64-bit Fixed-Point Shift Instructions
: SLD    ( ra rs rb -- ) swapd  27 0 31 x-insn ;
: SLD.   ( ra rs rb -- ) swapd  27 1 31 x-insn ;
: SRD    ( ra rs rb -- ) swapd 539 0 31 x-insn ;
: SRD.   ( ra rs rb -- ) swapd 539 1 31 x-insn ;
: SRAD   ( ra rs rb -- ) swapd 794 0 31 x-insn ;
: SRAD.  ( ra rs rb -- ) swapd 794 1 31 x-insn ;
: SRADI  ( ra rs sh -- )
    swapd [ 0x1f bitand ] [ -5 shift ] bi
    413 swap 0 31 xs-insn ;
: SRADI. ( ra rs sh -- )
    swapd [ 0x1f bitand ] [ -5 shift ] bi
    413 swap 1 31 xs-insn ;

! 3.3.14 BCD Assist Instructions
: CDTBCD ( ra rs -- ) swap 0 282 0 31 x-insn ;
: CBCDTD ( ra rs -- ) swap 0 314 0 31 x-insn ;
: ADDG6S ( rt ra rb -- ) 0 74 0 31 xo-insn ;

! 3.3.15 Move To/From System Register Instructions
: MTSPR ( spr rs -- ) swap 467 0 31 xfx-insn ;
: MFSPR ( rt spr -- ) 339 0 31 xfx-insn ;
: MTCRF ( fxm rs -- ) swap 0xff bitand 1 shift 144 0 31 xfx-insn ;
: MFCR ( rt -- ) 0 19 0 31 xfx-insn ;

! 3.3.15.1 Move To/From One Condition Register Field Instructions
: MTOCRF ( fxm rs -- ) swap 0x100 bitor 1 shift 144 0 31 xfx-insn ;
: MFOCRF ( rt fxm -- ) 0x100 bitor 1 shift 19 0 31 xfx-insn ;

! 3.3.15.2 Move To/From System Registers (Category: Embedded)
: MCRXR ( bf -- ) 2 shift 0 0 512 0 31 x-insn ;
: MTDCRUX ( rs ra -- ) 0 419 0 31 x-insn ;
: MFDCRUX ( rt ra -- ) 0 291 0 31 x-insn ;

! 4.6.2 Floating-Point Load Instructions
: LFS    ( frt ra  d -- ) 48 d-insn ;
: LFSU   ( frt ra  d -- ) 49 d-insn ;
: LFD    ( frt ra  d -- ) 50 d-insn ;
: LFDU   ( frt ra  d -- ) 51 d-insn ;
: LFSX   ( frt ra rb -- ) 535 0 31 x-insn ;
: LFSUX  ( frt ra rb -- ) 567 0 31 x-insn ;
: LFDX   ( frt ra rb -- ) 599 0 31 x-insn ;
: LFDUX  ( frt ra rb -- ) 631 0 31 x-insn ;
: LFIWAX ( frt ra rb -- ) 855 0 31 x-insn ;
: LFIWZX ( frt ra rb -- ) 887 0 31 x-insn ;

! 4.6.3 Floating-Point Store Instructions
: STFS   ( frs ra d -- ) 52 d-insn ;
: STFSU  ( frs ra d -- ) 53 d-insn ;
: STFD   ( frs ra d -- ) 54 d-insn ;
: STFDU  ( frs ra d -- ) 55 d-insn ;
: STFSX  ( frs ra rb -- ) 663 0 31 x-insn ;
: STFSUX ( frs ra rb -- ) 695 0 31 x-insn ;
: STFDX  ( frs ra rb -- ) 727 0 31 x-insn ;
: STFDUX ( frs ra rb -- ) 759 0 31 x-insn ;
: STFIWX ( frs ra rb -- ) 983 0 31 x-insn ;

! 4.6.4 Floating-Point Load Store Doubleword Pair Instructions
: LFDP   ( frtp ra ds -- ) 0 57 ds-insn ; deprecated
: STFDP  ( frsp ra ds -- ) 0 61 ds-insn ; deprecated
: LFDPX  ( frtp ra rb -- ) 791 0 31 x-insn ; deprecated
: STFDPX ( frsp ra rb -- ) 919 0 31 x-insn ; deprecated

! 4.6.5 Floating-Point Move Instructions
: FMR     ( frt frb -- ) [ 0 ] dip  72 0 63 x-insn ;
: FMR.    ( frt frb -- ) [ 0 ] dip  72 1 63 x-insn ;
: FABS    ( frt frb -- ) [ 0 ] dip 264 0 63 x-insn ;
: FABS.   ( frt frb -- ) [ 0 ] dip 264 1 63 x-insn ;
: FNABS   ( frt frb -- ) [ 0 ] dip 136 0 63 x-insn ;
: FNABS.  ( frt frb -- ) [ 0 ] dip 136 1 63 x-insn ;
: FNEG    ( frt frb -- ) [ 0 ] dip  40 0 63 x-insn ;
: FNEG.   ( frt frb -- ) [ 0 ] dip  40 1 63 x-insn ;
: FCPSGN  ( frt fra frb -- ) 8 0 63 x-insn ;
: FCPSGN. ( frt fra frb -- ) 8 1 63 x-insn ;

! 4.6.6.1 Floating-Point Elementary Arithmetic Instructions
: FADD      ( frt fra frb -- ) 0 21 0 63 a-insn ;
: FADD.     ( frt fra frb -- ) 0 21 1 63 a-insn ;
: FADDS     ( frt fra frb -- ) 0 21 0 59 a-insn ;
: FADDS.    ( frt fra frb -- ) 0 21 1 59 a-insn ;
: FSUB      ( frt fra frb -- ) 0 20 0 63 a-insn ;
: FSUB.     ( frt fra frb -- ) 0 20 1 63 a-insn ;
: FSUBS     ( frt fra frb -- ) 0 20 0 59 a-insn ;
: FSUBS.    ( frt fra frb -- ) 0 20 1 59 a-insn ;
: FMUL      ( frt fra frc -- ) 0 swap 25 0 63 a-insn ;
: FMUL.     ( frt fra frc -- ) 0 swap 25 1 63 a-insn ;
: FMULS     ( frt fra frb -- ) 0 25 0 59 a-insn ;
: FMULS.    ( frt fra frb -- ) 0 25 1 59 a-insn ;
: FDIV      ( frt fra frb -- ) 0 18 0 63 a-insn ;
: FDIV.     ( frt fra frb -- ) 0 18 1 63 a-insn ;
: FDIVS     ( frt fra frb -- ) 0 18 0 59 a-insn ;
: FDIVS.    ( frt fra frb -- ) 0 18 1 59 a-insn ;
: FSQRT     ( frt frb -- ) [ 0 ] dip 0 22 0 63 a-insn ;
: FSQRT.    ( frt frb -- ) [ 0 ] dip 0 22 1 63 a-insn ;
: FSQRTS    ( frt frb -- ) [ 0 ] dip 0 22 0 59 a-insn ;
: FSQRTS.   ( frt frb -- ) [ 0 ] dip 0 22 1 59 a-insn ;
: FRE       ( frt frb -- ) [ 0 ] dip 0 24 0 63 a-insn ;
: FRE.      ( frt frb -- ) [ 0 ] dip 0 24 1 63 a-insn ;
: FRES      ( frt frb -- ) [ 0 ] dip 0 24 0 59 a-insn ;
: FRES.     ( frt frb -- ) [ 0 ] dip 0 24 1 59 a-insn ;
: FRSQRTE   ( frt frb -- ) [ 0 ] dip 0 26 0 63 a-insn ;
: FRSQRTE.  ( frt frb -- ) [ 0 ] dip 0 26 1 63 a-insn ;
: FRSQRTES  ( frt frb -- ) [ 0 ] dip 0 26 0 59 a-insn ;
: FRSQRTES. ( frt frb -- ) [ 0 ] dip 0 26 1 59 a-insn ;
: FTDIV     ( bf fra frb -- ) [ 2 shift ] 2dip 128 0 63 x-insn ;
: FTSQRT    ( bf frb -- ) [ 2 shift 0 ] dip 160 0 63 x-insn ;

! 4.6.6.2 Floating-Point Multiply-Add Instructions
: FMADD    ( frt fra frc frb -- ) swap 29 0 63 a-insn ;
: FMADD.   ( frt fra frc frb -- ) swap 29 1 63 a-insn ;
: FMADDS   ( frt fra frc frb -- ) swap 29 0 59 a-insn ;
: FMADDS.  ( frt fra frc frb -- ) swap 29 1 59 a-insn ;
: FMSUB    ( frt fra frc frb -- ) swap 28 0 63 a-insn ;
: FMSUB.   ( frt fra frc frb -- ) swap 28 1 63 a-insn ;
: FMSUBS   ( frt fra frc frb -- ) swap 28 0 59 a-insn ;
: FMSUBS.  ( frt fra frc frb -- ) swap 28 1 59 a-insn ;
: FNMADD   ( frt fra frc frb -- ) swap 31 0 63 a-insn ;
: FNMADD.  ( frt fra frc frb -- ) swap 31 1 63 a-insn ;
: FNMADDS  ( frt fra frc frb -- ) swap 31 0 59 a-insn ;
: FNMADDS. ( frt fra frc frb -- ) swap 31 1 59 a-insn ;
: FNMSUB   ( frt fra frc frb -- ) swap 30 0 63 a-insn ;
: FNMSUB.  ( frt fra frc frb -- ) swap 30 1 63 a-insn ;
: FNMSUBS  ( frt fra frc frb -- ) swap 30 0 59 a-insn ;
: FNMSUBS. ( frt fra frc frb -- ) swap 30 1 59 a-insn ;

! 4.6.7.1 Floating-Point Rounding Instruction
: FRSP  ( frt frb -- ) [ 0 ] dip 12 0 63 x-insn ;
: FRSP. ( frt frb -- ) [ 0 ] dip 12 1 63 x-insn ;

! 4.6.7.2 Floating-Point Convert To/From Integer Instructions
: FCTID    ( frt frb -- ) [ 0 ] dip 814 0 63 x-insn ;
: FCTID.   ( frt frb -- ) [ 0 ] dip 814 1 63 x-insn ;
: FCTIDZ   ( frt frb -- ) [ 0 ] dip 815 0 63 x-insn ;
: FCTIDZ.  ( frt frb -- ) [ 0 ] dip 815 1 63 x-insn ;
: FCTIDU   ( frt frb -- ) [ 0 ] dip 942 0 63 x-insn ;
: FCTIDU.  ( frt frb -- ) [ 0 ] dip 942 1 63 x-insn ;
: FCTIDUZ  ( frt frb -- ) [ 0 ] dip 943 0 63 x-insn ;
: FCTIDUZ. ( frt frb -- ) [ 0 ] dip 943 1 63 x-insn ;
: FCTIW    ( frt frb -- ) [ 0 ] dip  14 0 63 x-insn ;
: FCTIW.   ( frt frb -- ) [ 0 ] dip  14 1 63 x-insn ;
: FCTIWZ   ( frt frb -- ) [ 0 ] dip  15 0 63 x-insn ;
: FCTIWZ.  ( frt frb -- ) [ 0 ] dip  15 1 63 x-insn ;
: FCTIWU   ( frt frb -- ) [ 0 ] dip 142 0 63 x-insn ;
: FCTIWU.  ( frt frb -- ) [ 0 ] dip 142 1 63 x-insn ;
: FCTIWUZ  ( frt frb -- ) [ 0 ] dip 143 0 63 x-insn ;
: FCTIWUZ. ( frt frb -- ) [ 0 ] dip 143 1 63 x-insn ;
: FCFID    ( frt frb -- ) [ 0 ] dip 846 0 63 x-insn ;
: FCFID.   ( frt frb -- ) [ 0 ] dip 846 1 63 x-insn ;
: FCFIDU   ( frt frb -- ) [ 0 ] dip 974 0 63 x-insn ;
: FCFIDU.  ( frt frb -- ) [ 0 ] dip 974 1 63 x-insn ;
: FCFIDS   ( frt frb -- ) [ 0 ] dip 846 0 59 x-insn ;
: FCFIDS.  ( frt frb -- ) [ 0 ] dip 846 1 59 x-insn ;
: FCFIDUS  ( frt frb -- ) [ 0 ] dip 974 0 59 x-insn ;
: FCFIDUS. ( frt frb -- ) [ 0 ] dip 974 1 59 x-insn ;

! 4.6.7.3 Floating Round to Integer Instructions
: FRIN  ( frt frb -- ) [ 0 ] dip 392 0 63 x-insn ;
: FRIN. ( frt frb -- ) [ 0 ] dip 392 1 63 x-insn ;
: FRIZ  ( frt frb -- ) [ 0 ] dip 424 0 63 x-insn ;
: FRIZ. ( frt frb -- ) [ 0 ] dip 424 1 63 x-insn ;
: FRIP  ( frt frb -- ) [ 0 ] dip 456 0 63 x-insn ;
: FRIP. ( frt frb -- ) [ 0 ] dip 456 1 63 x-insn ;
: FRIM  ( frt frb -- ) [ 0 ] dip 488 0 63 x-insn ;
: FRIM. ( frt frb -- ) [ 0 ] dip 488 1 63 x-insn ;

! 4.6.8 Floating-Point Compare Instructions
: FCMPU ( bf fra frb -- ) [ 2 shift ] 2dip  0 0 63 x-insn ;
: FCMPO ( bf fra frb -- ) [ 2 shift ] 2dip 32 0 63 x-insn ;

! 4.6.9 Floating-Point Select Instruction
: FSEL  ( frt fra frc frb -- ) swap 23 0 63 a-insn ;
: FSEL. ( frt fra frc frb -- ) swap 23 1 63 a-insn ;

! 4.6.10 Floating-Point Status and Control Register Instructions
: MFFS    ( frt -- ) 0 0 583 0 63 x-insn ;
: MFFS.   ( frt -- ) 0 0 583 1 63 x-insn ;
: MCRFS   ( bf bfa -- ) [ 2 shift ] bi@ 0 64 0 63 x-insn ;
: MTFSFI  ( bf u w -- ) swap [ 2 shift ] [ 1 bitand ] [ 1 shift ]
tri* 134 0 63 x-insn ;
: MTFSFI. ( bf u w -- ) swap [ 2 shift ] [ 1 bitand ] [ 1 shift ]
tri* 134 1 63 x-insn ;
:: MTFSF  ( flm frb l w -- ) l flm w frb 711 0 63 xfl-insn ;
:: MTFSF. ( flm frb l w -- ) l flm w frb 711 1 63 xfl-insn ;
: MTFSB0  ( bt -- ) 0 0 70 0 63 x-insn ;
: MTFSB0. ( bt -- ) 0 0 70 1 63 x-insn ;
: MTFSB1  ( bt -- ) 0 0 38 0 63 x-insn ;
: MTFSB1. ( bt -- ) 0 0 38 1 63 x-insn ;

! 5.6.1 DFP Arithmetic Instructions
: DADD   ( frt  fra  frb  -- )   2 0 59 x-insn ;
: DADD.  ( frt  fra  frb  -- )   2 1 59 x-insn ;
: DADDQ  ( frtp frap frbp -- )   2 0 63 x-insn ;
: DADDQ. ( frtp frap frbp -- )   2 1 63 x-insn ;
: DSUB   ( frt  fra  frb  -- ) 514 0 59 x-insn ;
: DSUB.  ( frt  fra  frb  -- ) 514 1 59 x-insn ;
: DSUBQ  ( frtp frap frbp -- ) 514 0 63 x-insn ;
: DSUBQ. ( frtp frap frbp -- ) 514 1 63 x-insn ;
: DMUL   ( frp  fra  frb  -- )  34 0 59 x-insn ;
: DMUL.  ( frt  fra  frb  -- )  34 1 59 x-insn ;
: DMULQ  ( frtp frap frbp -- )  34 0 63 x-insn ;
: DMULQ. ( frtp frap frbp -- )  34 1 63 x-insn ;
: DDIV   ( frp  fra  frb  -- ) 546 0 59 x-insn ;
: DDIV.  ( frt  fra  frb  -- ) 546 1 59 x-insn ;
: DDIVQ  ( frtp frap frbp -- ) 546 0 63 x-insn ;
: DDIVQ. ( frtp frap frbp -- ) 546 1 63 x-insn ;

! 5.6.2 DFP Compare Instructions
: DCMPU  ( bf fra  frb  -- ) [ 2 shift ] 2dip 642 0 59 x-insn ;
: DCMPUQ ( bf frap frbp -- ) [ 2 shift ] 2dip 642 0 63 x-insn ;
: DCMPO  ( bf fra  frb  -- ) [ 2 shift ] 2dip 130 0 59 x-insn ;
: DCMPOQ ( bf frap frbp -- ) [ 2 shift ] 2dip 130 0 63 x-insn ;

! 5.6.3 DFP Test Instructions
: DTSTDC  ( bf fra  dcm  -- ) [ 2 shift ] 2dip 194 0 59 z22-insn ;
: DTSTDCQ ( bf frap dgm  -- ) [ 2 shift ] 2dip 194 0 63 z22-insn ;
: DTSTDG  ( bf fra  dcm  -- ) [ 2 shift ] 2dip 226 0 59 z22-insn ;
: DTSTDGQ ( bf frap dgm  -- ) [ 2 shift ] 2dip 226 0 63 z22-insn ;
: DTSTEX  ( bf fra  frb  -- ) [ 2 shift ] 2dip 162 0 59 x-insn ;
: DTSTEXQ ( bf frap frbp -- ) [ 2 shift ] 2dip 162 0 63 x-insn ;
: DTSTSF  ( bf fra  frb  -- ) [ 2 shift ] 2dip 674 0 59 x-insn ;
: DTSTSFQ ( bf frap frbp -- ) [ 2 shift ] 2dip 674 0 63 x-insn ;

! 5.6.4 DFP Quantum Adjustment Instructions
: DQUAI    ( te   frt  frb  rmc -- ) [ swap ] 2dip 67 0 59 z23-insn ;
: DQUAI.   ( te   frt  frb  rmc -- ) [ swap ] 2dip 67 1 59 z23-insn ;
: DQUAIQ   ( te   frtp frbp rmc -- ) [ swap ] 2dip 67 0 63 z23-insn ;
: DQUAIQ.  ( te   frtp frbp rmc -- ) [ swap ] 2dip 67 1 63 z23-insn ;
: DQUA     ( frt  fra  frb  rmc -- )   3 0 59 z23-insn ;
: DQUA.    ( frt  fra  frb  rmc -- )   3 1 59 z23-insn ;
: DQUAQ    ( frtp frap frbp rmc -- )   3 0 63 z23-insn ;
: DQUAQ.   ( frtp frap frbp rmc -- )   3 1 63 z23-insn ;
: DRRND    ( frt  fra  frb  rmc -- )  35 0 59 z23-insn ;
: DRRND.   ( frt  fra  frb  rmc -- )  35 1 59 z23-insn ;
: DRRNDQ   ( frtp frap frbp rmc -- )  35 0 63 z23-insn ;
: DRRNDQ.  ( frtp frap frbp rmc -- )  35 1 63 z23-insn ;
: DRINTX   ( r    frt  frb  rmc -- ) [ swap ] 2dip  99 0 59 z23-insn ;
: DRINTX.  ( r    frt  frb  rmc -- ) [ swap ] 2dip  99 1 59 z23-insn ;
: DRINTXQ  ( r    frtp frbp rmc -- ) [ swap ] 2dip  99 0 63 z23-insn ;
: DRINTXQ. ( r    frtp frbp rmc -- ) [ swap ] 2dip  99 1 63 z23-insn ;
: DRINTN   ( r    frt  frb  rmc -- ) [ swap ] 2dip 227 0 59 z23-insn ;
: DRINTN.  ( r    frt  frb  rmc -- ) [ swap ] 2dip 227 1 59 z23-insn ;
: DRINTNQ  ( r    frtp frbp rmc -- ) [ swap ] 2dip 227 0 63 z23-insn ;
: DRINTNQ. ( r    frtp frbp rmc -- ) [ swap ] 2dip 227 1 63 z23-insn ;

! 5.6.5.1 DFP Data-Format Conversion Instructions
: DCTDP   ( frt  frb  -- ) 0 swap 258 0 59 x-insn ;
: DCTDP.  ( frt  frb  -- ) 0 swap 258 1 59 x-insn ;
: DCTQPQ  ( frtp frbp -- ) 0 swap 258 0 63 x-insn ;
: DCTQPQ. ( frtp frbp -- ) 0 swap 258 1 63 x-insn ;
: DSRP    ( frt  frb  -- ) 0 swap 770 0 59 x-insn ;
: DSRP.   ( frt  frb  -- ) 0 swap 770 1 59 x-insn ;
: DRDPQ   ( frtp frbp -- ) 0 swap 770 0 63 x-insn ;
: DRDPQ.  ( frtp frbp -- ) 0 swap 770 1 63 x-insn ;

! 5.6.5.2 DFP Data-Type Conversion Instructions
: DCFFIX   ( frt  frb  -- ) 0 swap 802 0 59 x-insn ;
: DCFFIX.  ( frt  frb  -- ) 0 swap 802 1 59 x-insn ;
: DCFFIXQ  ( frtp frbp -- ) 0 swap 802 0 63 x-insn ;
: DCFFIXQ. ( frtp frbp -- ) 0 swap 802 1 63 x-insn ;
: DCTFIX   ( frt  frb  -- ) 0 swap 290 0 59 x-insn ;
: DCTFIX.  ( frt  frb  -- ) 0 swap 290 1 59 x-insn ;
: DCTFIXQ  ( frtp frbp -- ) 0 swap 290 0 63 x-insn ;
: DCTFIXQ. ( frtp frbp -- ) 0 swap 290 1 63 x-insn ;

! 5.6.6 DFP Format Instructions
: DDEDPD   ( sp   frt  frb  -- ) [ swap 3 shift ] dip 322 0 59 x-insn ;
: DDEDPD.  ( sp   frt  frb  -- ) [ swap 3 shift ] dip 322 1 59 x-insn ;
: DDEDPDQ  ( sp   frtp frbp -- ) [ swap 3 shift ] dip 322 0 63 x-insn ;
: DDEDPDQ. ( sp   frtp frbp -- ) [ swap 3 shift ] dip 322 1 63 x-insn ;
: DENBCD   ( s    frt  frb  -- ) [ swap 4 shift ] dip 834 0 59 x-insn ;
: DENBCD.  ( s    frt  frb  -- ) [ swap 4 shift ] dip 834 1 59 x-insn ;
: DENBCDQ  ( s    frtp frbp -- ) [ swap 4 shift ] dip 834 0 63 x-insn ;
: DENBCDQ. ( s    frtp frbp -- ) [ swap 4 shift ] dip 834 1 63 x-insn ;
: DXEX     ( frt  frb  -- )      0 swap 354 0 59 x-insn ;
: DXEX.    ( frt  frb  -- )      0 swap 354 1 59 x-insn ;
: DXEXQ    ( frtp frbp -- )      0 swap 354 0 63 x-insn ;
: DXEXQ.   ( frtp frbp -- )      0 swap 354 1 63 x-insn ;
: DIEX     ( frt  fra  frb  -- ) 866 0 59 x-insn ;
: DIEX.    ( frt  fra  frb  -- ) 866 1 59 x-insn ;
: DIEXQ    ( frtp frap frbp -- ) 866 0 63 x-insn ;
: DIEXQ.   ( frtp frap frbp -- ) 866 1 63 x-insn ;
: DSCLI    ( frt  fra  sh -- )   66 0 59 z22-insn ;
: DSCLI.   ( frt  fra  sh -- )   66 1 59 z22-insn ;
: DSCLIQ   ( frtp frap sh -- )   66 0 63 z22-insn ;
: DSCLIQ.  ( frtp frap sh -- )   66 1 63 z22-insn ;
: DSCRI    ( frt  fra  sh -- )   98 0 59 z22-insn ;
: DSCRI.   ( frt  fra  sh -- )   98 1 59 z22-insn ;
: DSCRIQ   ( frtp frap sh -- )   98 0 63 z22-insn ;
: DSCRIQ.  ( frtp frap sh -- )   98 1 63 z22-insn ;

! 6.7.2 Vector Load Instructions
: LVEBX ( vrt ra rb -- )   7 0 31 x-insn ;
: LVEHX ( vrt ra rb -- )  39 0 31 x-insn ;
: LVEWX ( vrt ra rb -- )  71 0 31 x-insn ;
: LVX   ( vrt ra rb -- ) 103 0 31 x-insn ;
: LVXL  ( vrt ra rb -- ) 359 0 31 x-insn ;

! 6.7.3 Vector Store Instructions
: STVEBX ( vrs ra rb -- ) 135 0 31 x-insn ;
: STVEHX ( vrs ra rb -- ) 167 0 31 x-insn ;
: STVEWX ( vrs ra rb -- ) 199 0 31 x-insn ;
: STVX   ( vrs ra rb -- ) 231 0 31 x-insn ;
: STVXL  ( vrs ra rb -- ) 487 0 31 x-insn ;

! 6.7.4 Vector Alignment Support Instructions
: LVSL ( vrt ra rb -- )  6 0 31 x-insn ;
: LVSR ( vrt ra rb -- ) 38 0 31 x-insn ;

! 6.8.1 Vector Pack and Unpack Instructions
: VPKUHUM ( vrt vra vrb -- )  14 4 vx-insn ;
: VPKUWUM ( vrt vra vrb -- )  78 4 vx-insn ;
: VPKUHUS ( vrt vra vrb -- ) 142 4 vx-insn ;
: VPKUWUS ( vrt vra vrb -- ) 206 4 vx-insn ;
: VPKSHUS ( vrt vra vrb -- ) 270 4 vx-insn ;
: VPKSWUS ( vrt vra vrb -- ) 334 4 vx-insn ;
: VPKSHSS ( vrt vra vrb -- ) 398 4 vx-insn ;
: VPKSWSS ( vrt vra vrb -- ) 462 4 vx-insn ;
: VPKPX   ( vrt vra vrb -- ) 782 4 vx-insn ;
: VUPKHSB ( vrt vrb -- ) 0 swap 526 4 vx-insn ;
: VUPKHSH ( vrt vrb -- ) 0 swap 590 4 vx-insn ;
: VUPKLSB ( vrt vrb -- ) 0 swap 654 4 vx-insn ;
: VUPKLSH ( vrt vrb -- ) 0 swap 718 4 vx-insn ;
: VUPKHPX ( vrt vrb -- ) 0 swap 846 4 vx-insn ;
: VUPKLPX ( vrt vrb -- ) 0 swap 974 4 vx-insn ;

! 6.8.2 Vector Merge Instructions
: VMRGHB ( vrt vra vrb -- )  12 4 vx-insn ;
: VMRGHH ( vrt vra vrb -- )  76 4 vx-insn ;
: VMRGHW ( vrt vra vrb -- ) 140 4 vx-insn ;
: VMRGLB ( vrt vra vrb -- ) 268 4 vx-insn ;
: VMRGLH ( vrt vra vrb -- ) 332 4 vx-insn ;
: VMRGLW ( vrt vra vrb -- ) 396 4 vx-insn ;

! 6.8.3 Vector Splat Instructions
: VSPLTB ( vrt vrb uim -- ) swap 524 4 vx-insn ;
: VSPLTH ( vrt vrb uim -- ) swap 588 4 vx-insn ;
: VSPLTW ( vrt vrb uim -- ) swap 652 4 vx-insn ;
: VSPLTISB ( vrt sim -- ) 0 780 4 vx-insn ;
: VSPLTISH ( vrt sim -- ) 0 844 4 vx-insn ;
: VSPLTISW ( vrt sim -- ) 0 908 4 vx-insn ;

! 6.8.4 Vector Permute Instruction
: VPERM ( vrt vra vrb vrc -- ) 43 4 va-insn ;

! 6.8.5 Vector Select Instruction
: VSEL ( vrt vra vrb vrc -- ) 42 4 va-insn ;

! 6.8.6 Vector Shift Instructions
: VSL  ( vrt vra vrb -- )  452 4 vx-insn ;
: VSR  ( vrt vra vrb -- )  708 4 vx-insn ;
: VSLO ( vrt vra vrb -- ) 1036 4 vx-insn ;
: VSRO ( vrt vra vrb -- ) 1100 4 vx-insn ;
: VSLDOI ( vrt vra vrb shb -- ) 44 4 va-insn ;

! 6.9.1.1 Vector Integer Add Instructions
: VADDCUW ( vrt vra vrb -- ) 384 4 vx-insn ;
: VADDSHS ( vrt vra vrb -- ) 832 4 vx-insn ;
: VADDSBS ( vrt vra vrb -- ) 768 4 vx-insn ;
: VADDSWS ( vrt vra vrb -- ) 896 4 vx-insn ;
: VADDUBM ( vrt vra vrb -- )   0 4 vx-insn ;
: VADDUHM ( vrt vra vrb -- )  64 4 vx-insn ;
: VADDUWM ( vrt vra vrb -- ) 128 4 vx-insn ;
: VADDUBS ( vrt vra vrb -- ) 512 4 vx-insn ;
: VADDUHS ( vrt vra vrb -- ) 576 4 vx-insn ;
: VADDUWS ( vrt vra vrb -- ) 640 4 vx-insn ;

! 6.9.1.2 Vector Integer Subtract Instructions
: VSUBCUW ( vrt vra vrb -- ) 1408 4 vx-insn ;
: VSUBSBS ( vrt vra vrb -- ) 1792 4 vx-insn ;
: VSUBSHS ( vrt vra vrb -- ) 1856 4 vx-insn ;
: VSUBSWS ( vrt vra vrb -- ) 1920 4 vx-insn ;
: VSUBUBM ( vrt vra vrb -- ) 1024 4 vx-insn ;
: VSUBUHM ( vrt vra vrb -- ) 1088 4 vx-insn ;
: VSUBUWM ( vrt vra vrb -- ) 1152 4 vx-insn ;
: VSUBUBS ( vrt vra vrb -- ) 1536 4 vx-insn ;
: VSUBUHS ( vrt vra vrb -- ) 1600 4 vx-insn ;
: VSUBUWS ( vrt vra vrb -- ) 1664 4 vx-insn ;

! 6.9.1.3 Vector Integer Multiply Instructions
: VMULESB ( vrt vra vrb -- ) 776 4 vx-insn ;
: VMULESH ( vrt vra vrb -- ) 840 4 vx-insn ;
: VMULEUB ( vrt vra vrb -- ) 520 4 vx-insn ;
: VMULEUH ( vrt vra vrb -- ) 584 4 vx-insn ;
: VMULOSB ( vrt vra vrb -- ) 264 4 vx-insn ;
: VMULOSH ( vrt vra vrb -- ) 328 4 vx-insn ;
: VMULOUB ( vrt vra vrb -- )   8 4 vx-insn ;
: VMULOUH ( vrt vra vrb -- )  72 4 vx-insn ;

! 6.9.1.4 Vector Integer Multiply-Add/Sum Instructions
: VMHADDSHS  ( vrt vra vrb vrc -- ) 32 4 va-insn ;
: VMHRADDSHS ( vrt vra vrb vrc -- ) 33 4 va-insn ;
: VMLADDUHM  ( vrt vra vrb vrc -- ) 34 4 va-insn ;
: VMSUMUBM   ( vrt vra vrb vrc -- ) 36 4 va-insn ;
: VMSUMMBM   ( vrt vra vrb vrc -- ) 37 4 va-insn ;
: VMSUMSHM   ( vrt vra vrb vrc -- ) 40 4 va-insn ;
: VMSUMSHS   ( vrt vra vrb vrc -- ) 41 4 va-insn ;
: VMSUMUHM   ( vrt vra vrb vrc -- ) 38 4 va-insn ;
: VMSUMUHS   ( vrt vra vrb vrc -- ) 39 4 va-insn ;

! 6.9.1.5 Vector Integer Sum-Across Intructions
: VSUMSWS  ( vrt vra vrb -- ) 1928 4 vx-insn ;
: VSUM2SWS ( vrt vra vrb -- ) 1672 4 vx-insn ;
: VSUM4SBS ( vrt vra vrb -- ) 1800 4 vx-insn ;
: VSUM4UBS ( vrt vra vrb -- ) 1544 4 vx-insn ;
: VSUM4SHS ( vrt vra vrb -- ) 1608 4 vx-insn ;

! 6.9.1.6 Vector Integer Average Instructions
: VAVGSB ( vrt vra vrb -- ) 1282 4 vx-insn ;
: VAVGSH ( vrt vra vrb -- ) 1346 4 vx-insn ;
: VAVGSW ( vrt vra vrb -- ) 1410 4 vx-insn ;
: VAVGUB ( vrt vra vrb -- ) 1026 4 vx-insn ;
: VAVGUH ( vrt vra vrb -- ) 1090 4 vx-insn ;
: VAVGUW ( vrt vra vrb -- ) 1154 4 vx-insn ;

! 6.9.1.7 Vector Integer Maximum and Minimum Instructions
: VMAXSB ( vrt vra vrb -- ) 258 4 vx-insn ;
: VMAXSH ( vrt vra vrb -- ) 322 4 vx-insn ;
: VMAXSW ( vrt vra vrb -- ) 386 4 vx-insn ;
: VMAXUB ( vrt vra vrb -- )   2 4 vx-insn ;
: VMAXUH ( vrt vra vrb -- )  66 4 vx-insn ;
: VMAXUW ( vrt vra vrb -- ) 130 4 vx-insn ;
: VMINSB ( vrt vra vrb -- ) 770 4 vx-insn ;
: VMINSH ( vrt vra vrb -- ) 834 4 vx-insn ;
: VMINSW ( vrt vra vrb -- ) 898 4 vx-insn ;
: VMINUB ( vrt vra vrb -- ) 514 4 vx-insn ;
: VMINUH ( vrt vra vrb -- ) 578 4 vx-insn ;
: VMINUW ( vrt vra vrb -- ) 642 4 vx-insn ;

! 6.9.2 Vector Integer Compare Instructions
: VCMPEQUB  ( vrt vra vrb -- ) 0    6 4 vc-insn ;
: VCMPEQUB. ( vrt vra vrb -- ) 1    6 4 vc-insn ;
: VCMPEQUH  ( vrt vra vrb -- ) 0   70 4 vc-insn ;
: VCMPEQUH. ( vrt vra vrb -- ) 1   70 4 vc-insn ;
: VCMPEQUW  ( vrt vra vrb -- ) 0  134 4 vc-insn ;
: VCMPEQUW. ( vrt vra vrb -- ) 1  134 4 vc-insn ;
: VCMPGTSB  ( vrt vra vrb -- ) 0  774 4 vc-insn ;
: VCMPGTSB. ( vrt vra vrb -- ) 1  774 4 vc-insn ;
: VCMPGTSH  ( vrt vra vrb -- ) 0  838 4 vc-insn ;
: VCMPGTSH. ( vrt vra vrb -- ) 1  838 4 vc-insn ;
: VCMPGTSW  ( vrt vra vrb -- ) 0  902 4 vc-insn ;
: VCMPGTSW. ( vrt vra vrb -- ) 1  902 4 vc-insn ;
: VCMPGTUB  ( vrt vra vrb -- ) 0  518 4 vc-insn ;
: VCMPGTUB. ( vrt vra vrb -- ) 1  518 4 vc-insn ;
: VCMPGTUH  ( vrt vra vrb -- ) 0  582 4 vc-insn ;
: VCMPGTUH. ( vrt vra vrb -- ) 1  582 4 vc-insn ;
: VCMPGTUW  ( vrt vra vrb -- ) 0  646 4 vc-insn ;
: VCMPGTUW. ( vrt vra vrb -- ) 1  646 4 vc-insn ;

! 6.9.3 Vector Logical Instructions
: VAND  ( vrt vra vrb -- ) 1028 4 vx-insn ;
: VANDC ( vrt vra vrb -- ) 1092 4 vx-insn ;
: VNOR  ( vrt vra vrb -- ) 1284 4 vx-insn ;
: VOR   ( vrt vra vrb -- ) 1156 4 vx-insn ;
: VXOR  ( vrt vra vrb -- ) 1220 4 vx-insn ;

! 6.9.4 Vector Integer Rotate and Shift Instructions
: VRLB  ( vrt vra vrb -- )   4 4 vx-insn ;
: VRLH  ( vrt vra vrb -- )  68 4 vx-insn ;
: VRLW  ( vrt vra vrb -- ) 132 4 vx-insn ;
: VSLB  ( vrt vra vrb -- ) 260 4 vx-insn ;
: VSLH  ( vrt vra vrb -- ) 324 4 vx-insn ;
: VSLW  ( vrt vra vrb -- ) 388 4 vx-insn ;
: VSRB  ( vrt vra vrb -- ) 516 4 vx-insn ;
: VSRH  ( vrt vra vrb -- ) 580 4 vx-insn ;
: VSRW  ( vrt vra vrb -- ) 644 4 vx-insn ;
: VSRAB ( vrt vra vrb -- ) 772 4 vx-insn ;
: VSRAH ( vrt vra vrb -- ) 836 4 vx-insn ;
: VSRAW ( vrt vra vrb -- ) 900 4 vx-insn ;

! 6.10.1 Vector Floating-Point Arithmetic Instructions
: VADDFP   ( vrt vra vrb -- ) 10 4 vx-insn ;
: VSUBFP   ( vrt vra vrb -- ) 74 4 vx-insn ;
: VMADDFP  ( vrt vra vrb -- ) 46 4 vx-insn ;
: VNMSUBFP ( vrt vra vrb -- ) 47 4 vx-insn ;

! 6.10.2 Vector Floating-Point Maximum and Minimum Instructions
: VMAXFP ( vrt vra vrb -- ) 1034 4 vx-insn ;
: VMINFP ( vrt vra vrb -- ) 1098 4 vx-insn ;

! 6.10.3 Vector Floating-Point Rounding and Conversion Instructions
: VCTSXS ( vrt vrb uim -- ) swap 970 4 vx-insn ;
: VCTUXS ( vrt vrb uim -- ) swap 906 4 vx-insn ;
: VCFSX  ( vrt vrb uim -- ) swap 842 4 vx-insn ;
: VCFUX  ( vrt vrb uim -- ) swap 778 4 vx-insn ;
: VRFIM  ( vrt vrb -- ) 0 swap 714 4 vx-insn ;
: VRFIN  ( vrt vrb -- ) 0 swap 522 4 vx-insn ;
: VRFIP  ( vrt vrb -- ) 0 swap 650 4 vx-insn ;
: VRFIX  ( vrt vrb -- ) 0 swap 586 4 vx-insn ;

! 6.10.4 Vector Floating-Point Compare Instructions
: VCMPBFP   ( vrt vra vrb -- ) 0 966 4 vc-insn ;
: VCMPBFP.  ( vrt vra vrb -- ) 1 966 4 vc-insn ;
: VCMPEQFP  ( vrt vra vrb -- ) 0 198 4 vc-insn ;
: VCMPEQFP. ( vrt vra vrb -- ) 1 198 4 vc-insn ;
: VCMPGEFP  ( vrt vra vrb -- ) 0 454 4 vc-insn ;
: VCMPGEFP. ( vrt vra vrb -- ) 1 454 4 vc-insn ;
: VCMPGTFP  ( vrt vra vrb -- ) 0 710 4 vc-insn ;
: VCMPGTFP. ( vrt vra vrb -- ) 1 710 4 vc-insn ;

! 6.10.5 Vector Floating-Point Estimate Instructions
: VEXPTEFP  ( vrt vrb -- ) 0 swap 394 4 vx-insn ;
: VLOGEFP   ( vrt vrb -- ) 0 swap 458 4 vx-insn ;
: VREFP     ( vrt vrb -- ) 0 swap 266 4 vx-insn ;
: VRSQRTEFP ( vrt vrb -- ) 0 swap 330 4 vx-insn ;

! 6.10.6 Vector Status and Control Register Instructions
: MTVSCR ( vrb -- ) [ 0 0 ] dip 1604 4 vx-insn ;
: MFVSCR ( vrt -- ) 0 0 1540 4 vx-insn ;

! 7.7 VSX Instruction Descriptions
: LXSDX       ( xt ra rb -- ) 588 31 xx1-insn ;
: LXVD2X      ( xt ra rb -- ) 844 31 xx1-insn ;
: LXVDSX      ( xt ra rb -- ) 332 31 xx1-insn ;
: LXVW4X      ( xt ra rb -- ) 780 31 xx1-insn ;
: STXSDX      ( xs ra rb -- ) 716 31 xx1-insn ;
: STXVD2X     ( xs ra rb -- ) 972 31 xx1-insn ;
: STXVW4X     ( xs ra rb -- ) 908 31 xx1-insn ;
: XSABSDP     ( xt xb -- )    0 swap 345 60 xx2-insn ;
: XSADDDP     ( xt xa xb -- )  32 60 xx3-insn ;
: XSCMPODP    ( bf xa xb -- ) [ 2 shift ] 2dip  43 60 xx3-insn ;
: XSCMPUDP    ( bf xa xb -- ) [ 2 shift ] 2dip  35 60 xx3-insn ;
: XSCPSGNDP   ( xt xa xb -- ) 176 60 xx3-insn ;
: XSCVDPSP    ( xt xb -- )    0 swap 265 60 xx2-insn ;
: XSCVDPSXDS  ( xt xb -- )    0 swap 344 60 xx2-insn ;
: XSCVDPSXWS  ( xt xb -- )    0 swap  88 60 xx2-insn ;
: XSCVDPUXDS  ( xt xb -- )    0 swap 328 60 xx2-insn ;
: XSCVDPUXWS  ( xt xb -- )    0 swap  72 60 xx2-insn ;
: XSCVSPDP    ( xt xb -- )    0 swap 329 60 xx2-insn ;
: XSCVSXDDP   ( xt xb -- )    0 swap 376 60 xx2-insn ;
: XSCUXDDP    ( xt xb -- )    0 swap 360 60 xx2-insn ;
: XSDIVDP     ( xt xa xb -- )  56 60 xx3-insn ;
: XSMADDADP   ( xt xa xb -- )  33 60 xx3-insn ;
: XSMADDMDP   ( xt xa xb -- )  41 60 xx3-insn ;
: XSMAXDP     ( xt xa xb -- ) 160 60 xx3-insn ;
: XSMINDP     ( xt xa xb -- ) 168 60 xx3-insn ;
: XSMSUBADP   ( xt xa xb -- )  49 60 xx3-insn ;
: XSMSUBMDP   ( xt xa xb -- )  57 60 xx3-insn ;
: XSMULDP     ( xt xa xb -- )  48 60 xx3-insn ;
: XSNABSDP    ( xt xb -- )    0 swap 361 60 xx2-insn ;
: XSNEGDP     ( xt xb -- )    0 swap 377 60 xx2-insn ;
: XSNMADDADP  ( xt xa xb -- ) 161 60 xx3-insn ;
: XSNMADDMDP  ( xt xa xb -- ) 169 60 xx3-insn ;
: XSNMSUBADP  ( xt xa xb -- ) 177 60 xx3-insn ;
: XSNMSUBMDP  ( xt xa xb -- ) 185 60 xx3-insn ;
: XSRDPI      ( xt xb -- )    0 swap  73 60 xx2-insn ;
: XSRDPIC     ( xt xb -- )    0 swap 107 60 xx2-insn ;
: XSRDPIM     ( xt xb -- )    0 swap 121 60 xx2-insn ;
: XSRDPIP     ( xt xb -- )    0 swap 105 60 xx2-insn ;
: XSRDPIZ     ( xt xb -- )    0 swap  89 60 xx2-insn ;
: XSREDP      ( xt xb -- )    0 swap  90 60 xx2-insn ;
: XSRSQRTEDP  ( xt xb -- )    0 swap  74 60 xx2-insn ;
: XSSQRTDP    ( xt xb -- )    0 swap  75 60 xx2-insn ;
: XSSUBDP     ( xt xa xb -- )  40 60 xx3-insn ;
: XSTDIVDP    ( bf xa xb -- ) [ 2 shift ] 2dip  61 60 xx3-insn ;
: XSTSQRTDP   ( bf xb -- )    [ 2 shift ] dip 0 swap 106 60 xx2-insn ;
: XVABSDP     ( xt xb -- )    0 swap 473 60 xx2-insn ;
: XVABSSP     ( xt xb -- )    0 swap 409 60 xx2-insn ;
: XVADDDP     ( xt xa xb -- )  96 60 xx3-insn ;
: XVADDSP     ( xt xa xb -- )  64 60 xx3-insn ;
: XVCMPEQDP   ( xt xa xb -- ) 0  99 60 xx3-rc-insn ;
: XVCMPEQDP.  ( xt xa xb -- ) 1  99 60 xx3-rc-insn ;
: XVCMPEQSP   ( xt xa xb -- ) 0  67 60 xx3-rc-insn ;
: XVCMPEQSP.  ( xt xa xb -- ) 1  67 60 xx3-rc-insn ;
: XVCMPGEDP   ( xt xa xb -- ) 0 115 60 xx3-rc-insn ;
: XVCMPGEDP.  ( xt xa xb -- ) 1 115 60 xx3-rc-insn ;
: XVCMPGESP   ( xt xa xb -- ) 0  83 60 xx3-rc-insn ;
: XVCMPGESP.  ( xt xa xb -- ) 1  83 60 xx3-rc-insn ;
: XVCMPGTDP   ( xt xa xb -- ) 0 107 60 xx3-rc-insn ;
: XVCMPGTDP.  ( xt xa xb -- ) 1 107 60 xx3-rc-insn ;
: XVCMPGTSP   ( xt xa xb -- ) 0  75 60 xx3-rc-insn ;
: XVCMPGTSP.  ( xt xa xb -- ) 1  75 60 xx3-rc-insn ;
: XVCPSGNDP   ( xt xa xb -- ) 240 60 xx3-insn ;
: XVCPSGNSP   ( xt xa xb -- ) 208 60 xx3-insn ;
: XVCVDPSP    ( xt xb -- )    0 swap 393 60 xx2-insn ;
: XVCVDPSXDS  ( xt xb -- )    0 swap 472 60 xx2-insn ;
: XVCVDPSXWS  ( xt xb -- )    0 swap 216 60 xx2-insn ;
: XVCVDPUXDS  ( xt xb -- )    0 swap 456 60 xx2-insn ;
: XVCVDPUXWS  ( xt xb -- )    0 swap 200 60 xx2-insn ;
: XVCVSPDP    ( xt xb -- )    0 swap 457 60 xx2-insn ;
: XVCVSPSXDS  ( xt xb -- )    0 swap 408 60 xx2-insn ;
: XVCVSPSXWS  ( xt xb -- )    0 swap 152 60 xx2-insn ;
: XVCVSPUXDS  ( xt xb -- )    0 swap 392 60 xx2-insn ;
: XVCVSPUXWS  ( xt xb -- )    0 swap 136 60 xx2-insn ;
: XVCVSXDDP   ( xt xb -- )    0 swap 504 60 xx2-insn ;
: XVCVSXDSP   ( xt xb -- )    0 swap 440 60 xx2-insn ;
: XVCVSXWDP   ( xt xb -- )    0 swap 248 60 xx2-insn ;
: XVCVSXWSP   ( xt xb -- )    0 swap 184 60 xx2-insn ;
: XVCVUXDDP   ( xt xb -- )    0 swap 488 60 xx2-insn ;
: XVCVUXDSP   ( xt xb -- )    0 swap 424 60 xx2-insn ;
: XVCVUXWDP   ( xt xb -- )    0 swap 232 60 xx2-insn ;
: XVCVUXWSP   ( xt xb -- )    0 swap 168 60 xx2-insn ;
: XVDIVDP     ( xt xa xb -- ) 120 60 xx3-insn ;
: XVDIVSP     ( xt xa xb -- )  88 60 xx3-insn ;
: XVMADDADP   ( xt xa xb -- )  97 60 xx3-insn ;
: XVMADDMDP   ( xt xa xb -- ) 105 60 xx3-insn ;
: XVMADDASP   ( xt xa xb -- )  65 60 xx3-insn ;
: XVMADDMSP   ( xt xa xb -- )  73 60 xx3-insn ;
: XVMAXDP     ( xt xa xb -- ) 224 60 xx3-insn ;
: XVMAXSP     ( xt xa xb -- ) 192 60 xx3-insn ;
: XVMINDP     ( xt xa xb -- ) 232 60 xx3-insn ;
: XVMINSP     ( xt xa xb -- ) 200 60 xx3-insn ;
: XVMSUBADP   ( xt xa xb -- ) 113 60 xx3-insn ;
: XVMSUBMDP   ( xt xa xb -- ) 121 60 xx3-insn ;
: XVMSUBASP   ( xt xa xb -- )  81 60 xx3-insn ;
: XVMSUBMSP   ( xt xa xb -- )  89 60 xx3-insn ;
: XVMULDP     ( xt xa xb -- ) 112 60 xx3-insn ;
: XVMULSP     ( xt xa xb -- )  80 60 xx3-insn ;
: XVNABSDP    ( xt xb -- )    0 swap 489 60 xx2-insn ;
: XVNABSSP    ( xt xb -- )    0 swap 425 60 xx2-insn ;
: XVNEGDP     ( xt xb -- )    0 swap 505 60 xx2-insn ;
: XVNEGSP     ( xt xb -- )    0 swap 441 60 xx2-insn ;
: XVNMADDADP  ( xt xa xb -- ) 225 60 xx3-insn ;
: XVNMADDMDP  ( xt xa xb -- ) 233 60 xx3-insn ;
: XVNMADDASP  ( xt xa xb -- ) 193 60 xx3-insn ;
: XVNMADDMSP  ( xt xa xb -- ) 201 60 xx3-insn ;
: XVNMSUBADP  ( xt xa xb -- ) 241 60 xx3-insn ;
: XVNMSUBMDP  ( xt xa xb -- ) 249 60 xx3-insn ;
: XVNMSUBASP  ( xt xa xb -- ) 209 60 xx3-insn ;
: XVNMSUBMSP  ( xt xa xb -- ) 217 60 xx3-insn ;
: XVRDPI      ( xt xb -- )    0 swap 201 60 xx2-insn ;
: XVRDPIC     ( xt xb -- )    0 swap 235 60 xx2-insn ;
: XVRDPIM     ( xt xb -- )    0 swap 249 60 xx2-insn ;
: XVRDPIP     ( xt xb -- )    0 swap 233 60 xx2-insn ;
: XVRDPIZ     ( xt xb -- )    0 swap 217 60 xx2-insn ;
: XVREDP      ( xt xb -- )    0 swap 218 60 xx2-insn ;
: XVRESP      ( xt xb -- )    0 swap 154 60 xx2-insn ;
: XVRSPI      ( xt xb -- )    0 swap 137 60 xx2-insn ;
: XVRSPIC     ( xt xb -- )    0 swap 171 60 xx2-insn ;
: XVRSPIM     ( xt xb -- )    0 swap 185 60 xx2-insn ;
: XVRSPIP     ( xt xb -- )    0 swap 169 60 xx2-insn ;
: XVRSPIZ     ( xt xb -- )    0 swap 153 60 xx2-insn ;
: XVRSQRTEDP  ( xt xb -- )    0 swap 202 60 xx2-insn ;
: XVRSQRTESP  ( xt xb -- )    0 swap 138 60 xx2-insn ;
: XVSQRTDP    ( xt xb -- )    0 swap 203 60 xx2-insn ;
: XVSQRTSP    ( xt xb -- )    0 swap 139 60 xx2-insn ;
: XVSUBDP     ( xt xb -- )    0 swap 104 60 xx2-insn ;
: XVSUBSP     ( xt xb -- )    0 swap  72 60 xx2-insn ;
: XVTDIVDP    ( bf xa xb -- ) [ 2 shift ] 2dip 125 60 xx3-insn ;
: XVTDIVSP    ( bf xa xb -- ) [ 2 shift ] 2dip  93 60 xx3-insn ;
: XVTSQRTDP   ( bf xa xb -- ) [ 2 shift ] 2dip 234 60 xx3-insn ;
: XVTSQRTSP   ( bf xa xb -- ) [ 2 shift ] 2dip 170 60 xx3-insn ;
: XXLAND      ( xt xa xb -- ) 130 60 xx3-insn ;
: XXLANDC     ( xt xa xb -- ) 138 60 xx3-insn ;
: XXLNOR      ( xt xa xb -- ) 162 60 xx3-insn ;
: XXLOR       ( xt xa xb -- ) 146 60 xx3-insn ;
: XXLXOR      ( xt xa xb -- ) 154 60 xx3-insn ;
: XXMRGHW     ( xt xa xb -- )  18 60 xx3-insn ;
: XXMRGLW     ( xt xa xb -- )  50 60 xx3-insn ;
: XXPERMDI    ( xt xa xb dm -- ) 0 swap 10 60 xx3-rc-dm-insn ;
: XXSEL       ( xt xa xb xc -- ) 3 60 xx4-insn ;
: XXSLDWI     ( xt xa xb sh -- ) 0 swap 2 60 xx3-rc-dm-insn ;
: XVSPLTW     ( xt xb uim -- ) swap 164 60 xx2-insn ;

! 8.3.9 SPE Instruction Set
: BRINC         ( rt ra rb -- )  527 4 evx-insn ;
: EVABS         ( rt ra -- ) 0 520 4 evx-insn ;
: EVADDIW       ( rt rb ui -- ) swap 514 4 evx-insn ;
: EVADDSMIAAW   ( rt ra -- ) 0 1225 4 evx-insn ;
: EVADDSSIAAW   ( rt ra -- ) 0 1217 4 evx-insn ;
: EVADDUMIAAW   ( rt ra -- ) 0 1224 4 evx-insn ;
: EVADDUSIAWW   ( rt ra -- ) 0 1216 4 evx-insn ;
: EVADDW        ( rt ra rb -- )  512 4 evx-insn ;
: EVAND         ( rt ra rb -- )  529 4 evx-insn ;
: EVANDC        ( rt ra rb -- )  530 4 evx-insn ;
: EVCMPEQ       ( bf ra rb -- ) [ 2 shift ] 2dip 564 4 evx-insn ;
: EVCMPGTS      ( bf ra rb -- ) [ 2 shift ] 2dip 561 4 evx-insn ;
: EVCMPGTU      ( bf ra rb -- ) [ 2 shift ] 2dip 560 4 evx-insn ;
: EVCMPLTS      ( bf ra rb -- ) [ 2 shift ] 2dip 563 4 evx-insn ;
: EVCMPLTU      ( bf ra rb -- ) [ 2 shift ] 2dip 562 4 evx-insn ;
: EVCNTLSW      ( rt ra -- ) 0 526 4 evx-insn ;
: EVCNTLZW      ( rt ra -- ) 0 525 4 evx-insn ;
: EVDIVWS       ( rt ra rb -- ) 1222 4 evx-insn ;
: EVDIVWU       ( rt ra rb -- ) 1223 4 evx-insn ;
: EVEQV         ( rt ra rb -- ) 537 4 evx-insn ;
: EVEXTSB       ( rt ra -- ) 0 522 4 evx-insn ;
: EVEXTSH       ( rt ra -- ) 0 523 4 evx-insn ;
: EVLDD         ( rt ra  d -- )  769 4 evx-insn ;
: EVLDDX        ( rt ra rb -- )  768 4 evx-insn ;
: EVLDH         ( rt ra  d -- )  773 4 evx-insn ;
: EVLDHX        ( rt ra rb -- )  772 4 evx-insn ;
: EVLDW         ( rt ra  d -- )  771 4 evx-insn ;
: EVLDWX        ( rt ra rb -- )  770 4 evx-insn ;
: EVLHHESPLAT   ( rt ra  d -- )  777 4 evx-insn ;
: EVLHHESPLATX  ( rt ra rb -- )  776 4 evx-insn ;
: EVLHHOSSPLAT  ( rt ra  d -- )  783 4 evx-insn ;
: EVLHHOSSPLATX ( rt ra rb -- )  782 4 evx-insn ;
: EVLHHOUSPLAT  ( rt ra  d -- )  781 4 evx-insn ;
: EVLHHOUSPLATX ( rt ra rb -- )  780 4 evx-insn ;
: EVLWHE        ( rt ra  d -- )  785 4 evx-insn ;
: EVLWHEX       ( rt ra rb -- )  784 4 evx-insn ;
: EVLWHOS       ( rt ra  d -- )  791 4 evx-insn ;
: EVLWHOSX      ( rt ra rb -- )  790 4 evx-insn ;
: EVLWHOU       ( rt ra  d -- )  789 4 evx-insn ;
: EVLWHOUX      ( rt ra rb -- )  788 4 evx-insn ;
: EVLWHSPLAT    ( rt ra  d -- )  797 4 evx-insn ;
: EVLWHSPLATX   ( rt ra rb -- )  796 4 evx-insn ;
: EVLWWSPLAT    ( rt ra  d -- )  793 4 evx-insn ;
: EVLWWSPLATX   ( rt ra  d -- )  792 4 evx-insn ;
: EVMERGEHI     ( rt ra rb -- )  556 4 evx-insn ;
: EVMERGELO     ( rt ra rb -- )  557 4 evx-insn ;
: EVMERGEHILO   ( rt ra rb -- )  558 4 evx-insn ;
: EVMERGELOHI   ( rt ra rb -- )  559 4 evx-insn ;
: EVMHEGSMFAA   ( rt ra rb -- ) 1323 4 evx-insn ;
: EVMHEGSMFAN   ( rt ra rb -- ) 1451 4 evx-insn ;
: EVMHEGSMIAA   ( rt ra rb -- ) 1321 4 evx-insn ;
: EVMHEGSMIAN   ( rt ra rb -- ) 1449 4 evx-insn ;
: EVMHEGUMIAA   ( rt ra rb -- ) 1320 4 evx-insn ;
: EVMHEGUMIAN   ( rt ra rb -- ) 1448 4 evx-insn ;
: EVMHESMF      ( rt ra rb -- ) 1035 4 evx-insn ;
: EVMHESMFA     ( rt ra rb -- ) 1067 4 evx-insn ;
: EVMHESMFAAW   ( rt ra rb -- ) 1291 4 evx-insn ;
: EVMHESMFANW   ( rt ra rb -- ) 1419 4 evx-insn ;
: EVMHESMI      ( rt ra rb -- ) 1033 4 evx-insn ;
: EVMHESMIA     ( rt ra rb -- ) 1065 4 evx-insn ;
: EVMHESMIAAW   ( rt ra rb -- ) 1289 4 evx-insn ;
: EVMHESMIANW   ( rt ra rb -- ) 1417 4 evx-insn ;
: EVMHESSF      ( rt ra rb -- ) 1027 4 evx-insn ;
: EVMHESSFA     ( rt ra rb -- ) 1059 4 evx-insn ;
: EVMHESSFAAW   ( rt ra rb -- ) 1283 4 evx-insn ;
: EVMHESSFANW   ( rt ra rb -- ) 1411 4 evx-insn ;
: EVMHESSIAAW   ( rt ra rb -- ) 1281 4 evx-insn ;
: EVMHESSIANW   ( rt ra rb -- ) 1409 4 evx-insn ;
: EVMHEUMI      ( rt ra rb -- ) 1032 4 evx-insn ;
: EVMHEUMIA     ( rt ra rb -- ) 1064 4 evx-insn ;
: EVMHEUMIAAW   ( rt ra rb -- ) 1288 4 evx-insn ;
: EVMHEUMIANW   ( rt ra rb -- ) 1416 4 evx-insn ;
: EVMHEUSIAAW   ( rt ra rb -- ) 1280 4 evx-insn ;
: EVMHEUSIANW   ( rt ra rb -- ) 1408 4 evx-insn ;
: EVMHOGSMFAA   ( rt ra rb -- ) 1327 4 evx-insn ;
: EVMHOGSMFAN   ( rt ra rb -- ) 1455 4 evx-insn ;
: EVMHOGSMIAA   ( rt ra rb -- ) 1325 4 evx-insn ;
: EVMHOGSMIAN   ( rt ra rb -- ) 1453 4 evx-insn ;
: EVMHOGUMIAA   ( rt ra rb -- ) 1324 4 evx-insn ;
: EVMHOGUMIAN   ( rt ra rb -- ) 1452 4 evx-insn ;
: EVMHOSMF      ( rt ra rb -- ) 1039 4 evx-insn ;
: EVMHOSMFA     ( rt ra rb -- ) 1071 4 evx-insn ;
: EVMHOSMFAAW   ( rt ra rb -- ) 1295 4 evx-insn ;
: EVMHOSMFANW   ( rt ra rb -- ) 1423 4 evx-insn ;
: EVMHOSMI      ( rt ra rb -- ) 1037 4 evx-insn ;
: EVMHOSMIA     ( rt ra rb -- ) 1069 4 evx-insn ;
: EVMHOSMIAAW   ( rt ra rb -- ) 1293 4 evx-insn ;
: EVMHOSMIANW   ( rt ra rb -- ) 1421 4 evx-insn ;
: EVMHOSSF      ( rt ra rb -- ) 1031 4 evx-insn ;
: EVMHOSSFA     ( rt ra rb -- ) 1063 4 evx-insn ;
: EVMHOSSFAAW   ( rt ra rb -- ) 1287 4 evx-insn ;
: EVMHOSSFANW   ( rt ra rb -- ) 1415 4 evx-insn ;
: EVMHOSSIAAW   ( rt ra rb -- ) 1285 4 evx-insn ;
: EVMHOSSIANW   ( rt ra rb -- ) 1413 4 evx-insn ;
: EVMHOUMI      ( rt ra rb -- ) 1036 4 evx-insn ;
: EVMHOUMIA     ( rt ra rb -- ) 1068 4 evx-insn ;
: EVMHOUMIAAW   ( rt ra rb -- ) 1292 4 evx-insn ;
: EVMHOUMIANW   ( rt ra rb -- ) 1420 4 evx-insn ;
: EVMHOUSIAAW   ( rt ra rb -- ) 1284 4 evx-insn ;
: EVMHOUSIANW   ( rt ra rb -- ) 1412 4 evx-insn ;
: EVMRA         ( rt ra rb -- ) 1220 4 evx-insn ;
: EVMWHSMF      ( rt ra rb -- ) 1103 4 evx-insn ;
: EVMWHSMFA     ( rt ra rb -- ) 1135 4 evx-insn ;
: EVMWHSMI      ( rt ra rb -- ) 1101 4 evx-insn ;
: EVMWHSMIA     ( rt ra rb -- ) 1133 4 evx-insn ;
: EVMWHSSF      ( rt ra rb -- ) 1095 4 evx-insn ;
: EVMWHSSFA     ( rt ra rb -- ) 1127 4 evx-insn ;
: EVMWHUMI      ( rt ra rb -- ) 1100 4 evx-insn ;
: EVMWHUMIA     ( rt ra rb -- ) 1132 4 evx-insn ;
: EVMWLSMIAAW   ( rt ra rb -- ) 1353 4 evx-insn ;
: EVMWLSMIANW   ( rt ra rb -- ) 1481 4 evx-insn ;
: EVMWLSSIAAW   ( rt ra rb -- ) 1345 4 evx-insn ;
: EVMWLSSIANW   ( rt ra rb -- ) 1473 4 evx-insn ;
: EVMWLUMI      ( rt ra rb -- ) 1096 4 evx-insn ;
: EVMWLUMIA     ( rt ra rb -- ) 1128 4 evx-insn ;
: EVMWLUMIAAW   ( rt ra rb -- ) 1352 4 evx-insn ;
: EVMWLUMIANW   ( rt ra rb -- ) 1480 4 evx-insn ;
: EVMWLUSIAAW   ( rt ra rb -- ) 1344 4 evx-insn ;
: EVMWLUSIANW   ( rt ra rb -- ) 1472 4 evx-insn ;
: EVMWSMF       ( rt ra rb -- ) 1115 4 evx-insn ;
: EVMWSMFA      ( rt ra rb -- ) 1147 4 evx-insn ;
: EVMWSMFAA     ( rt ra rb -- ) 1371 4 evx-insn ;
: EVMWSMFAN     ( rt ra rb -- ) 1499 4 evx-insn ;
: EVMWSMI       ( rt ra rb -- ) 1113 4 evx-insn ;
: EVMWSMIA      ( rt ra rb -- ) 1145 4 evx-insn ;
: EVMWSMIAA     ( rt ra rb -- ) 1369 4 evx-insn ;
: EVMWSMIAN     ( rt ra rb -- ) 1497 4 evx-insn ;
: EVMWSSF       ( rt ra rb -- ) 1107 4 evx-insn ;
: EVMWSSFA      ( rt ra rb -- ) 1139 4 evx-insn ;
: EVMWSSFAA     ( rt ra rb -- ) 1363 4 evx-insn ;
: EVMWSSFAN     ( rt ra rb -- ) 1491 4 evx-insn ;
: EVMWUMI       ( rt ra rb -- ) 1112 4 evx-insn ;
: EVMWUMIA      ( rt ra rb -- ) 1144 4 evx-insn ;
: EVMWUMIAA     ( rt ra rb -- ) 1368 4 evx-insn ;
: EVMWUMIAN     ( rt ra rb -- ) 1496 4 evx-insn ;
: EVNAND        ( rt ra rb -- )  542 4 evx-insn ;
: EVNEG         ( rt ra rb -- )  521 4 evx-insn ;
: EVNOR         ( rt ra rb -- )  536 4 evx-insn ;
: EVOR          ( rt ra rb -- )  535 4 evx-insn ;
: EVORC         ( rt ra rb -- )  539 4 evx-insn ;
: EVRLW         ( rt ra rb -- )  552 4 evx-insn ;
: EVRLWI        ( rt ra rb -- )  554 4 evx-insn ;
: EVRNDW        ( rt ra rb -- )  524 4 evx-insn ;
: EVSEL         ( rt ra rb -- )   79 4 evx-insn ;
: EVSLW         ( rt ra rb -- )  548 4 evx-insn ;
: EVSLWI        ( rt ra rb -- )  550 4 evx-insn ;
: EVSPLATFI     ( rt ra rb -- )  555 4 evx-insn ;
: EVSPLATI      ( rt ra rb -- )  553 4 evx-insn ;
: EVSRWIS       ( rt ra rb -- )  547 4 evx-insn ;
: EVSRWIU       ( rt ra rb -- )  546 4 evx-insn ;
: EVSRWS        ( rt ra rb -- )  545 4 evx-insn ;
: EVSRWU        ( rt ra rb -- )  544 4 evx-insn ;
: EVSTDD        ( rt ra  d -- )  801 4 evx-insn ;
: EVSTDDX       ( rt ra rb -- )  800 4 evx-insn ;
: EVSTDH        ( rt ra  d -- )  805 4 evx-insn ;
: EVSTDHX       ( rt ra rb -- )  804 4 evx-insn ;
: EVSTDW        ( rt ra  d -- )  803 4 evx-insn ;
: EVSTDWX       ( rt ra rb -- )  802 4 evx-insn ;
: EVSTWHE       ( rt ra  d -- )  817 4 evx-insn ;
: EVSTWHEX      ( rt ra rb -- )  816 4 evx-insn ;
: EVSTWHO       ( rt ra  d -- )  821 4 evx-insn ;
: EVSTWHOX      ( rt ra rb -- )  820 4 evx-insn ;
: EVSTWWE       ( rt ra  d -- )  825 4 evx-insn ;
: EVSTWWEX      ( rt ra rb -- )  824 4 evx-insn ;
: EVSTWWO       ( rt ra  d -- )  829 4 evx-insn ;
: EVSTWWOX      ( rt ra rb -- )  828 4 evx-insn ;
: EVSUBFSMIAAW  ( rt ra -- ) 0 1227 4 evx-insn ;
: EVSUBFSSIAAW  ( rt ra -- ) 0 1219 4 evx-insn ;
: EVSUBFUMIAAW  ( rt ra -- ) 0 1226 4 evx-insn ;
: EVSUBFUSIAAW  ( rt ra -- ) 0 1218 4 evx-insn ;
: EVSUBFW       ( rt ra rb -- )  516 4 evx-insn ;
: EVSUBIFW      ( rt ui rb -- )  518 4 evx-insn ;
: EVXOR         ( rt ra rb -- )  534 4 evx-insn ;

! 9.3.2 SPE Embedded Float Vector Insturctions
: EVFSABS   ( rt ra -- ) 0 644 4 evx-insn ;
: EVFSNABS  ( rt ra -- ) 0 645 4 evx-insn ;
: EVFSNEG   ( rt ra -- ) 0 646 4 evx-insn ;
: EVFSADD   ( rt ra rb -- ) 640 4 evx-insn ;
: EVFSSUB   ( rt ra rb -- ) 641 4 evx-insn ;
: EVFSMUL   ( rt ra rb -- ) 648 4 evx-insn ;
: EVFSDIV   ( rt ra rb -- ) 649 4 evx-insn ;
: EVFSCMPGT ( bf ra rb -- ) [ 2 shift ] 2dip 652 4 evx-insn ;
: EVFSCMPLT ( bf ra rb -- ) [ 2 shift ] 2dip 653 4 evx-insn ;
: EVFSCMPEQ ( bf ra rb -- ) [ 2 shift ] 2dip 654 4 evx-insn ;
: EVFSTSTGT ( bf ra rb -- ) [ 2 shift ] 2dip 668 4 evx-insn ;
: EVFSTSTLT ( bf ra rb -- ) [ 2 shift ] 2dip 669 4 evx-insn ;
: EVFSTSTEQ ( bf ra rb -- ) [ 2 shift ] 2dip 670 4 evx-insn ;
: EVFSCFSI  ( rt rb -- ) 0 swap 657 4 evx-insn ;
: EVFSCFUI  ( rt rb -- ) 0 swap 656 4 evx-insn ;
: EVFSCFSF  ( rt rb -- ) 0 swap 659 4 evx-insn ;
: EVFSCFUF  ( rt rb -- ) 0 swap 658 4 evx-insn ;
: EVFSCTSI  ( rt rb -- ) 0 swap 661 4 evx-insn ;
: EVFSCTSIZ ( rt rb -- ) 0 swap 666 4 evx-insn ;
: EVFSCTUI  ( rt rb -- ) 0 swap 660 4 evx-insn ;
: EVFSCTUIZ ( rt rb -- ) 0 swap 664 4 evx-insn ;
: EVFSCTSF  ( rt rb -- ) 0 swap 663 4 evx-insn ;
: EVFSCTUF  ( rt rb -- ) 0 swap 662 4 evx-insn ;

! 9.3.3 SPE Embedded Float Scalar Single Instructions
: EFSABS   ( rt ra -- ) 0 708 4 evx-insn ;
: EFSNABS  ( rt ra -- ) 0 709 4 evx-insn ;
: EFSNEG   ( rt ra -- ) 0 710 4 evx-insn ;
: EFSADD   ( rt ra rb -- ) 704 4 evx-insn ;
: EFSSUB   ( rt ra rb -- ) 705 4 evx-insn ;
: EFSMUL   ( rt ra rb -- ) 712 4 evx-insn ;
: EFSDIV   ( rt ra rb -- ) 713 4 evx-insn ;
: EFSCMPGT ( bf ra rb -- ) [ 2 shift ] 2dip 716 4 evx-insn ;
: EFSCMPLT ( bf ra rb -- ) [ 2 shift ] 2dip 717 4 evx-insn ;
: EFSCMPEQ ( bf ra rb -- ) [ 2 shift ] 2dip 718 4 evx-insn ;
: EFSTSTGT ( bf ra rb -- ) [ 2 shift ] 2dip 732 4 evx-insn ;
: EFSTSTLT ( bf ra rb -- ) [ 2 shift ] 2dip 733 4 evx-insn ;
: EFSTSTEQ ( bf ra rb -- ) [ 2 shift ] 2dip 734 4 evx-insn ;
: EFSCFSI  ( rt rb -- ) 0 swap 721 4 evx-insn ;
: EFSCFUI  ( rt rb -- ) 0 swap 720 4 evx-insn ;
: EFSCFSF  ( rt rb -- ) 0 swap 723 4 evx-insn ;
: EFSCFUF  ( rt rb -- ) 0 swap 722 4 evx-insn ;
: EFSCTSI  ( rt rb -- ) 0 swap 725 4 evx-insn ;
: EFSCTUI  ( rt rb -- ) 0 swap 724 4 evx-insn ;
: EFSCTSIZ ( rt rb -- ) 0 swap 730 4 evx-insn ;
: EFSCTUIZ ( rt rb -- ) 0 swap 728 4 evx-insn ;
: EFSCTSF  ( rt rb -- ) 0 swap 727 4 evx-insn ;
: EFSCTUF  ( rt rb -- ) 0 swap 726 4 evx-insn ;

! 9.3.4 SPE Embedded Float Scalar Double Instructions
: EFDABS    ( rt ra -- ) 0 740 4 evx-insn ;
: EFDNABS   ( rt ra -- ) 0 741 4 evx-insn ;
: EFDNEG    ( rt ra -- ) 0 742 4 evx-insn ;
: EFDADD    ( rt ra rb -- ) 736 4 evx-insn ;
: EFDSUB    ( rt ra rb -- ) 737 4 evx-insn ;
: EFDMUL    ( rt ra rb -- ) 744 4 evx-insn ;
: EFDDIV    ( rt ra rb -- ) 745 4 evx-insn ;
: EFDCMPGT  ( bf ra rb -- ) [ 2 shift ] 2dip 748 4 evx-insn ;
: EFDCMPLT  ( bf ra rb -- ) [ 2 shift ] 2dip 749 4 evx-insn ;
: EFDCMPEQ  ( bf ra rb -- ) [ 2 shift ] 2dip 750 4 evx-insn ;
: EFDTSTGT  ( bf ra rb -- ) [ 2 shift ] 2dip 764 4 evx-insn ;
: EFDTSTLT  ( bf ra rb -- ) [ 2 shift ] 2dip 765 4 evx-insn ;
: EFDTSTEQ  ( bf ra rb -- ) [ 2 shift ] 2dip 766 4 evx-insn ;
: EFDCFSI   ( rt rb -- ) 0 swap 753 4 evx-insn ;
: EFDCFUI   ( rt rb -- ) 0 swap 752 4 evx-insn ;
: EFDCFSID  ( rt rb -- ) 0 swap 739 4 evx-insn ;
: EFDCFUID  ( rt rb -- ) 0 swap 738 4 evx-insn ;
: EFDCFSF   ( rt rb -- ) 0 swap 755 4 evx-insn ;
: EFDCTSI   ( rt rb -- ) 0 swap 757 4 evx-insn ;
: EFDCFUF   ( rt rb -- ) 0 swap 754 4 evx-insn ;
: EFDCTUI   ( rt rb -- ) 0 swap 756 4 evx-insn ;
: EFDCTSIDZ ( rt rb -- ) 0 swap 747 4 evx-insn ;
: EFDCTUIDZ ( rt rb -- ) 0 swap 746 4 evx-insn ;
: EFDCTSIZ  ( rt rb -- ) 0 swap 762 4 evx-insn ;
: EFDCTUIZ  ( rt rb -- ) 0 swap 760 4 evx-insn ;
: EFDCTSF   ( rt rb -- ) 0 swap 759 4 evx-insn ;
: EFDCTUF   ( rt rb -- ) 0 swap 758 4 evx-insn ;
: EFDCFS    ( rt rb -- ) 0 swap 751 4 evx-insn ;
: EFSCFD    ( rt rb -- ) 0 swap 719 4 evx-insn ;

! 10.0 Legacy Move Assist Instruction
: DLMZB  ( ra rs rb -- ) swapd 0 78 31 x-insn ; deprecated
: DLMZB. ( ra rs rb -- ) swapd 1 78 31 x-insn ; deprecated

! 11.0 Legacy Integer Multiply-Accumulate Instructions
: MACCHW     ( rt ra rb -- ) 0 172 0 4 xo-insn ; deprecated
: MACCHW.    ( rt ra rb -- ) 0 172 1 4 xo-insn ; deprecated
: MACCHWO    ( rt ra rb -- ) 1 172 0 4 xo-insn ; deprecated
: MACCHWO.   ( rt ra rb -- ) 1 172 1 4 xo-insn ; deprecated
: MACCHWS    ( rt ra rb -- ) 0 236 0 4 xo-insn ; deprecated
: MACCHWS.   ( rt ra rb -- ) 0 236 1 4 xo-insn ; deprecated
: MACCHWSO   ( rt ra rb -- ) 1 236 0 4 xo-insn ; deprecated
: MACCHWSO.  ( rt ra rb -- ) 1 236 1 4 xo-insn ; deprecated
: MACCHWU    ( rt ra rb -- ) 0 140 0 4 xo-insn ; deprecated
: MACCHWU.   ( rt ra rb -- ) 0 140 1 4 xo-insn ; deprecated
: MACCHWUO   ( rt ra rb -- ) 1 140 0 4 xo-insn ; deprecated
: MACCHWUO.  ( rt ra rb -- ) 1 140 1 4 xo-insn ; deprecated
: MACCHWSU   ( rt ra rb -- ) 0 204 0 4 xo-insn ; deprecated
: MACCHWSU.  ( rt ra rb -- ) 0 204 1 4 xo-insn ; deprecated
: MACCHWSUO  ( rt ra rb -- ) 1 204 0 4 xo-insn ; deprecated
: MACCHWSUO. ( rt ra rb -- ) 1 204 1 4 xo-insn ; deprecated
: MACHHW     ( rt ra rb -- ) 0  44 0 4 xo-insn ; deprecated
: MACHHW.    ( rt ra rb -- ) 0  44 1 4 xo-insn ; deprecated
: MACHHWO    ( rt ra rb -- ) 1  44 0 4 xo-insn ; deprecated
: MACHHWO.   ( rt ra rb -- ) 1  44 1 4 xo-insn ; deprecated
: MACHHWS    ( rt ra rb -- ) 0 108 0 4 xo-insn ; deprecated
: MACHHWS.   ( rt ra rb -- ) 0 108 1 4 xo-insn ; deprecated
: MACHHWSO   ( rt ra rb -- ) 1 108 0 4 xo-insn ; deprecated
: MACHHWSO.  ( rt ra rb -- ) 1 108 1 4 xo-insn ; deprecated
: MACHHWU    ( rt ra rb -- ) 0  12 0 4 xo-insn ; deprecated
: MACHHWU.   ( rt ra rb -- ) 0  12 1 4 xo-insn ; deprecated
: MACHHWUO   ( rt ra rb -- ) 1  12 0 4 xo-insn ; deprecated
: MACHHWUO.  ( rt ra rb -- ) 1  12 1 4 xo-insn ; deprecated
: MACHHWSU   ( rt ra rb -- ) 0  76 0 4 xo-insn ; deprecated
: MACHHWSU.  ( rt ra rb -- ) 0  76 1 4 xo-insn ; deprecated
: MACHHWSUO  ( rt ra rb -- ) 1  76 0 4 xo-insn ; deprecated
: MACHHWSUO. ( rt ra rb -- ) 1  76 1 4 xo-insn ; deprecated
: MACLHW     ( rt ra rb -- ) 0 428 0 4 xo-insn ; deprecated
: MACLHW.    ( rt ra rb -- ) 0 428 1 4 xo-insn ; deprecated
: MACLHWO    ( rt ra rb -- ) 1 428 0 4 xo-insn ; deprecated
: MACLHWO.   ( rt ra rb -- ) 1 428 1 4 xo-insn ; deprecated
: MACLHWS    ( rt ra rb -- ) 0 492 0 4 xo-insn ; deprecated
: MACLHWS.   ( rt ra rb -- ) 0 492 1 4 xo-insn ; deprecated
: MACLHWSO   ( rt ra rb -- ) 1 492 0 4 xo-insn ; deprecated
: MACLHWSO.  ( rt ra rb -- ) 1 492 1 4 xo-insn ; deprecated
: MACLHWU    ( rt ra rb -- ) 0 396 0 4 xo-insn ; deprecated
: MACLHWU.   ( rt ra rb -- ) 0 396 1 4 xo-insn ; deprecated
: MACLHWUO   ( rt ra rb -- ) 1 396 0 4 xo-insn ; deprecated
: MACLHWUO.  ( rt ra rb -- ) 1 396 1 4 xo-insn ; deprecated
: MACLHWSU   ( rt ra rb -- ) 0 460 0 4 xo-insn ; deprecated
: MACLHWSU.  ( rt ra rb -- ) 0 460 1 4 xo-insn ; deprecated
: MACLHWSUO  ( rt ra rb -- ) 1 460 0 4 xo-insn ; deprecated
: MACLHWSUO. ( rt ra rb -- ) 1 460 1 4 xo-insn ; deprecated
: MULCHW     ( rt ra rb -- ) 168 0 4 x-insn ; deprecated
: MULCHW.    ( rt ra rb -- ) 168 1 4 x-insn ; deprecated
: MULCHWU    ( rt ra rb -- ) 136 0 4 x-insn ; deprecated
: MULCHWU.   ( rt ra rb -- ) 136 1 4 x-insn ; deprecated
: MULHHW     ( rt ra rb -- )  40 0 4 x-insn ; deprecated
: MULHHW.    ( rt ra rb -- )  40 1 4 x-insn ; deprecated
: MULHHWU    ( rt ra rb -- )   8 0 4 x-insn ; deprecated
: MULHHWU.   ( rt ra rb -- )   8 1 4 x-insn ; deprecated
: MULLHW     ( rt ra rb -- ) 424 0 4 x-insn ; deprecated
: MULLHW.    ( rt ra rb -- ) 424 1 4 x-insn ; deprecated
: MULLHWU    ( rt ra rb -- ) 392 0 4 x-insn ; deprecated
: MULLHWU.   ( rt ra rb -- ) 392 1 4 x-insn ; deprecated
: NMACCHW    ( rt ra rb -- ) 0 174 0 4 xo-insn ; deprecated
: NMACCHW.   ( rt ra rb -- ) 0 174 1 4 xo-insn ; deprecated
: NMACCHWO   ( rt ra rb -- ) 1 174 0 4 xo-insn ; deprecated
: NMACCHWO.  ( rt ra rb -- ) 1 174 1 4 xo-insn ; deprecated
: NMACCHWS   ( rt ra rb -- ) 0 238 0 4 xo-insn ; deprecated
: NMACCHWS.  ( rt ra rb -- ) 0 238 1 4 xo-insn ; deprecated
: NMACCHWSO  ( rt ra rb -- ) 1 238 0 4 xo-insn ; deprecated
: NMACCHWSO. ( rt ra rb -- ) 1 238 1 4 xo-insn ; deprecated
: NMACHHW    ( rt ra rb -- ) 0  46 0 4 xo-insn ; deprecated
: NMACHHW.   ( rt ra rb -- ) 0  46 1 4 xo-insn ; deprecated
: NMACHHWO   ( rt ra rb -- ) 1  46 0 4 xo-insn ; deprecated
: NMACHHWO.  ( rt ra rb -- ) 1  46 1 4 xo-insn ; deprecated
: NMACHHWS   ( rt ra rb -- ) 0 110 0 4 xo-insn ; deprecated
: NMACHHWS.  ( rt ra rb -- ) 0 110 1 4 xo-insn ; deprecated
: NMACHHWSO  ( rt ra rb -- ) 1 110 0 4 xo-insn ; deprecated
: NMACHHWSO. ( rt ra rb -- ) 1 110 1 4 xo-insn ; deprecated
: NMACHLW    ( rt ra rb -- ) 0 430 0 4 xo-insn ; deprecated
: NMACHLW.   ( rt ra rb -- ) 0 430 1 4 xo-insn ; deprecated
: NMACHLWO   ( rt ra rb -- ) 1 430 0 4 xo-insn ; deprecated
: NMACHLWO.  ( rt ra rb -- ) 1 430 1 4 xo-insn ; deprecated
: NMACHLWS   ( rt ra rb -- ) 0 494 0 4 xo-insn ; deprecated
: NMACHLWS.  ( rt ra rb -- ) 0 494 1 4 xo-insn ; deprecated
: NMACHLWSO  ( rt ra rb -- ) 1 494 0 4 xo-insn ; deprecated
: NMACHLWSO. ( rt ra rb -- ) 1 494 1 4 xo-insn ; deprecated

! E.2.2 Simple Branch Mnemonics
: BLR      ( -- ) 0x14 0 0 BCLR ;
: BCTR     ( -- ) 0x14 0 0 BCCTR ;
: BLRL     ( -- ) 0x14 0 0 BCLRL ;
: BCTRL    ( -- ) 0x14 0 0 BCCTRL ;
: BT       ( bi target_addr -- ) [ 0xC ] 2dip BC ;
: BTA      ( bi target_addr -- ) [ 0xC ] 2dip BCA ;
: BTLR     ( bi target_addr -- ) [ 0xC ] 2dip BCLR ;
: BTCTR    ( bi target_addr -- ) [ 0xC ] 2dip BCCTR ;
: BTL      ( bi target_addr -- ) [ 0xC ] 2dip BCL ;
: BTLA     ( bi target_addr -- ) [ 0xC ] 2dip BCLA ;
: BTLRL    ( bi target_addr -- ) [ 0xC ] 2dip BCLRL ;
: BTCTRL   ( bi target_addr -- ) [ 0xC ] 2dip BCCTRL ;
: BF       ( bi target_addr -- ) [ 0x4 ] 2dip BC ;
: BFA      ( bi target_addr -- ) [ 0x4 ] 2dip BCA ;
: BFLR     ( bi target_addr -- ) [ 0x4 ] 2dip BCLR ;
: BFCTR    ( bi target_addr -- ) [ 0x4 ] 2dip BCCTR ;
: BFL      ( bi target_addr -- ) [ 0x4 ] 2dip BCL ;
: BFLA     ( bi target_addr -- ) [ 0x4 ] 2dip BCLA ;
: BFLRL    ( bi target_addr -- ) [ 0x4 ] 2dip BCLRL ;
: BFCTRL   ( bi target_addr -- ) [ 0x4 ] 2dip BCCTRL ;
: BDNZ     ( target_addr -- ) [ 0x10 0 ] dip BC ;
: BDNZA    ( target_addr -- ) [ 0x10 0 ] dip BCA ;
: BDNZLR   ( target_addr -- ) [ 0x10 0 ] dip BCLR ;
: BDNZL    ( target_addr -- ) [ 0x10 0 ] dip BCL ;
: BDNZLA   ( target_addr -- ) [ 0x10 0 ] dip BCLA ;
: BDNZLRL  ( target_addr -- ) [ 0x10 0 ] dip BCLRL ;
: BDNZT    ( bi target_addr -- ) [ 0x8 ] 2dip BC ;
: BDNZTA   ( bi target_addr -- ) [ 0x8 ] 2dip BCA ;
: BDNZTLR  ( bi target_addr -- ) [ 0x8 ] 2dip BCLR ;
: BDNZTL   ( bi target_addr -- ) [ 0x8 ] 2dip BCL ;
: BDNZTLA  ( bi target_addr -- ) [ 0x8 ] 2dip BCLA ;
: BDNZTLRL ( bi target_addr -- ) [ 0x8 ] 2dip BCLRL ;
: BDNZF    ( bi target_addr -- ) [ 0x0 ] 2dip BC ;
: BDNZFA   ( bi target_addr -- ) [ 0x0 ] 2dip BCA ;
: BDNZFLR  ( bi target_addr -- ) [ 0x0 ] 2dip BCLR ;
: BDNZFL   ( bi target_addr -- ) [ 0x0 ] 2dip BCL ;
: BDNZFLA  ( bi target_addr -- ) [ 0x0 ] 2dip BCLA ;
: BDNZFLRL ( bi target_addr -- ) [ 0x0 ] 2dip BCLRL ;
: BDZ      ( target_addr -- ) [ 0x12 0 ] dip BC ;
: BDZA     ( target_addr -- ) [ 0x12 0 ] dip BCA ;
: BDZLR    ( target_addr -- ) [ 0x12 0 ] dip BCLR ;
: BDZL     ( target_addr -- ) [ 0x12 0 ] dip BCL ;
: BDZLA    ( target_addr -- ) [ 0x12 0 ] dip BCLA ;
: BDZLRL   ( target_addr -- ) [ 0x12 0 ] dip BCLRL ;
: BDZT     ( bi target_addr -- ) [ 0xA ] 2dip BC ;
: BDZTA    ( bi target_addr -- ) [ 0xA ] 2dip BCA ;
: BDZTLR   ( bi target_addr -- ) [ 0xA ] 2dip BCLR ;
: BDZTL    ( bi target_addr -- ) [ 0xA ] 2dip BCL ;
: BDZTLA   ( bi target_addr -- ) [ 0xA ] 2dip BCLA ;
: BDZTLRL  ( bi target_addr -- ) [ 0xA ] 2dip BCLRL ;
: BDZF     ( bi target_addr -- ) [ 0x2 ] 2dip BC ;
: BDZFA    ( bi target_addr -- ) [ 0x2 ] 2dip BCA ;
: BDZFLR   ( bi target_addr -- ) [ 0x2 ] 2dip BCLR ;
: BDZFL    ( bi target_addr -- ) [ 0x2 ] 2dip BCL ;
: BDZFLA   ( bi target_addr -- ) [ 0x2 ] 2dip BCLA ;
: BDZFLRL  ( bi target_addr -- ) [ 0x2 ] 2dip BCLRL ;

! E.2.3 Branch Mnemonics Incorporating Conditions
: BLT      ( cr target_addr -- ) [ 4 * 0 + ] dip [ 12 ] 2dip BC ;
: BLTA     ( cr target_addr -- ) [ 4 * 0 + ] dip [ 12 ] 2dip BCA ;
: BLTLR    ( cr target_addr -- ) [ 4 * 0 + ] dip [ 12 ] 2dip BCLR ;
: BLTCTR   ( cr target_addr -- ) [ 4 * 0 + ] dip [ 12 ] 2dip BCCTR ;
: BLTL     ( cr target_addr -- ) [ 4 * 0 + ] dip [ 12 ] 2dip BCL ;
: BLTLA    ( cr target_addr -- ) [ 4 * 0 + ] dip [ 12 ] 2dip BCLA ;
: BLTLRL   ( cr target_addr -- ) [ 4 * 0 + ] dip [ 12 ] 2dip BCLRL ;
: BLTCTRL  ( cr target_addr -- ) [ 4 * 0 + ] dip [ 12 ] 2dip BCCTRL ;
: BGT      ( cr target_addr -- ) [ 4 * 1 + ] dip [ 12 ] 2dip BC ;
: BGTA     ( cr target_addr -- ) [ 4 * 1 + ] dip [ 12 ] 2dip BCA ;
: BGTLR    ( cr target_addr -- ) [ 4 * 1 + ] dip [ 12 ] 2dip BCLR ;
: BGTCTR   ( cr target_addr -- ) [ 4 * 1 + ] dip [ 12 ] 2dip BCCTR ;
: BGTL     ( cr target_addr -- ) [ 4 * 1 + ] dip [ 12 ] 2dip BCL ;
: BGTLA    ( cr target_addr -- ) [ 4 * 1 + ] dip [ 12 ] 2dip BCLA ;
: BGTLRL   ( cr target_addr -- ) [ 4 * 1 + ] dip [ 12 ] 2dip BCLRL ;
: BGTCTRL  ( cr target_addr -- ) [ 4 * 1 + ] dip [ 12 ] 2dip BCCTRL ;
: BEQ      ( cr target_addr -- ) [ 4 * 2 + ] dip [ 12 ] 2dip BC ;
: BEQA     ( cr target_addr -- ) [ 4 * 2 + ] dip [ 12 ] 2dip BCA ;
: BEQLR    ( cr target_addr -- ) [ 4 * 2 + ] dip [ 12 ] 2dip BCLR ;
: BEQCTR   ( cr target_addr -- ) [ 4 * 2 + ] dip [ 12 ] 2dip BCCTR ;
: BEQL     ( cr target_addr -- ) [ 4 * 2 + ] dip [ 12 ] 2dip BCL ;
: BEQLA    ( cr target_addr -- ) [ 4 * 2 + ] dip [ 12 ] 2dip BCLA ;
: BEQLRL   ( cr target_addr -- ) [ 4 * 2 + ] dip [ 12 ] 2dip BCLRL ;
: BEQCTRL  ( cr target_addr -- ) [ 4 * 2 + ] dip [ 12 ] 2dip BCCTRL ;
: BSO      ( cr target_addr -- ) [ 4 * 3 + ] dip [ 12 ] 2dip BC ;
: BSOA     ( cr target_addr -- ) [ 4 * 3 + ] dip [ 12 ] 2dip BCA ;
: BSOLR    ( cr target_addr -- ) [ 4 * 3 + ] dip [ 12 ] 2dip BCLR ;
: BSOCTR   ( cr target_addr -- ) [ 4 * 3 + ] dip [ 12 ] 2dip BCCTR ;
: BSOL     ( cr target_addr -- ) [ 4 * 3 + ] dip [ 12 ] 2dip BCL ;
: BSOLA    ( cr target_addr -- ) [ 4 * 3 + ] dip [ 12 ] 2dip BCLA ;
: BSOLRL   ( cr target_addr -- ) [ 4 * 3 + ] dip [ 12 ] 2dip BCLRL ;
: BSOCTRL  ( cr target_addr -- ) [ 4 * 3 + ] dip [ 12 ] 2dip BCCTRL ;
: BNL      ( cr target_addr -- ) [ 4 * 0 + ] dip [  4 ] 2dip BC ;
: BNLA     ( cr target_addr -- ) [ 4 * 0 + ] dip [  4 ] 2dip BCA ;
: BNLLR    ( cr target_addr -- ) [ 4 * 0 + ] dip [  4 ] 2dip BCLR ;
: BNLCTR   ( cr target_addr -- ) [ 4 * 0 + ] dip [  4 ] 2dip BCCTR ;
: BNLL     ( cr target_addr -- ) [ 4 * 0 + ] dip [  4 ] 2dip BCL ;
: BNLLA    ( cr target_addr -- ) [ 4 * 0 + ] dip [  4 ] 2dip BCLA ;
: BNLLRL   ( cr target_addr -- ) [ 4 * 0 + ] dip [  4 ] 2dip BCLRL ;
: BNLCTRL  ( cr target_addr -- ) [ 4 * 0 + ] dip [  4 ] 2dip BCCTRL ;
: BNG      ( cr target_addr -- ) [ 4 * 1 + ] dip [  4 ] 2dip BC ;
: BNGA     ( cr target_addr -- ) [ 4 * 1 + ] dip [  4 ] 2dip BCA ;
: BNGLR    ( cr target_addr -- ) [ 4 * 1 + ] dip [  4 ] 2dip BCLR ;
: BNGCTR   ( cr target_addr -- ) [ 4 * 1 + ] dip [  4 ] 2dip BCCTR ;
: BNGL     ( cr target_addr -- ) [ 4 * 1 + ] dip [  4 ] 2dip BCL ;
: BNGLA    ( cr target_addr -- ) [ 4 * 1 + ] dip [  4 ] 2dip BCLA ;
: BNGLRL   ( cr target_addr -- ) [ 4 * 1 + ] dip [  4 ] 2dip BCLRL ;
: BNGCTRL  ( cr target_addr -- ) [ 4 * 1 + ] dip [  4 ] 2dip BCCTRL ;
: BNE      ( cr target_addr -- ) [ 4 * 2 + ] dip [  4 ] 2dip BC ;
: BNEA     ( cr target_addr -- ) [ 4 * 2 + ] dip [  4 ] 2dip BCA ;
: BNELR    ( cr target_addr -- ) [ 4 * 2 + ] dip [  4 ] 2dip BCLR ;
: BNECTR   ( cr target_addr -- ) [ 4 * 2 + ] dip [  4 ] 2dip BCCTR ;
: BNEL     ( cr target_addr -- ) [ 4 * 2 + ] dip [  4 ] 2dip BCL ;
: BNELA    ( cr target_addr -- ) [ 4 * 2 + ] dip [  4 ] 2dip BCLA ;
: BNELRL   ( cr target_addr -- ) [ 4 * 2 + ] dip [  4 ] 2dip BCLRL ;
: BNECTRL  ( cr target_addr -- ) [ 4 * 2 + ] dip [  4 ] 2dip BCCTRL ;
: BNS      ( cr target_addr -- ) [ 4 * 3 + ] dip [  4 ] 2dip BC ;
: BNSA     ( cr target_addr -- ) [ 4 * 3 + ] dip [  4 ] 2dip BCA ;
: BNSLR    ( cr target_addr -- ) [ 4 * 3 + ] dip [  4 ] 2dip BCLR ;
: BNSCTR   ( cr target_addr -- ) [ 4 * 3 + ] dip [  4 ] 2dip BCCTR ;
: BNSL     ( cr target_addr -- ) [ 4 * 3 + ] dip [  4 ] 2dip BCL ;
: BNSLA    ( cr target_addr -- ) [ 4 * 3 + ] dip [  4 ] 2dip BCLA ;
: BNSLRL   ( cr target_addr -- ) [ 4 * 3 + ] dip [  4 ] 2dip BCLRL ;
: BNSCTRL  ( cr target_addr -- ) [ 4 * 3 + ] dip [  4 ] 2dip BCCTRL ;
: BUN      ( cr target_addr -- ) BSO ;
: BUNA     ( cr target_addr -- ) BSOA ;
: BUNLR    ( cr target_addr -- ) BSOLR ;
: BUNCTR   ( cr target_addr -- ) BSOCTR ;
: BUNL     ( cr target_addr -- ) BSOL ;
: BUNLA    ( cr target_addr -- ) BSOLA ;
: BUNLRL   ( cr target_addr -- ) BSOLRL ;
: BUNCTRL  ( cr target_addr -- ) BSOCTRL ;
: BNU      ( cr target_addr -- ) BNS ;
: BNUA     ( cr target_addr -- ) BNSA ;
: BNULR    ( cr target_addr -- ) BNSLR ;
: BNUCTR   ( cr target_addr -- ) BNSCTR ;
: BNUL     ( cr target_addr -- ) BNSL ;
: BNULA    ( cr target_addr -- ) BNSLA ;
: BNULRL   ( cr target_addr -- ) BNSLRL ;
: BNUCTRL  ( cr target_addr -- ) BNSCTRL ;
: BLE      ( cr target_addr -- ) BNG ;
: BLEA     ( cr target_addr -- ) BNGA ;
: BLELR    ( cr target_addr -- ) BNGLR ;
: BLECTR   ( cr target_addr -- ) BNGCTR ;
: BLEL     ( cr target_addr -- ) BNGL ;
: BLELA    ( cr target_addr -- ) BNGLA ;
: BLELRL   ( cr target_addr -- ) BNGLRL ;
: BLECTRL  ( cr target_addr -- ) BNGCTRL ;
: BGE      ( cr target_addr -- ) BNL ;
: BGEA     ( cr target_addr -- ) BNLA ;
: BGELR    ( cr target_addr -- ) BNLLR ;
: BGECTR   ( cr target_addr -- ) BNLCTR ;
: BGEL     ( cr target_addr -- ) BNLL ;
: BGELA    ( cr target_addr -- ) BNLLA ;
: BGELRL   ( cr target_addr -- ) BNLLRL ;
: BGECTRL  ( cr target_addr -- ) BNLCTRL ;

! E.2.4 Branch Prediction
: BT+       ( bi target_addr -- ) [ 0xF ] 2dip BC ;
: BTA+      ( bi target_addr -- ) [ 0xF ] 2dip BCA ;
: BTLR+     ( bi target_addr -- ) [ 0xF ] 2dip BCLR ;
: BTCTR+    ( bi target_addr -- ) [ 0xF ] 2dip BCCTR ;
: BTL+      ( bi target_addr -- ) [ 0xF ] 2dip BCL ;
: BTLA+     ( bi target_addr -- ) [ 0xF ] 2dip BCLA ;
: BTLRL+    ( bi target_addr -- ) [ 0xF ] 2dip BCLRL ;
: BTCTRL+   ( bi target_addr -- ) [ 0xF ] 2dip BCCTRL ;
: BF+       ( bi target_addr -- ) [ 0x7 ] 2dip BC ;
: BFA+      ( bi target_addr -- ) [ 0x7 ] 2dip BCA ;
: BFLR+     ( bi target_addr -- ) [ 0x7 ] 2dip BCLR ;
: BFCTR+    ( bi target_addr -- ) [ 0x7 ] 2dip BCCTR ;
: BFL+      ( bi target_addr -- ) [ 0x7 ] 2dip BCL ;
: BFLA+     ( bi target_addr -- ) [ 0x7 ] 2dip BCLA ;
: BFLRL+    ( bi target_addr -- ) [ 0x7 ] 2dip BCLRL ;
: BFCTRL+   ( bi target_addr -- ) [ 0x7 ] 2dip BCCTRL ;
: BDNZ+     ( target_addr -- ) [ 0x19 0 ] dip BC ;
: BDNZA+    ( target_addr -- ) [ 0x19 0 ] dip BCA ;
: BDNZLR+   ( target_addr -- ) [ 0x19 0 ] dip BCLR ;
: BDNZL+    ( target_addr -- ) [ 0x19 0 ] dip BCL ;
: BDNZLA+   ( target_addr -- ) [ 0x19 0 ] dip BCLA ;
: BDNZLRL+  ( target_addr -- ) [ 0x19 0 ] dip BCLRL ;
: BDZ+      ( target_addr -- ) [ 0x1B 0 ] dip BC ;
: BDZA+     ( target_addr -- ) [ 0x1B 0 ] dip BCA ;
: BDZLR+    ( target_addr -- ) [ 0x1B 0 ] dip BCLR ;
: BDZL+     ( target_addr -- ) [ 0x1B 0 ] dip BCL ;
: BDZLA+    ( target_addr -- ) [ 0x1B 0 ] dip BCLA ;
: BDZLRL+   ( target_addr -- ) [ 0x1B 0 ] dip BCLRL ;
: BT-       ( bi target_addr -- ) [ 0xE ] 2dip BC ;
: BTA-      ( bi target_addr -- ) [ 0xE ] 2dip BCA ;
: BTLR-     ( bi target_addr -- ) [ 0xE ] 2dip BCLR ;
: BTCTR-    ( bi target_addr -- ) [ 0xE ] 2dip BCCTR ;
: BTL-      ( bi target_addr -- ) [ 0xE ] 2dip BCL ;
: BTLA-     ( bi target_addr -- ) [ 0xE ] 2dip BCLA ;
: BTLRL-    ( bi target_addr -- ) [ 0xE ] 2dip BCLRL ;
: BTCTRL-   ( bi target_addr -- ) [ 0xE ] 2dip BCCTRL ;
: BF-       ( bi target_addr -- ) [ 0x6 ] 2dip BC ;
: BFA-      ( bi target_addr -- ) [ 0x6 ] 2dip BCA ;
: BFLR-     ( bi target_addr -- ) [ 0x6 ] 2dip BCLR ;
: BFCTR-    ( bi target_addr -- ) [ 0x6 ] 2dip BCCTR ;
: BFL-      ( bi target_addr -- ) [ 0x6 ] 2dip BCL ;
: BFLA-     ( bi target_addr -- ) [ 0x6 ] 2dip BCLA ;
: BFLRL-    ( bi target_addr -- ) [ 0x6 ] 2dip BCLRL ;
: BFCTRL-   ( bi target_addr -- ) [ 0x6 ] 2dip BCCTRL ;
: BDNZ-     ( target_addr -- ) [ 0x18 0 ] dip BC ;
: BDNZA-    ( target_addr -- ) [ 0x18 0 ] dip BCA ;
: BDNZLR-   ( target_addr -- ) [ 0x18 0 ] dip BCLR ;
: BDNZL-    ( target_addr -- ) [ 0x18 0 ] dip BCL ;
: BDNZLA-   ( target_addr -- ) [ 0x18 0 ] dip BCLA ;
: BDNZLRL-  ( target_addr -- ) [ 0x18 0 ] dip BCLRL ;
: BDZ-      ( target_addr -- ) [ 0x1A 0 ] dip BC ;
: BDZA-     ( target_addr -- ) [ 0x1A 0 ] dip BCA ;
: BDZLR-    ( target_addr -- ) [ 0x1A 0 ] dip BCLR ;
: BDZL-     ( target_addr -- ) [ 0x1A 0 ] dip BCL ;
: BDZLA-    ( target_addr -- ) [ 0x1A 0 ] dip BCLA ;
: BDZLRL-   ( target_addr -- ) [ 0x1A 0 ] dip BCLRL ;
: BLT+     ( cr target_addr -- ) [ 4 * 0 + ] dip [ 15 ] 2dip BC ;
: BLTA+    ( cr target_addr -- ) [ 4 * 0 + ] dip [ 15 ] 2dip BCA ;
: BLTLR+   ( cr target_addr -- ) [ 4 * 0 + ] dip [ 15 ] 2dip BCLR ;
: BLTCTR+  ( cr target_addr -- ) [ 4 * 0 + ] dip [ 15 ] 2dip BCCTR ;
: BLTL+    ( cr target_addr -- ) [ 4 * 0 + ] dip [ 15 ] 2dip BCL ;
: BLTLA+   ( cr target_addr -- ) [ 4 * 0 + ] dip [ 15 ] 2dip BCLA ;
: BLTLRL+  ( cr target_addr -- ) [ 4 * 0 + ] dip [ 15 ] 2dip BCLRL ;
: BLTCTRL+ ( cr target_addr -- ) [ 4 * 0 + ] dip [ 15 ] 2dip BCCTRL ;
: BGT+     ( cr target_addr -- ) [ 4 * 1 + ] dip [ 15 ] 2dip BC ;
: BGTA+    ( cr target_addr -- ) [ 4 * 1 + ] dip [ 15 ] 2dip BCA ;
: BGTLR+   ( cr target_addr -- ) [ 4 * 1 + ] dip [ 15 ] 2dip BCLR ;
: BGTCTR+  ( cr target_addr -- ) [ 4 * 1 + ] dip [ 15 ] 2dip BCCTR ;
: BGTL+    ( cr target_addr -- ) [ 4 * 1 + ] dip [ 15 ] 2dip BCL ;
: BGTLA+   ( cr target_addr -- ) [ 4 * 1 + ] dip [ 15 ] 2dip BCLA ;
: BGTLRL+  ( cr target_addr -- ) [ 4 * 1 + ] dip [ 15 ] 2dip BCLRL ;
: BGTCTRL+ ( cr target_addr -- ) [ 4 * 1 + ] dip [ 15 ] 2dip BCCTRL ;
: BEQ+     ( cr target_addr -- ) [ 4 * 2 + ] dip [ 15 ] 2dip BC ;
: BEQA+    ( cr target_addr -- ) [ 4 * 2 + ] dip [ 15 ] 2dip BCA ;
: BEQLR+   ( cr target_addr -- ) [ 4 * 2 + ] dip [ 15 ] 2dip BCLR ;
: BEQCTR+  ( cr target_addr -- ) [ 4 * 2 + ] dip [ 15 ] 2dip BCCTR ;
: BEQL+    ( cr target_addr -- ) [ 4 * 2 + ] dip [ 15 ] 2dip BCL ;
: BEQLA+   ( cr target_addr -- ) [ 4 * 2 + ] dip [ 15 ] 2dip BCLA ;
: BEQLRL+  ( cr target_addr -- ) [ 4 * 2 + ] dip [ 15 ] 2dip BCLRL ;
: BEQCTRL+ ( cr target_addr -- ) [ 4 * 2 + ] dip [ 15 ] 2dip BCCTRL ;
: BSO+     ( cr target_addr -- ) [ 4 * 3 + ] dip [ 15 ] 2dip BC ;
: BSOA+    ( cr target_addr -- ) [ 4 * 3 + ] dip [ 15 ] 2dip BCA ;
: BSOLR+   ( cr target_addr -- ) [ 4 * 3 + ] dip [ 15 ] 2dip BCLR ;
: BSOCTR+  ( cr target_addr -- ) [ 4 * 3 + ] dip [ 15 ] 2dip BCCTR ;
: BSOL+    ( cr target_addr -- ) [ 4 * 3 + ] dip [ 15 ] 2dip BCL ;
: BSOLA+   ( cr target_addr -- ) [ 4 * 3 + ] dip [ 15 ] 2dip BCLA ;
: BSOLRL+  ( cr target_addr -- ) [ 4 * 3 + ] dip [ 15 ] 2dip BCLRL ;
: BSOCTRL+ ( cr target_addr -- ) [ 4 * 3 + ] dip [ 15 ] 2dip BCCTRL ;
: BNL+     ( cr target_addr -- ) [ 4 * 0 + ] dip [  7 ] 2dip BC ;
: BNLA+    ( cr target_addr -- ) [ 4 * 0 + ] dip [  7 ] 2dip BCA ;
: BNLLR+   ( cr target_addr -- ) [ 4 * 0 + ] dip [  7 ] 2dip BCLR ;
: BNLCTR+  ( cr target_addr -- ) [ 4 * 0 + ] dip [  7 ] 2dip BCCTR ;
: BNLL+    ( cr target_addr -- ) [ 4 * 0 + ] dip [  7 ] 2dip BCL ;
: BNLLA+   ( cr target_addr -- ) [ 4 * 0 + ] dip [  7 ] 2dip BCLA ;
: BNLLRL+  ( cr target_addr -- ) [ 4 * 0 + ] dip [  7 ] 2dip BCLRL ;
: BNLCTRL+ ( cr target_addr -- ) [ 4 * 0 + ] dip [  7 ] 2dip BCCTRL ;
: BNG+     ( cr target_addr -- ) [ 4 * 1 + ] dip [  7 ] 2dip BC ;
: BNGA+    ( cr target_addr -- ) [ 4 * 1 + ] dip [  7 ] 2dip BCA ;
: BNGLR+   ( cr target_addr -- ) [ 4 * 1 + ] dip [  7 ] 2dip BCLR ;
: BNGCTR+  ( cr target_addr -- ) [ 4 * 1 + ] dip [  7 ] 2dip BCCTR ;
: BNGL+    ( cr target_addr -- ) [ 4 * 1 + ] dip [  7 ] 2dip BCL ;
: BNGLA+   ( cr target_addr -- ) [ 4 * 1 + ] dip [  7 ] 2dip BCLA ;
: BNGLRL+  ( cr target_addr -- ) [ 4 * 1 + ] dip [  7 ] 2dip BCLRL ;
: BNGCTRL+ ( cr target_addr -- ) [ 4 * 1 + ] dip [  7 ] 2dip BCCTRL ;
: BNE+     ( cr target_addr -- ) [ 4 * 2 + ] dip [  7 ] 2dip BC ;
: BNEA+    ( cr target_addr -- ) [ 4 * 2 + ] dip [  7 ] 2dip BCA ;
: BNELR+   ( cr target_addr -- ) [ 4 * 2 + ] dip [  7 ] 2dip BCLR ;
: BNECTR+  ( cr target_addr -- ) [ 4 * 2 + ] dip [  7 ] 2dip BCCTR ;
: BNEL+    ( cr target_addr -- ) [ 4 * 2 + ] dip [  7 ] 2dip BCL ;
: BNELA+   ( cr target_addr -- ) [ 4 * 2 + ] dip [  7 ] 2dip BCLA ;
: BNELRL+  ( cr target_addr -- ) [ 4 * 2 + ] dip [  7 ] 2dip BCLRL ;
: BNECTRL+ ( cr target_addr -- ) [ 4 * 2 + ] dip [  7 ] 2dip BCCTRL ;
: BNS+     ( cr target_addr -- ) [ 4 * 3 + ] dip [  7 ] 2dip BC ;
: BNSA+    ( cr target_addr -- ) [ 4 * 3 + ] dip [  7 ] 2dip BCA ;
: BNSLR+   ( cr target_addr -- ) [ 4 * 3 + ] dip [  7 ] 2dip BCLR ;
: BNSCTR+  ( cr target_addr -- ) [ 4 * 3 + ] dip [  7 ] 2dip BCCTR ;
: BNSL+    ( cr target_addr -- ) [ 4 * 3 + ] dip [  7 ] 2dip BCL ;
: BNSLA+   ( cr target_addr -- ) [ 4 * 3 + ] dip [  7 ] 2dip BCLA ;
: BNSLRL+  ( cr target_addr -- ) [ 4 * 3 + ] dip [  7 ] 2dip BCLRL ;
: BNSCTRL+ ( cr target_addr -- ) [ 4 * 3 + ] dip [  7 ] 2dip BCCTRL ;
: BUN+     ( cr target_addr -- ) BSO+ ;
: BUNA+    ( cr target_addr -- ) BSOA+ ;
: BUNLR+   ( cr target_addr -- ) BSOLR+ ;
: BUNCTR+  ( cr target_addr -- ) BSOCTR+ ;
: BUNL+    ( cr target_addr -- ) BSOL+ ;
: BUNLA+   ( cr target_addr -- ) BSOLA+ ;
: BUNLRL+  ( cr target_addr -- ) BSOLRL+ ;
: BUNCTRL+ ( cr target_addr -- ) BSOCTRL+ ;
: BNU+     ( cr target_addr -- ) BNS+ ;
: BNUA+    ( cr target_addr -- ) BNSA+ ;
: BNULR+   ( cr target_addr -- ) BNSLR+ ;
: BNUCTR+  ( cr target_addr -- ) BNSCTR+ ;
: BNUL+    ( cr target_addr -- ) BNSL+ ;
: BNULA+   ( cr target_addr -- ) BNSLA+ ;
: BNULRL+  ( cr target_addr -- ) BNSLRL+ ;
: BNUCTRL+ ( cr target_addr -- ) BNSCTRL+ ;
: BLE+     ( cr target_addr -- ) BNG+ ;
: BLEA+    ( cr target_addr -- ) BNGA+ ;
: BLELR+   ( cr target_addr -- ) BNGLR+ ;
: BLECTR+  ( cr target_addr -- ) BNGCTR+ ;
: BLEL+    ( cr target_addr -- ) BNGL+ ;
: BLELA+   ( cr target_addr -- ) BNGLA+ ;
: BLELRL+  ( cr target_addr -- ) BNGLRL+ ;
: BLECTRL+ ( cr target_addr -- ) BNGCTRL+ ;
: BGE+     ( cr target_addr -- ) BNL+ ;
: BGEA+    ( cr target_addr -- ) BNLA+ ;
: BGELR+   ( cr target_addr -- ) BNLLR+ ;
: BGECTR+  ( cr target_addr -- ) BNLCTR+ ;
: BGEL+    ( cr target_addr -- ) BNLL+ ;
: BGELA+   ( cr target_addr -- ) BNLLA+ ;
: BGELRL+  ( cr target_addr -- ) BNLLRL+ ;
: BGECTRL+ ( cr target_addr -- ) BNLCTRL+ ;
: BLT-     ( cr target_addr -- ) [ 4 * 0 + ] dip [ 14 ] 2dip BC ;
: BLTA-    ( cr target_addr -- ) [ 4 * 0 + ] dip [ 14 ] 2dip BCA ;
: BLTLR-   ( cr target_addr -- ) [ 4 * 0 + ] dip [ 14 ] 2dip BCLR ;
: BLTCTR-  ( cr target_addr -- ) [ 4 * 0 + ] dip [ 14 ] 2dip BCCTR ;
: BLTL-    ( cr target_addr -- ) [ 4 * 0 + ] dip [ 14 ] 2dip BCL ;
: BLTLA-   ( cr target_addr -- ) [ 4 * 0 + ] dip [ 14 ] 2dip BCLA ;
: BLTLRL-  ( cr target_addr -- ) [ 4 * 0 + ] dip [ 14 ] 2dip BCLRL ;
: BLTCTRL- ( cr target_addr -- ) [ 4 * 0 + ] dip [ 14 ] 2dip BCCTRL ;
: BGT-     ( cr target_addr -- ) [ 4 * 1 + ] dip [ 14 ] 2dip BC ;
: BGTA-    ( cr target_addr -- ) [ 4 * 1 + ] dip [ 14 ] 2dip BCA ;
: BGTLR-   ( cr target_addr -- ) [ 4 * 1 + ] dip [ 14 ] 2dip BCLR ;
: BGTCTR-  ( cr target_addr -- ) [ 4 * 1 + ] dip [ 14 ] 2dip BCCTR ;
: BGTL-    ( cr target_addr -- ) [ 4 * 1 + ] dip [ 14 ] 2dip BCL ;
: BGTLA-   ( cr target_addr -- ) [ 4 * 1 + ] dip [ 14 ] 2dip BCLA ;
: BGTLRL-  ( cr target_addr -- ) [ 4 * 1 + ] dip [ 14 ] 2dip BCLRL ;
: BGTCTRL- ( cr target_addr -- ) [ 4 * 1 + ] dip [ 14 ] 2dip BCCTRL ;
: BEQ-     ( cr target_addr -- ) [ 4 * 2 + ] dip [ 14 ] 2dip BC ;
: BEQA-    ( cr target_addr -- ) [ 4 * 2 + ] dip [ 14 ] 2dip BCA ;
: BEQLR-   ( cr target_addr -- ) [ 4 * 2 + ] dip [ 14 ] 2dip BCLR ;
: BEQCTR-  ( cr target_addr -- ) [ 4 * 2 + ] dip [ 14 ] 2dip BCCTR ;
: BEQL-    ( cr target_addr -- ) [ 4 * 2 + ] dip [ 14 ] 2dip BCL ;
: BEQLA-   ( cr target_addr -- ) [ 4 * 2 + ] dip [ 14 ] 2dip BCLA ;
: BEQLRL-  ( cr target_addr -- ) [ 4 * 2 + ] dip [ 14 ] 2dip BCLRL ;
: BEQCTRL- ( cr target_addr -- ) [ 4 * 2 + ] dip [ 14 ] 2dip BCCTRL ;
: BSO-     ( cr target_addr -- ) [ 4 * 3 + ] dip [ 14 ] 2dip BC ;
: BSOA-    ( cr target_addr -- ) [ 4 * 3 + ] dip [ 14 ] 2dip BCA ;
: BSOLR-   ( cr target_addr -- ) [ 4 * 3 + ] dip [ 14 ] 2dip BCLR ;
: BSOCTR-  ( cr target_addr -- ) [ 4 * 3 + ] dip [ 14 ] 2dip BCCTR ;
: BSOL-    ( cr target_addr -- ) [ 4 * 3 + ] dip [ 14 ] 2dip BCL ;
: BSOLA-   ( cr target_addr -- ) [ 4 * 3 + ] dip [ 14 ] 2dip BCLA ;
: BSOLRL-  ( cr target_addr -- ) [ 4 * 3 + ] dip [ 14 ] 2dip BCLRL ;
: BSOCTRL- ( cr target_addr -- ) [ 4 * 3 + ] dip [ 14 ] 2dip BCCTRL ;
: BNL-     ( cr target_addr -- ) [ 4 * 0 + ] dip [  6 ] 2dip BC ;
: BNLA-    ( cr target_addr -- ) [ 4 * 0 + ] dip [  6 ] 2dip BCA ;
: BNLLR-   ( cr target_addr -- ) [ 4 * 0 + ] dip [  6 ] 2dip BCLR ;
: BNLCTR-  ( cr target_addr -- ) [ 4 * 0 + ] dip [  6 ] 2dip BCCTR ;
: BNLL-    ( cr target_addr -- ) [ 4 * 0 + ] dip [  6 ] 2dip BCL ;
: BNLLA-   ( cr target_addr -- ) [ 4 * 0 + ] dip [  6 ] 2dip BCLA ;
: BNLLRL-  ( cr target_addr -- ) [ 4 * 0 + ] dip [  6 ] 2dip BCLRL ;
: BNLCTRL- ( cr target_addr -- ) [ 4 * 0 + ] dip [  6 ] 2dip BCCTRL ;
: BNG-     ( cr target_addr -- ) [ 4 * 1 + ] dip [  6 ] 2dip BC ;
: BNGA-    ( cr target_addr -- ) [ 4 * 1 + ] dip [  6 ] 2dip BCA ;
: BNGLR-   ( cr target_addr -- ) [ 4 * 1 + ] dip [  6 ] 2dip BCLR ;
: BNGCTR-  ( cr target_addr -- ) [ 4 * 1 + ] dip [  6 ] 2dip BCCTR ;
: BNGL-    ( cr target_addr -- ) [ 4 * 1 + ] dip [  6 ] 2dip BCL ;
: BNGLA-   ( cr target_addr -- ) [ 4 * 1 + ] dip [  6 ] 2dip BCLA ;
: BNGLRL-  ( cr target_addr -- ) [ 4 * 1 + ] dip [  6 ] 2dip BCLRL ;
: BNGCTRL- ( cr target_addr -- ) [ 4 * 1 + ] dip [  6 ] 2dip BCCTRL ;
: BNE-     ( cr target_addr -- ) [ 4 * 2 + ] dip [  6 ] 2dip BC ;
: BNEA-    ( cr target_addr -- ) [ 4 * 2 + ] dip [  6 ] 2dip BCA ;
: BNELR-   ( cr target_addr -- ) [ 4 * 2 + ] dip [  6 ] 2dip BCLR ;
: BNECTR-  ( cr target_addr -- ) [ 4 * 2 + ] dip [  6 ] 2dip BCCTR ;
: BNEL-    ( cr target_addr -- ) [ 4 * 2 + ] dip [  6 ] 2dip BCL ;
: BNELA-   ( cr target_addr -- ) [ 4 * 2 + ] dip [  6 ] 2dip BCLA ;
: BNELRL-  ( cr target_addr -- ) [ 4 * 2 + ] dip [  6 ] 2dip BCLRL ;
: BNECTRL- ( cr target_addr -- ) [ 4 * 2 + ] dip [  6 ] 2dip BCCTRL ;
: BNS-     ( cr target_addr -- ) [ 4 * 3 + ] dip [  6 ] 2dip BC ;
: BNSA-    ( cr target_addr -- ) [ 4 * 3 + ] dip [  6 ] 2dip BCA ;
: BNSLR-   ( cr target_addr -- ) [ 4 * 3 + ] dip [  6 ] 2dip BCLR ;
: BNSCTR-  ( cr target_addr -- ) [ 4 * 3 + ] dip [  6 ] 2dip BCCTR ;
: BNSL-    ( cr target_addr -- ) [ 4 * 3 + ] dip [  6 ] 2dip BCL ;
: BNSLA-   ( cr target_addr -- ) [ 4 * 3 + ] dip [  6 ] 2dip BCLA ;
: BNSLRL-  ( cr target_addr -- ) [ 4 * 3 + ] dip [  6 ] 2dip BCLRL ;
: BNSCTRL- ( cr target_addr -- ) [ 4 * 3 + ] dip [  6 ] 2dip BCCTRL ;
: BUN-     ( cr target_addr -- ) BSO- ;
: BUNA-    ( cr target_addr -- ) BSOA- ;
: BUNLR-   ( cr target_addr -- ) BSOLR- ;
: BUNCTR-  ( cr target_addr -- ) BSOCTR- ;
: BUNL-    ( cr target_addr -- ) BSOL- ;
: BUNLA-   ( cr target_addr -- ) BSOLA- ;
: BUNLRL-  ( cr target_addr -- ) BSOLRL- ;
: BUNCTRL- ( cr target_addr -- ) BSOCTRL- ;
: BNU-     ( cr target_addr -- ) BNS- ;
: BNUA-    ( cr target_addr -- ) BNSA- ;
: BNULR-   ( cr target_addr -- ) BNSLR- ;
: BNUCTR-  ( cr target_addr -- ) BNSCTR- ;
: BNUL-    ( cr target_addr -- ) BNSL- ;
: BNULA-   ( cr target_addr -- ) BNSLA- ;
: BNULRL-  ( cr target_addr -- ) BNSLRL- ;
: BNUCTRL- ( cr target_addr -- ) BNSCTRL- ;
: BLE-     ( cr target_addr -- ) BNG- ;
: BLEA-    ( cr target_addr -- ) BNGA- ;
: BLELR-   ( cr target_addr -- ) BNGLR- ;
: BLECTR-  ( cr target_addr -- ) BNGCTR- ;
: BLEL-    ( cr target_addr -- ) BNGL- ;
: BLELA-   ( cr target_addr -- ) BNGLA- ;
: BLELRL-  ( cr target_addr -- ) BNGLRL- ;
: BLECTRL- ( cr target_addr -- ) BNGCTRL- ;
: BGE-     ( cr target_addr -- ) BNL- ;
: BGEA-    ( cr target_addr -- ) BNLA- ;
: BGELR-   ( cr target_addr -- ) BNLLR- ;
: BGECTR-  ( cr target_addr -- ) BNLCTR- ;
: BGEL-    ( cr target_addr -- ) BNLL- ;
: BGELA-   ( cr target_addr -- ) BNLLA- ;
: BGELRL-  ( cr target_addr -- ) BNLLRL- ;
: BGECTRL- ( cr target_addr -- ) BNLCTRL- ;

! E.3 Condition Register Logical Mnemonics
: CRSET  ( bx -- )    dup dup CREQV ;
: CRCLR  ( bx -- )    dup dup CRXOR ;
: CRMOVE ( bx by -- ) dup     CROR  ;
: CRNOT  ( bx by -- ) dup     CRNOR ;

! E.4.1 Subtract Immediate
: SUBI   ( dst src1 src2 -- ) neg ADDI   ;
: SUBIS  ( dst src1 src2 -- ) neg ADDIS  ;
: SUBIC  ( dst src1 src2 -- ) neg ADDIC  ;
: SUBIC. ( dst src1 src2 -- ) neg ADDIC. ;

! E.4.2 Subtract
: SUB    ( rx ry rz -- ) swap SUBF    ;
: SUB.   ( rx ry rz -- ) swap SUBF.   ;
: SUBO   ( rx ry rz -- ) swap SUBFO   ;
: SUBO.  ( rx ry rz -- ) swap SUBFO.  ;
: SUBC   ( rx ry rz -- ) swap SUBFC   ;
: SUBC.  ( rx ry rz -- ) swap SUBFC.  ;
: SUBCO  ( rx ry rz -- ) swap SUBFCO  ;
: SUBCO. ( rx ry rz -- ) swap SUBFCO. ;

! E.5.1 Double Word Comparisons
: CMPDI  ( bf ra si -- ) [ 1 ] 2dip CMPI  ;
: CMPD   ( bf ra rb -- ) [ 1 ] 2dip CMP   ;
: CMPLDI ( bf ra ui -- ) [ 1 ] 2dip CMPLI ;
: CMPLD  ( bf ra rb -- ) [ 1 ] 2dip CMPL  ;

! E.5.2 Word Comparisons
: CMPWI  ( bf ra si -- ) [ 0 ] 2dip CMPI  ;
: CMPW   ( bf ra rb -- ) [ 0 ] 2dip CMP   ;
: CMPLWI ( bf ra ui -- ) [ 0 ] 2dip CMPLI ;
: CMPLW  ( bf ra rb -- ) [ 0 ] 2dip CMPL  ;

! E.6 Trap Mnemonics
: TRAP ( -- ) 31 0 0 TW ;
: TDUI   ( rx  n -- ) [ 31 ] 2dip TDI ;
: TDU    ( rx ry -- ) [ 31 ] 2dip TD  ;
: TWUI   ( rx  n -- ) [ 31 ] 2dip TWI ;
: TWU    ( rx ry -- ) [ 31 ] 2dip TW  ;
: TDLTI  ( rx  n -- ) [ 16 ] 2dip TDI ;
: TDLT   ( rx ry -- ) [ 16 ] 2dip TD  ;
: TWLTI  ( rx  n -- ) [ 16 ] 2dip TWI ;
: TWLT   ( rx ry -- ) [ 16 ] 2dip TW  ;
: TDLEI  ( rx  n -- ) [ 20 ] 2dip TDI ;
: TDLE   ( rx ry -- ) [ 20 ] 2dip TD  ;
: TWLEI  ( rx  n -- ) [ 20 ] 2dip TWI ;
: TWLE   ( rx ry -- ) [ 20 ] 2dip TW  ;
: TDEQI  ( rx  n -- ) [  4 ] 2dip TDI ;
: TDEQ   ( rx ry -- ) [  4 ] 2dip TD  ;
: TWEQI  ( rx  n -- ) [  4 ] 2dip TWI ;
: TWEQ   ( rx ry -- ) [  4 ] 2dip TW  ;
: TDGEI  ( rx  n -- ) [ 12 ] 2dip TDI ;
: TDGE   ( rx ry -- ) [ 12 ] 2dip TD  ;
: TWGEI  ( rx  n -- ) [ 12 ] 2dip TWI ;
: TWGE   ( rx ry -- ) [ 12 ] 2dip TW  ;
: TDGTI  ( rx  n -- ) [  8 ] 2dip TDI ;
: TDGT   ( rx ry -- ) [  8 ] 2dip TD  ;
: TWGTI  ( rx  n -- ) [  8 ] 2dip TWI ;
: TWGT   ( rx ry -- ) [  8 ] 2dip TW  ;
: TDNLI  ( rx  n -- ) [ 12 ] 2dip TDI ;
: TDNL   ( rx ry -- ) [ 12 ] 2dip TD  ;
: TWNLI  ( rx  n -- ) [ 12 ] 2dip TWI ;
: TWNL   ( rx ry -- ) [ 12 ] 2dip TW  ;
: TDNEI  ( rx  n -- ) [ 24 ] 2dip TDI ;
: TDNE   ( rx ry -- ) [ 24 ] 2dip TD  ;
: TWNEI  ( rx  n -- ) [ 24 ] 2dip TWI ;
: TWNE   ( rx ry -- ) [ 24 ] 2dip TW  ;
: TDNGI  ( rx  n -- ) [ 20 ] 2dip TDI ;
: TDNG   ( rx ry -- ) [ 20 ] 2dip TD  ;
: TWNGI  ( rx  n -- ) [ 20 ] 2dip TWI ;
: TWNG   ( rx ry -- ) [ 20 ] 2dip TW  ;
: TDLLTI ( rx  n -- ) [  2 ] 2dip TDI ;
: TDLLT  ( rx ry -- ) [  2 ] 2dip TD  ;
: TWLLTI ( rx  n -- ) [  2 ] 2dip TWI ;
: TWLLT  ( rx ry -- ) [  2 ] 2dip TW  ;
: TDLLEI ( rx  n -- ) [  6 ] 2dip TDI ;
: TDLLE  ( rx ry -- ) [  6 ] 2dip TD  ;
: TWLLEI ( rx  n -- ) [  6 ] 2dip TWI ;
: TWLLE  ( rx ry -- ) [  6 ] 2dip TW  ;
: TDLGEI ( rx  n -- ) [  5 ] 2dip TDI ;
: TDLGE  ( rx ry -- ) [  5 ] 2dip TD  ;
: TWLGEI ( rx  n -- ) [  5 ] 2dip TWI ;
: TWLGE  ( rx ry -- ) [  5 ] 2dip TW  ;
: TDLGTI ( rx  n -- ) [  1 ] 2dip TDI ;
: TDLGT  ( rx ry -- ) [  1 ] 2dip TD  ;
: TWLGTI ( rx  n -- ) [  1 ] 2dip TWI ;
: TWLGT  ( rx ry -- ) [  1 ] 2dip TW  ;
: TDLNLI ( rx  n -- ) [  5 ] 2dip TDI ;
: TDLNL  ( rx ry -- ) [  5 ] 2dip TD  ;
: TWLNLI ( rx  n -- ) [  5 ] 2dip TWI ;
: TWLNL  ( rx ry -- ) [  5 ] 2dip TW  ;
: TDLNGI ( rx  n -- ) [  6 ] 2dip TDI ;
: TDLNG  ( rx ry -- ) [  6 ] 2dip TD  ;
: TWLNGI ( rx  n -- ) [  6 ] 2dip TWI ;
: TWLNG  ( rx ry -- ) [  6 ] 2dip TW  ;

! E.7.1 Operations on Doublewords
: EXTLDI    ( ra rs  n b -- ) swap 1 - RLDICR ;
: EXTLDI.   ( ra rs  n b -- ) swap 1 - RLDICR. ;
: EXTRDI    ( ra rs  n b -- ) [ + ] [ drop 64 swap - ] 2bi RLDICL ;
: EXTRDI.   ( ra rs  n b -- ) [ + ] [ drop 64 swap - ] 2bi RLDICL. ;
: INSRDI    ( ra rs  n b -- ) [ + 64 swap - ] [ nip ] 2bi RLDIMI ;
: INSRDI.   ( ra rs  n b -- ) [ + 64 swap - ] [ nip ] 2bi RLDIMI. ;
: ROTLDI    ( ra rs  n -- ) 0 RLDICL ;
: ROTLDI.   ( ra rs  n -- ) 0 RLDICL. ;
: ROTRDI    ( ra rs  n -- ) 64 swap - 0 RLDICL ;
: ROTRDI.   ( ra rs  n -- ) 64 swap - 0 RLDICL. ;
: ROTLD     ( ra rs rb -- ) 0 RLDCL ;
: ROTLD.    ( ra rs rb -- ) 0 RLDCL. ;
: SLDI      ( ra rs  n -- ) dup 63 swap - RLDICR ;
: SLDI.     ( ra rs  n -- ) dup 63 swap - RLDICR. ;
: SRDI      ( ra rs  n -- ) dup [ 64 swap - ] dip RLDICL ;
: SRDI.     ( ra rs  n -- ) dup [ 64 swap - ] dip RLDICL. ;
: CLRLDI    ( ra rs  n -- ) 0 swap RLDICL ;
: CLRLDI.   ( ra rs  n -- ) 0 swap RLDICL. ;
: CLRRDI    ( ra rs  n -- ) 0 swap 63 swap - RLDICR ;
: CLRRDI.   ( ra rs  n -- ) 0 swap 63 swap - RLDICR. ;
: CLRLSLDI  ( ra rs  b n -- ) tuck - RLDIC ;
: CLRLSLDI. ( ra rs  b n -- ) tuck - RLDIC. ;

! E.7.2 Operations on Words
: EXTLWI    ( ra rs  n b -- ) swap 0 1 - RLWINM ;
: EXTLWI.   ( ra rs  n b -- ) swap 0 1 - RLWINM. ;
: EXTRWI    ( ra rs  n b -- ) swap dup [ + ] dip 32 swap - 31 RLWINM ;
: EXTRWI.   ( ra rs  n b -- ) swap dup [ + ] dip 32 swap - 31 RLWINM. ;
: INSLWI    ( ra rs  n b -- ) [ [ drop 32 ] dip - ] [ nip ] [ + 1 - ] 2tri RLWIMI ;
: INSLWI.   ( ra rs  n b -- ) [ [ drop 32 ] dip - ] [ nip ] [ + 1 - ] 2tri RLWIMI. ;
: INSRWI    ( ra rs  n b -- ) [ + 32 swap - ] [ nip ] [ + 1 - ] 2tri RLWIMI ;
: INSRWI.   ( ra rs  n b -- ) [ + 32 swap - ] [ nip ] [ + 1 - ] 2tri RLWIMI. ;
: ROTLWI    ( ra rs  n -- ) 0 31 RLWINM ;
: ROTLWI.   ( ra rs  n -- ) 0 31 RLWINM. ;
: ROTRWI    ( ra rs  n -- ) 32 swap - 0 31 RLWINM ;
: ROTRWI.   ( ra rs  n -- ) 32 swap - 0 31 RLWINM. ;
: ROTLW     ( ra rs rb -- ) 0 31 RLWNM ;
: ROTLW.    ( ra rs rb -- ) 0 31 RLWNM. ;
: SLWI      ( ra rs  n -- ) 0 over 31 swap - RLWINM ;
: SLWI.     ( ra rs  n -- ) 0 over 31 swap - RLWINM. ;
: SRWI      ( ra rs  n -- ) [ 32 swap - ] [ ] bi 31 RLWINM ;
: SRWI.     ( ra rs  n -- ) [ 32 swap - ] [ ] bi 31 RLWINM. ;
: CLRLWI    ( ra rs  n -- ) 0 swap 31 RLWINM ;
: CLRLWI.   ( ra rs  n -- ) 0 swap 31 RLWINM. ;
: CLRRWI    ( ra rs  n -- ) [ 0 0 ] dip 31 swap - RLWINM ;
: CLRRWI.   ( ra rs  n -- ) [ 0 0 ] dip 31 swap - RLWINM. ;
: CLRLSLWI  ( ra rs  b n -- ) [ nip ] [ - ] [ nip 31 swap - ] 2tri RLWINM ;
: CLRLSLWI. ( ra rs  b n -- ) [ nip ] [ - ] [ nip 31 swap - ] 2tri RLWINM. ;

! E.8 Move To/From Special Purpose Registers Mnemonics
: MFXER   ( rx -- )   1  5 shift MFSPR ;
: MFLR    ( rx -- )   8  5 shift MFSPR ;
: MFCTR   ( rx -- )   9  5 shift MFSPR ;
: MFUAMR  ( rx -- )  13  5 shift MFSPR ;
: MFPPR   ( rx -- ) 896 -5 shift MFSPR ;
: MFPPR32 ( rx -- ) 898 -5 shift MFSPR ;
: MTXER   ( rx -- )   1  5 shift swap MTSPR ;
: MTLR    ( rx -- )   8  5 shift swap MTSPR ;
: MTCTR   ( rx -- )   9  5 shift swap MTSPR ;
: MTUAMR  ( rx -- )  13  5 shift swap MTSPR ;
: MTPPR   ( rx -- ) 896 -5 shift swap MTSPR ;
: MTPPR32 ( rx -- ) 898 -5 shift swap MTSPR ;

! E.9 Miscellaneous Mnemonics
: NOP ( -- ) 0 0 0 ORI ;
: XNOP ( -- ) 0 0 0 XORI ;
: LI ( dst value -- ) 0 swap ADDI ;
: LIS ( dst value -- ) 0 swap ADDIS ;
: LA ( rx ry d -- ) ADDI ;
: MR ( dst src -- ) dup OR ;
: MR. ( dst src -- ) dup OR. ;
: NOT ( dst src -- ) dup NOR ;
: NOT. ( dst src -- ) dup NOR. ;
: MTCR ( rx -- ) 0xff swap MTCRF ; deprecated
