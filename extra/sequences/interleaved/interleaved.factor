! Copyright (C) 2018 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors kernel math math.order sequences
sequences.private ;

IN: sequences.interleaved

TUPLE: interleaved { seq read-only } { elt read-only } ;

C: <interleaved> interleaved

M: interleaved length seq>> length dup 1 - + 0 max ;

M: interleaved nth-unsafe
    over even? [
        [ 2/ ] [ seq>> ] bi* nth-unsafe
    ] [
        nip elt>>
    ] if ;

M: interleaved like seq>> like ;

M: interleaved new-sequence seq>> new-sequence ;

INSTANCE: interleaved immutable-sequence
