! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: combinators.short-circuit grouping kernel math
math.primes sequences ;

IN: math.primes.twins

: twin-primes-upto ( n -- seq )
    primes-upto 2 clump [ first2 - abs 2 = ] filter ;

: twin-primes? ( x y -- ? )
    { [ - abs 2 = ] [ nip prime? ] [ drop prime? ] } 2&& ;
