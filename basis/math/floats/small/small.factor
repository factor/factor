! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel locals math math.bitwise math.floating-point math.libm ;
IN: math.floats.small

<PRIVATE
! Integer rounding avoids double rounding through binary32 and is independent
! of the host floating-point rounding mode.
:: round-binary-shift ( n amount -- rounded )
    amount 0 >= [ n amount shift ] [
        amount neg :> discarded
        n discarded neg shift :> q
        n q discarded shift - :> remainder
        1 discarded 1 - shift :> midpoint
        remainder midpoint > remainder midpoint = q odd? and or
        [ q 1 + ] [ q ] if
    ] if ;

:: float>small-bits ( x fraction-bits exponent-bits -- bits )
    x >float double>bits :> raw
    raw -48 shift 0x8000 bitand :> sign
    raw -52 shift 0x7ff bitand :> exponent
    raw 52 bits :> fraction
    exponent-bits 2^ 1 - :> max-exponent
    exponent-bits 1 - 2^ 1 - :> bias
    exponent 0x7ff = [
        fraction zero? [ sign max-exponent fraction-bits shift bitor ]
        [ max-exponent fraction-bits shift 1 fraction-bits 1 - shift bitor ] if
    ] [
        exponent zero? [ fraction -1074 ] [ fraction 52 2^ bitor exponent 1075 - ] if
        :> ( significand power )
        significand zero? [ sign ] [
            significand log2 :> top
            top power + bias + :> target-exponent!
            target-exponent max-exponent >= [ sign max-exponent fraction-bits shift bitor ] [
                target-exponent 0 <= [
                    significand power bias + fraction-bits + 1 - round-binary-shift sign bitor
                ] [
                    significand fraction-bits top - round-binary-shift :> rounded!
                    rounded fraction-bits 1 + 2^ >= [
                        rounded -1 shift rounded!
                        target-exponent 1 + target-exponent!
                    ] when
                    target-exponent max-exponent >=
                    [ sign max-exponent fraction-bits shift bitor ]
                    [ sign target-exponent fraction-bits shift bitor rounded fraction-bits 2^ - bitor ] if
                ] if
            ] if
        ] if
    ] if ;

:: small-bits>float ( raw fraction-bits exponent-bits -- x )
    raw 0x8000 bitand 48 shift :> sign
    exponent-bits 2^ 1 - :> max-exponent
    raw fraction-bits neg shift max-exponent bitand :> exponent
    raw fraction-bits bits :> fraction
    exponent-bits 1 - 2^ 1 - :> bias
    exponent max-exponent = [
        fraction zero? [ sign 0x7ff0000000000000 bitor ] [ 0x7ff8000000000000 ] if bits>double
    ] [
        exponent zero? [ fraction 1 bias - fraction-bits - ]
        [ fraction fraction-bits 2^ bitor exponent bias - fraction-bits - ] if
        :> ( significand power )
        significand zero? [ sign bits>double ] [
            significand log2 :> top
            sign top power + 1023 + 52 shift bitor
            significand top 2^ - 52 top - shift bitor bits>double
        ] if
    ] if ;
PRIVATE>

: float>half-bits ( x -- bits ) 10 5 float>small-bits ;
: half-bits>float ( bits -- x ) 10 5 small-bits>float ;
: float>bfloat-bits ( x -- bits ) 7 8 float>small-bits ;
: bfloat-bits>float ( bits -- x ) 7 8 small-bits>float ;

<PRIVATE
:: scaled-integer>half ( n -- raw )
    n 0 < 0x8000 0 ? :> sign
    n abs :> magnitude
    magnitude zero? [ sign ] [
        magnitude log2 :> top
        top 33 - :> exponent!
        exponent 0 <= [ magnitude -24 round-binary-shift sign bitor ] [
            magnitude 10 top - round-binary-shift :> significand!
            significand 2048 >= [
                significand -1 shift significand!
                exponent 1 + exponent!
            ] when
            exponent 31 >= [ sign 0x7c00 bitor ]
            [ sign exponent 10 shift bitor significand 1024 - bitor ] if
        ] if
    ] if ;
PRIVATE>

! Finite half values are multiples of 2^-24. Compute the product and sum
! exactly as integers at scale 2^-48, then round once to binary16.
:: half-fma-value ( a b c -- d )
    a fp-special? b fp-special? or c fp-special? or
    [ a b c ffma ] [
        a double>ratio b double>ratio * c double>ratio + :> exact
        exact zero? [
            a double>bits b double>bits bitxor c double>bits bitand
            0x8000000000000000 bitand bits>double
        ]
        [ exact 48 2^ * >integer scaled-integer>half half-bits>float ] if
    ] if ;
