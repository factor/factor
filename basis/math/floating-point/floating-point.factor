! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math sequences prettyprint math.parser io
math.functions math.bitwise combinators.short-circuit ;
IN: math.floating-point

: (double-sign) ( bits -- n ) -63 shift ; inline
: double-sign ( double -- n ) double>bits (double-sign) ;

: (double-exponent-bits) ( bits -- n )
    -52 shift 11 on-bits mask ; inline

: double-exponent-bits ( double -- n )
    double>bits (double-exponent-bits) ;

: (double-mantissa-bits) ( double -- n )
    52 on-bits mask ;

: double-mantissa-bits ( double -- n )
    double>bits (double-mantissa-bits) ;

: >double ( S E M -- frac )
    [ 52 shift ] dip
    [ 63 shift ] 2dip bitor bitor bits>double ;

: >double< ( double -- S E M )
    double>bits
    [ (double-sign) ]
    [ (double-exponent-bits) ]
    [ (double-mantissa-bits) ] tri ;

: double. ( double -- )
    double>bits
    [ (double-sign) >bin print ]
    [ (double-exponent-bits) >bin 11 CHAR: 0 pad-head bl print ]
    [
        (double-mantissa-bits) >bin 52 CHAR: 0 pad-head
        12 [ bl ] times print
    ] tri ;

: infinity? ( double -- ? )
    double>bits
    {
        [ (double-exponent-bits) 11 on-bits = ]
        [ (double-mantissa-bits) 0 = ]
    } 1&& ;

: check-special ( n -- n )
    dup fp-special? [ "cannot be special" throw ] when ;

: double>ratio ( double -- a/b )
    check-special double>bits
    [ (double-sign) zero? 1 -1 ? ]
    [ (double-mantissa-bits) 52 2^ / ]
    [ (double-exponent-bits) ] tri
    [ 1 ] [ [ 1 + ] dip ] if-zero 1023 - 2 swap ^ * * ;
