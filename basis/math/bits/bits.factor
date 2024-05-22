! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: sequences kernel math accessors sequences.private ;
IN: math.bits

TUPLE: bits { number read-only } { length read-only } ;
C: <bits> bits

: make-bits ( number -- bits )
    assert-non-negative
    [ T{ bits f 0 1 } ] [ dup abs log2 1 + <bits> ] if-zero ; inline

M: bits length length>> ; inline

M: bits nth-unsafe number>> swap bit? ; inline

INSTANCE: bits immutable-sequence

: bits>number ( seq -- number )
    <reversed> 0 [ [ 1 shift ] dip [ 1 + ] when ] reduce ;

TUPLE: binary-bits < bits ;

C: <binary-bits> binary-bits

M: binary-bits nth-unsafe call-next-method 1 0 ? ; inline

INSTANCE: binary-bits virtual-sequence

: make-binary-bits ( number -- binary-bits )
    assert-non-negative
    [ T{ binary-bits { number 0 } { length 1 } } ]
    [ dup abs log2 1 + <binary-bits> ] if-zero ; inline
