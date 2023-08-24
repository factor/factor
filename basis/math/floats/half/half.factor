! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.c-types combinators
kernel math ;
FROM: math => float ;
IN: math.floats.half

: half>bits ( float -- bits )
    float>bits
    [ -16 shift 0x8000 bitand ] keep
    [ 0x7fffff bitand ] keep
    -23 shift 0xff bitand 127 - {
        { [ dup -24 < ] [ 2drop 0 ] }
        { [ dup -14 < ] [ [ 1 + shift ] [ 24 + 2^ ] bi bitor ] }
        { [ dup 15 <= ] [ [ -13 shift ] [ 15 + 10 shift ] bi* bitor ] }
        { [ dup 128 < ] [ 2drop 0x7c00 ] }
        [ drop -13 shift 0x7c00 bitor ]
    } cond bitor ;

: bits>half ( bits -- float )
    [ -15 shift 31 shift ] [
        0x7fff bitand
        dup zero? [
            dup 0x7c00 >= [ 13 shift 0x7f800000 bitor ] [
                dup 0x0400 < [
                    dup log2
                    [ nip 103 + 23 shift ]
                    [ 23 swap - shift 0x7fffff bitand ] 2bi bitor
                ] [
                    13 shift
                    112 23 shift +
                ] if
            ] if
        ] unless
    ] bi bitor bits>float ;

SYMBOL: half

<<

<c-type>
    float >>class
    float >>boxed-class
    [ alien-unsigned-2 bits>half ] >>getter
    [ [ >float half>bits ] 2dip set-alien-unsigned-2 ] >>setter
    2 >>size
    2 >>align
    2 >>align-first
    [ >float ] >>unboxer-quot
\ half typedef

>>
