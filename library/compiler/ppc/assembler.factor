! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: assembler
USING: errors kernel math memory words ;

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

: x-form ( s a b xo rc -- n )
    >r 1 shift >r 11 shift >r 16 shift >r 21 shift
    r> bitor r> bitor r> bitor r> bitor ;

: xfx-form ( d spr xo -- n )
    1 shift >r 11 shift >r 21 shift r> bitor r> bitor ;

: xo-form ( d a b oe xo rc -- n )
    >r 1 shift >r 10 shift >r 11 shift >r 16 shift >r 21 shift
    r> bitor r> bitor r> bitor r> bitor r> bitor ;

: ADDI d-form 14 insn ;
: LI 0 rot ADDI ;
: ADDIS d-form 15 insn ;
: LIS 0 rot ADDIS ;
: ADD 0 266 0 xo-form 31 insn ;
: SUBI neg ADDI ;
: ORI d-form 24 insn ;
: SRAWI 824 0 x-form 31 insn ;
: BL 0 1 i-form 18 insn ;
: B 0 0 i-form 18 insn ;
: BC 0 0 b-form 16 insn ;
: BEQ 12 2 rot BC ;
: BNE 4 2 rot BC ;
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
: LWZ d-form 32 insn ;
: STW d-form 36 insn ;
: STWU d-form 37 insn ;
: CMPI d-form 11 insn ;

: LOAD32 >r w>h/h r> tuck LIS dup rot ORI ;

: LOAD ( n r -- )
    #! PowerPC cannot load a 32 bit literal in one instruction.
   >r dup dup HEX: ffff bitand = [ r> LI ] [ r> LOAD32 ] ifte ;
