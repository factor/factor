! Copyright (C) 2015 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: bit-arrays kernel literals math math.functions
math.private ranges math.statistics sequences
sequences.private ;

IN: math.primes.erato.fast

<PRIVATE

CONSTANT: wheel-2-3-5-7 $[
    11 dup 210 + [a..b] [
        { 2 3 5 7 } [ divisor? ] with none?
    ] B{ } filter-as differences
]

:: each-prime ( ... upto sieve quot: ( ... n -- ... ) -- ... )
    11 upto integer>fixnum-strict '[ dup _ <= ] [
        wheel-2-3-5-7 [
            over dup 2/ sieve nth-unsafe [ drop ] quot if
            fixnum+fast
        ] each
    ] while drop ; inline

:: mark-multiples ( i upto sieve -- )
    i 2 fixnum*fast :> step
    i i fixnum*fast upto integer>fixnum-strict '[ dup _ <= ] [
        t over 2/ sieve set-nth-unsafe
        step fixnum+fast
    ] while drop ; inline

: sieve-bits ( n -- bits )
    210 /i 1 + 210 * 2/ 6 + ; inline

PRIVATE>

:: make-sieve ( n -- sieve )
    n sieve-bits <bit-array> :> sieve
    t 0 sieve set-nth
    t 4 sieve set-nth
    n sqrt >integer sieve
    [ n sieve mark-multiples ] each-prime
    sieve ; inline

:: sieve ( n -- primes )
    V{ 2 3 5 7 } clone :> primes
    n dup make-sieve [
        dup n <= [ primes push ] [ drop ] if
    ] each-prime primes ;

:: marked-prime? ( i sieve -- prime? )
    i dup even? [ 2 = ] [ 2/ sieve nth not ] if ;
