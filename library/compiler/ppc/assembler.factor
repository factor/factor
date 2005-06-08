! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: assembler
USING: compiler errors kernel math memory words ;

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

: insn ( operand opcode -- ) 26 shift bitor compile-cell ;

: b-form ( bo bi bd aa lk -- n )
    >r 1 shift >r 2 shift >r 16 shift >r 21 shift
    r> bitor r> bitor r> bitor r> bitor ;

: d-form ( d a simm -- n )
    HEX: ffff bitand >r 16 shift >r 21 shift r> bitor r> bitor ;

: i-form ( li aa lk -- n )
    >r 1 shift bitor r> bitor ;

: m-form ( s a b mb me -- n )
    >r 1 shift >r 6 shift >r 11 shift >r 16 shift >r 21 shift
    r> bitor r> bitor r> bitor r> bitor r> bitor ;

: x-form ( a s b xo rc -- n )
    swap
    >r 1 shift >r 11 shift >r swap 16 shift >r 21 shift
    r> bitor r> bitor r> bitor r> bitor ;

: xfx-form ( d spr xo -- n )
    1 shift >r 11 shift >r 21 shift r> bitor r> bitor ;

: xo-form ( d a b oe rc xo -- n )
    swap
    >r 1 shift >r 10 shift >r 11 shift >r 16 shift >r 21 shift
    r> bitor r> bitor r> bitor r> bitor r> bitor ;

: ADDI d-form 14 insn ;   : LI 0 rot ADDI ;   : SUBI neg ADDI ;
: ADDIS d-form 15 insn ;  : LIS 0 rot ADDIS ;

: ADDIC d-form 12 insn ;  : SUBIC neg ADDIC ;

: ADDIC. d-form 13 insn ; : SUBIC. neg ADDIC. ;

: (ADD) 266 xo-form 31 insn ;
: ADD 0 0 (ADD) ;
: ADD. 0 1 (ADD) ;
: ADDO 1 0 (ADD) ;
: ADDO. 1 1 (ADD) ;

: (ADDC) 10 xo-form 31 insn ;
: ADDC 0 0 (ADDC) ;
: ADDC. 0 1 (ADDC) ;
: ADDCO 1 0 (ADDC) ;
: ADDCO. 1 1 (ADDC) ;

: (ADDE) 138 xo-form 31 insn ;
: ADDE 0 0 (ADDE) ;
: ADDE. 0 1 (ADDE) ;
: ADDEO 1 0 (ADDE) ;
: ADDEO. 1 1 (ADDE) ;

: ANDI d-form 28 insn ;
: ANDIS d-form 29 insn ;

: (AND) 28 x-form 31 insn ;
: AND 0 (AND) ;
: AND. 0 (AND) ;

: (DIVW) 491 xo-form 31 insn ;
: DIVW 0 0 (DIVW) ;
: DIVW. 0 1 (DIVW) ;
: DIVWO 1 0 (DIVW) ;
: DIVWO 1 1 (DIVW) ;

: (DIVWU) 459 xo-form 31 insn ;
: DIVWU 0 0 (DIVWU) ;
: DIVWU. 0 1 (DIVWU) ;
: DIVWUO 1 0 (DIVWU) ;
: DIVWUO. 1 1 (DIVWU) ;

: (EQV) 284 x-form 31 insn ;
: EQV 0 (EQV) ;
: EQV. 1 (EQV) ;

: (NAND) 476 x-form 31 insn ;
: NAND 0 (NAND) ;
: NAND. 1 (NAND) ;

: (NOR) 124 x-form 31 insn ;
: NOR 0 (NOR) ;
: NOR. 1 (NOR) ;

: NOT dup NOR ;
: NOT. dup NOR. ;

: ORI d-form 24 insn ;
: ORIS d-form 25 insn ;

: (OR) 444 x-form 31 insn ;
: OR 0 (OR) ;
: OR. 1 (OR) ;

: (ORC) 412 x-form 31 insn ;
: ORC 0 (ORC) ;
: ORC. 1 (ORC) ;

: MR dup OR ;
: MR. dup OR. ;

: (MULHW) 75 xo-form 31 insn ;
: MULHW 0 0 (MULHW) ;
: MULHW. 0 1 (MULHW) ;

: MULLI d-form 7 insn ;

: (MULHWU) 11 xo-form 31 insn ;
: MULHWU 0 0 (MULHWU) ;
: MULHWU. 0 1 (MULHWU) ;

: (MULLW) 235 xo-form 31 insn ;
: MULLW 0 0 (MULLW) ;
: MULLW. 0 1 (MULLW) ;
: MULLWO 1 0 (MULLW) ;
: MULLWO. 1 1 (MULLW) ;

: (SLW) 24 x-form 31 insn ;
: SLW 0 (SLW) ;
: SLW. 1 (SLW) ;

: (SRAW) 792 x-form 31 insn ;
: SRAW 0 (SRAW) ;
: SRAW. 1 (SRAW) ;

: (SRW) 536 x-form 31 insn ;
: SRW 0 (SRW) ;
: SRW. 1 (SRW) ;

: SRAWI 0 824 x-form 31 insn ;

: (SUBF) 40 xo-form 31 insn ;
: SUBF 0 0 (SUBF) ;
: SUBF. 0 1 (SUBF) ;
: SUBFO 1 0 (SUBF) ;
: SUBFO. 1 1 (SUBF) ;

: (SUBFC) 8 xo-form 31 insn ;
: SUBFC 0 0 (SUBFC) ;
: SUBFC. 0 1 (SUBFC) ;
: SUBFCO 1 0 (SUBFC) ;
: SUBFCO. 1 1 (SUBFC) ;

: (SUBFE) 136 xo-form 31 insn ;
: SUBFE 0 0 (SUBFE) ;
: SUBFE. 0 1 (SUBFE) ;
: SUBFEO 1 0 (SUBFE) ;
: SUBFEO. 1 1 (SUBFE) ;

: XORI d-form 26 insn ;
: XORIS d-form 27 insn ;

: (XOR) 316 x-form 31 insn ;
: XOR 0 (XOR) ;
: XOR. 1 (XOR) ;

: CMPI d-form 11 insn ;
: CMPLI d-form 10 insn ;

: CMP 0 0 x-form 31 insn ;
: CMPL 0 32 x-form 31 insn ;

: (RLWINM) m-form 21 insn ;
: RLWINM 0 (RLWINM) ;
: RLWINM. 1 (RLWINM) ;

: SLWI 0 31 pick - RLWINM ;
: SLWI. 0 31 pick - RLWINM. ;

: LBZ d-form 34 insn ;  : LBZU d-form 35 insn ;
: LHA d-form 42 insn ;  : LHAU d-form 43 insn ;
: LHZ d-form 40 insn ;  : LHZU d-form 41 insn ;
: LWZ d-form 32 insn ;  : LWZU d-form 33 insn ;

: STB d-form 38 insn ;  : STBU d-form 39 insn ;
: STH d-form 44 insn ;  : STHU d-form 45 insn ;
: STW d-form 36 insn ;  : STWU d-form 37 insn ;

G: (B) ( dest aa lk -- ) [ pick ] [ type ] ;
M: integer (B) i-form 18 insn ;
M: word (B) 0 -rot (B) relative-24 ;

: B 0 0 (B) ; : BL 0 1 (B) ;

GENERIC: BC
M: integer BC 0 0 b-form 16 insn ;
M: word BC >r 0 BC r> relative-14 ;

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
   >r dup dup HEX: ffff bitand = [ r> LI ] [ r> LOAD32 ] ifte ;
