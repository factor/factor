! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
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
    [ (double-sign) .b ]
    [ (double-exponent-bits) >bin 11 CHAR: 0 pad-left bl print ]
    [
        (double-mantissa-bits) >bin 52 CHAR: 0 pad-left
        11 [ bl ] times print
    ] tri ;

: infinity? ( double -- ? )
    double>bits
    {
        [ (double-exponent-bits) 11 on-bits = ]
        [ (double-mantissa-bits) 0 = ]
    } 1&& ;
