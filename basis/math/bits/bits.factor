! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel math accessors sequences.private ;
IN: math.bits

TUPLE: bits { number read-only } { length read-only } ;
C: <bits> bits

: check-negative-bits ( n -- n )
    dup 0 < [ non-negative-integer-expected ] when ; inline

: make-bits ( number -- bits )
    check-negative-bits
    [ T{ bits f 0 0 } ] [ dup abs log2 1 + <bits> ] if-zero ; inline

M: bits length length>> ; inline

M: bits nth-unsafe number>> swap bit? ; inline

INSTANCE: bits immutable-sequence

: bits>number ( seq -- number )
    <reversed> 0 [ [ 1 shift ] dip [ 1 + ] when ] reduce ;
