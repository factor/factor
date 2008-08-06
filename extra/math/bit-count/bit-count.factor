! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions quotations words sequences
sequences.private combinators fry ;
IN: math.bit-count

<PRIVATE

DEFER: byte-bit-count

<<

\ byte-bit-count
256 [
    0 swap [ [ 1+ ] when ] each-bit
] B{ } map-as '[ HEX: ff bitand , nth-unsafe ] define-inline

>>

GENERIC: (bit-count) ( x -- n )

M: fixnum (bit-count)
    {
        [           byte-bit-count ]
        [ -8  shift byte-bit-count ]
        [ -16 shift byte-bit-count ]
        [ -24 shift byte-bit-count ]
    } cleave + + + ;

M: bignum (bit-count)
    dup 0 = [ drop 0 ] [
        [ byte-bit-count ] [ -8 shift (bit-count) ] bi +
    ] if ;

PRIVATE>

: bit-count ( x -- n )
    dup 0 >= [ (bit-count) ] [ bitnot (bit-count) ] if ; inline
