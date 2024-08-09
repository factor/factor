! Copyright (C) 2024 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors kernel math math.bitwise random ;

IN: random.xorshift

TUPLE: xorshift seed ;

C: <xorshift> xorshift

M: xorshift random-32*
    [
        dup 13 shift 32 bits bitxor
        dup -17 shift 32 bits bitxor
        dup 5 shift 32 bits bitxor
        dup
    ] change-seed drop ;
