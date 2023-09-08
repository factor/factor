! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.parser math.primes sequences
project-euler.common ;
IN: project-euler.037

! https://projecteuler.net/problem=37

! DESCRIPTION
! -----------

! The number 3797 has an interesting property. Being prime
! itself, it is possible to continuously remove digits from left
! to right, and remain prime at each stage: 3797, 797, 97, and
! 7. Similarly we can work from right to left: 3797, 379, 37,
! and 3.

! Find the sum of the only eleven primes that are both
! truncatable from left to right and right to left.

! NOTE: 2, 3, 5, and 7 are not considered to be truncatable
! primes.


! SOLUTION
! --------

<PRIVATE

: r-trunc? ( n -- ? )
    10 /i dup 0 > [
        dup prime? [ r-trunc? ] [ drop f ] if
    ] [
        drop t
    ] if ;

: reverse-digits ( n -- m )
    number>string reverse string>number ;

: l-trunc? ( n -- ? )
    reverse-digits 10 /i reverse-digits dup 0 > [
        dup prime? [ l-trunc? ] [ drop f ] if
    ] [
        drop t
    ] if ;

PRIVATE>

: euler037 ( -- answer )
    23 1000000 primes-between [ r-trunc? ] filter [ l-trunc? ] filter sum ;

! [ euler037 ] 100 ave-time
! 130 ms ave run time - 6.27 SD (100 trials)

SOLUTION: euler037
