! Copyright (C) 2007-2009 Samuel Tardieu.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays combinators command-line io kernel math
math.functions math.parser math.primes.pollard-rho-brent
math.statistics namespaces ranges sequences sequences.product
sets sorting splitting ;
IN: math.primes.factors

: factors ( n -- seq ) pollard-rho-brent-factors ; flushable

: group-factors ( n -- seq ) factors histogram sort-keys ; flushable

: unique-factors ( n -- seq ) factors members ; flushable

: totient ( n -- t )
    {
        { [ dup 2 < ] [ drop 0 ] }
        [ dup unique-factors [ 1 [ 1 - * ] reduce ] [ product ] bi / * ]
    } cond ; foldable

: divisors ( n -- seq )
    dup 1 = [
        1array
    ] [
        group-factors dup empty? [
            [ first2 [0..b] [ ^ ] with map ] map
            [ product ] product-map sort
        ] unless
    ] if ;

: unix-factor ( string -- )
    dup string>number [
        [ ": " append write ]
        [ factors [ number>string ] map join-words print ] bi*
    ] [
        "factor: `" "' is not a valid positive integer" surround print
    ] if* flush ;

: run-unix-factor ( -- )
    command-line get [
        [ readln [ unix-factor t ] [ f ] if* ] loop
    ] [
        [ unix-factor ] each
    ] if-empty ;

MAIN: run-unix-factor
