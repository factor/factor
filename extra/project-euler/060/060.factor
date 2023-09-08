! Copyright (C) 2018 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license
USING: backtrack backtrack.private combinators.short-circuit
kernel math math.functions math.primes
project-euler.common sequences ;
IN: project-euler.060

! https://projecteuler.net/problem=60

! DESCRIPTION
! -----------

! The primes 3, 7, 109, and 673, are quite remarkable. By taking
! any two primes and concatenating them in any order the result
! will always be prime. For example, taking 7 and 109, both 7109
! and 1097 are prime. The sum of these four primes, 792,
! represents the lowest sum for a set of four primes with this
! property.

! Find the lowest sum for a set of five primes for which any two
! primes concatenate to produce another prime.


! SOLUTION
! --------

: join-numbers ( m n -- x )
    over log10 ceiling >integer 10^ * + ;

: prime-pair? ( m n -- ? )
    {
        [ join-numbers prime? ]
        [ swap join-numbers prime? ]
    } 2&& ;

:: (euler060) ( -- primes )
    [
        1/0. :> result!
        10000 primes-upto :> primes1

        primes1 amb-integer :> i
        i primes1 nth :> a
        primes1 i 1 + tail-slice [
            { [ 4 * a + result < ] [ a prime-pair? ] } 1&&
        ] filter :> primes2

        primes2 amb-integer :> j
        j primes2 nth :> b
        primes2 j 1 + tail-slice [
            { [ 3 * a b + + result < ] [ b prime-pair? ] } 1&&
        ] filter :> primes3

        primes3 amb-integer :> k
        k primes3 nth :> c
        primes3 k 1 + tail-slice [
            { [ 2 * a b c + + + result < ] [ c prime-pair? ] } 1&&
        ] filter :> primes4

        primes4 amb-integer :> l
        l primes4 nth :> d
        primes4 l 1 + tail-slice [
            { [ a b c d + + + + result < ] [ d prime-pair? ] } 1&&
        ] filter :> primes5

        primes5 amb-lazy :> e

        { a b c d e } dup sum result!
    ] bag-of last ;

: euler060 ( -- answer )
    (euler060) sum ;

SOLUTION: euler060
