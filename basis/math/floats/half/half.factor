! Copyright (C) 2009 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.c-types alien.data
alien.syntax kernel math math.order ;
FROM: math => float ;
IN: math.floats.half

: half>bits ( float -- bits )
    float>bits
    [ -31 shift 15 shift ] [
        0x7fffffff bitand
        dup zero? [
            dup 0x7f800000 >= [ -13 shift 0x7fff bitand ] [
                -13 shift
                112 10 shift -
                0 0x7c00 clamp
            ] if
        ] unless
    ] bi bitor ;

: bits>half ( bits -- float )
    [ -15 shift 31 shift ] [
        0x7fff bitand
        dup zero? [
            dup 0x7c00 >= [ 13 shift 0x7f800000 bitor ] [
                13 shift
                112 23 shift +
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
