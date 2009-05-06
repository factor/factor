! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel math accessors sequences.private ;
IN: math.bits

TUPLE: bits { number read-only } { length read-only } ;
C: <bits> bits

: make-bits ( number -- bits )
    dup zero? [ drop T{ bits f 0 0 } ] [ dup abs log2 1 + <bits> ] if ; inline

M: bits length length>> ;

M: bits nth-unsafe number>> swap bit? ;

INSTANCE: bits immutable-sequence
