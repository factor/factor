! Copyright (C) 2014 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: combinators kernel math math.extras math.extras.private
math.functions ranges random sequences ;

IN: math.primes.solovay-strassen

<PRIVATE

:: (solovay-strassen) ( n numtrials -- ? )
    numtrials <iota> [
        drop
        n 1 - [1..b) random :> a
        a n simple-gcd 1 > [ t ] [
            a n jacobi n mod'
            a n 1 - 2 /i n ^mod = not
        ] if
    ] none? ;

PRIVATE>

: solovay-strassen* ( n numtrials -- ? )
    {
        { [ over 1 <= ] [ 2drop f ] }
        { [ over even? ] [ drop 2 = ] }
        [ (solovay-strassen) ]
    } cond ;

: solovay-strassen ( n -- ? ) 32 solovay-strassen* ;
