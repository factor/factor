! Copyright (c) 2009 Aaron Schaefer. All rights reserved.
! The contents of this file are licensed under the Simplified BSD License
! A copy of the license is available at https://factorcode.org/license.txt
USING: arrays formatting io kernel math math.matrices
math.parser sequences ;
IN: benchmark.pidigits

: extract ( z x -- n )
    [ first2 ] dip '[ first2 [ _ * ] [ + ] bi* ] bi@ /i ;

: next ( z -- n )
    3 extract ;

: safe? ( z n -- ? )
    [ 4 extract ] dip = ;

: >matrix ( q s r t -- z )
    [ 2array ] 2bi@ 2array ;

: produce ( z y -- z' )
    [ 10 ] dip -10 * 0 1 >matrix swap mdot ;

: gen-x ( x -- matrix )
    dup 2 * 1 + [ 2 * 0 ] keep >matrix ;

: consume ( z k -- z' )
    gen-x mdot ;

:: (padded-total) ( row col -- str n format )
    "" row col + "%" "s\t:%d\n"
    10 col - number>string glue ;

: padded-total ( row col -- )
    (padded-total) '[ _ printf ] call( str n -- ) ;

:: (pidigits) ( k z n row col -- )
    n 0 > [
        z next :> y
        z y safe? [
            col 10 = [
                row 10 + y "\t:%d\n%d" printf
                k z y produce n 1 - row 10 + 1 (pidigits)
            ] [
                y number>string write
                k z y produce n 1 - row col 1 + (pidigits)
            ] if
        ] [
            k 1 + z k consume n row col (pidigits)
        ] if
    ] [ row col padded-total ] if ;

: pidigits ( n -- )
    [ 1 { { 1 0 } { 0 1 } } ] dip 0 0 (pidigits) ;

: pidigits-benchmark ( -- )
    2000 pidigits ;

MAIN: pidigits-benchmark
