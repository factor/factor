! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: assembler
USING: errors kernel math memory words ;

! See the Motorola or IBM documentation for details. The opcode
! names are standard.

: insn ( operand opcode -- ) 26 shift bitor compile-cell ;

: b-form ( bo bi bd aa lk -- n )
    >r 1 shift >r 2 shift >r 16 shift >r 21 shift
    r> bitor r> bitor r> bitor r> bitor ;

: d-form ( d a simm -- n )
    HEX: ffff bitand >r 16 shift >r 21 shift r> bitor r> bitor ;

: i-form ( li aa lk -- n )
    >r 1 shift bitor r> bitor ;

: xfx-form ( d spr xo -- n )
    1 shift >r 11 shift >r 21 shift r> bitor r> bitor ;

: ADDI d-form 14 insn ;
: SUBI neg ADDI ;
: LI 0 rot ADDI ;
: ADDIS d-form 15 insn ;
: LIS 0 rot ADDIS ;
: ORI d-form 24 insn ;
: BL 0 1 i-form 18 insn ;
: BCLR 0 8 0 0 b-form 19 insn ;
: BLR 20 BCLR ;
: MFSPR 5 shift 339 xfx-form 31 insn ;
: MFLR 8 MFSPR ;
: MTSPR 5 shift 467 xfx-form 31 insn ;
: MTLR 8 MTSPR ;
: LWZ d-form 32 insn ;
: STW d-form 36 insn ;
: STWU d-form 37 insn ;
