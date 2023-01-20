! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: io kernel math.functions math.parser ranges sequences ;
IN: rosetta-code.fizzbuzz

: fizz ( n -- str ) 3 divisor? "Fizz" "" ? ;

: buzz ( n -- str ) 5 divisor? "Buzz" "" ? ;

: fizzbuzz ( n -- str )
    dup [ fizz ] [ buzz ] bi append [ number>string ] [ nip ] if-empty ;

: fizzbuzz-main ( -- )
    100 [1..b] [ fizzbuzz print ] each ;

MAIN: fizzbuzz-main
