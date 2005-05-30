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

: x-form ( s a b xo rc -- n )
    >r 1 shift >r 11 shift >r 16 shift >r 21 shift
    r> bitor r> bitor r> bitor r> bitor ;

: xfx-form ( d spr xo -- n )
    1 shift >r 11 shift >r 21 shift r> bitor r> bitor ;

: xo-form ( d a b oe xo rc -- n )
    >r 1 shift >r 10 shift >r 11 shift >r 16 shift >r 21 shift
    r> bitor r> bitor r> bitor r> bitor r> bitor ;

: ADDI d-form 14 insn ;   : LI 0 rot ADDI ;   : SUBI neg ADDI ;
: ADDIS d-form 15 insn ;  : LIS 0 rot ADDIS ;

: ADDIC d-form 12 insn ;  : SUBIC neg ADDIC ;

: ADDIC. d-form 13 insn ; : SUBIC. neg ADDIC. ;

: (ADD) 266 swap xo-form 31 insn ;
: ADD 0 0 (ADD) ;
: ADD. 0 1 (ADD) ;
: ADDO 1 0 (ADD) ;
: ADDO. 1 1 (ADD) ;

: (ADDC) 10 swap xo-form 31 insn ;
: ADDC 0 0 (ADDC) ;
: ADDC. 0 1 (ADDC) ;
: ADDCO 1 0 (ADDC) ;
: ADDCO. 1 1 (ADDC) ;

: (ADDE) 138 swap xo-form 31 insn ;
: ADDE 0 0 (ADDE) ;
: ADDE. 0 1 (ADDE) ;
: ADDEO 1 0 (ADDE) ;
: ADDEO. 1 1 (ADDE) ;

: ANDI d-form 28 insn ;
: ANDIS d-form 29 insn ;

: (AND) 31 swap x-form 31 insn ;
: AND 0 (AND) ;
: AND. 0 (AND) ;

: (DIVW) 491 swap xo-form 31 insn ;
: DIVW 0 0 (DIVW) ;
: DIVW. 0 1 (DIVW) ;
: DIVWO 1 0 (DIVW) ;
: DIVWO 1 1 (DIVW) ;

: (DIVWU) 459 swap xo-form 31 insn ;
: DIVWU 0 0 (DIVWU) ;
: DIVWU. 0 1 (DIVWU) ;
: DIVWUO 1 0 (DIVWU) ;
: DIVWUO. 1 1 (DIVWU) ;

: (EQV) 284 swap x-form 31 insn ;
: EQV 0 (EQV) ;
: EQV. 1 (EQV) ;

: (NAND) 476 swap x-form 31 insn ;
: NAND 0 (NAND) ;
: NAND. 1 (NAND) ;

: (NOR) 124 swap x-form 31 insn ;
: NOR 0 (NOR) ;
: NOR. 1 (NOR) ;

: ORI d-form 24 insn ;
: ORIS d-form 25 insn ;

: (OR) 444 swap x-form 31 insn ;
: OR 0 (OR) ;
: OR. 1 (OR) ;

: (ORC) 412 swap x-form 31 insn ;
: ORC 0 (ORC) ;
: ORC. 1 (ORC) ;

: (SLW) 24 swap x-form 31 insn ;
: SLW 0 (SLW) ;
: SLW. 1 (SLW) ;

: (SRAW) 792 swap x-form 31 insn ;
: SRAW 0 (SRAW) ;
: SRAW. 1 (SRAW) ;

: (SRW) 536 swap x-form 31 insn ;
: SRW 0 (SRW) ;
: SRW. 1 (SRW) ;

: SRAWI 824 0 x-form 31 insn ;

: XORI d-form 26 insn ;
: XORIS d-form 27 insn ;

: (XOR) 316 swap x-form 31 insn ;
: XOR 0 (XOR) ;
: XOR. 1 (XOR) ;

: (RLWINM) m-form 21 insn ;
: RLWINM 0 (RLWINM) ;
: RLWINM. 1 (RLWINM) ;

: LBZ d-form 34 insn ;  : LBZU d-form 35 insn ;
: LHA d-form 42 insn ;  : LHAU d-form 43 insn ;
: LHZ d-form 40 insn ;  : LHZU d-form 41 insn ;
: LWZ d-form 32 insn ;  : LWZU d-form 33 insn ;

: STB d-form 38 insn ;  : STBU d-form 39 insn ;
: STH d-form 44 insn ;  : STHU d-form 45 insn ;
: STW d-form 36 insn ;  : STWU d-form 37 insn ;

G: (B) ( dest aa lk -- ) [ pick ] [ type ] ;
M: integer (B) i-form 18 insn ;
M: word (B) 0 swap (B) relative-24 ;

: B 0 0 (B) ; : BA 1 0 (B) ; : BL 0 1 (B) ; : BLA 1 1 (B) ;

GENERIC: BC
M: integer BC 0 0 b-form 16 insn ;
M: word BC >r 0 BC r> relative-14 ;

: BEQ 12 2 rot BC ;  : BNE 4 2 rot BC ;

: BCLR 0 8 0 0 b-form 19 insn ;
: BLR 20 BCLR ;
: BCLRL 0 8 0 1 b-form 19 insn ;
: BLRL 20 BCLRL ;
: BCCTR 0 264 0 0 b-form 19 insn ;
: BCTR 20 BCCTR ;
: MFSPR 5 shift 339 xfx-form 31 insn ;
: MFLR 8 MFSPR ;
: MFCTR 9 MFSPR ;
: MTSPR 5 shift 467 xfx-form 31 insn ;
: MTLR 8 MTSPR ;
: MTCTR 9 MTSPR ;
: CMPI d-form 11 insn ;

: LOAD32 >r w>h/h r> tuck LIS dup rot ORI ;

: LOAD ( n r -- )
    #! PowerPC cannot load a 32 bit literal in one instruction.
   >r dup dup HEX: ffff bitand = [ r> LI ] [ r> LOAD32 ] ifte ;
