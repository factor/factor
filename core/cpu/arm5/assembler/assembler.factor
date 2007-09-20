! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generator generator.fixup kernel sequences words
namespaces math math.bitfields cpu.arm.assembler ;
IN: cpu.arm5.assembler

TUPLE: arm5-variant ;

GENERIC# (BX) 1 ( Rm l -- )

M: register (BX) ( Rm l -- )
    {
        { 1 24 }
        { 1 21 }
        { BIN: 1111 16 }
        { BIN: 1111 12 }
        { BIN: 1111 8 }
        5
        { 1 4 }
        { register 0 }
    } insn ;

M: word (BX) 0 swap (BX) rc-relative-arm-3 rel-word ;

M: label (BX) 0 swap (BX) rc-relative-arm-3 label-fixup ;

M: arm5-variant BX 0 (BX) ;

M: arm5-variant BLX 1 (BX) ;

! More load and store instructions
GENERIC: addressing-mode-3 ( addressing-mode -- n )

: b>n/n ( b -- n n ) dup -4 shift swap HEX: f bitand ;

M: addressing addressing-mode-3
    [ addressing-p ] keep
    [ addressing-u ] keep
    [ addressing-w ] keep
    delegate addressing-mode-3
    { 0 21 23 24 } bitfield ;

M: integer addressing-mode-3
    b>n/n {
        ! { 1 24 }
        { 1 22 }
        { 1 7 }
        { 1 4 }
        0
        8
    } bitfield ;

M: object addressing-mode-3
    shifter-op {
        ! { 1 24 }
        { 1 7 }
        { 1 4 }
        0
    } bitfield ;

: addr3 ( Rn Rd addressing-mode h l s -- )
    {
        6
        20
        5
        { addressing-mode-3 0 }
        { register 16 }
        { register 12 }
    } insn ;

: LDRH 1 1 0 addr3 ;
: LDRSB 0 1 1 addr3 ;
: LDRSH 1 1 1 addr3 ;
: STRH 1 0 0 addr3 ;
