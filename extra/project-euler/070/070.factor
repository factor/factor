! Copyright (c) 2010 Aaron Schaefer. All rights reserved.
! The contents of this file are licensed under the Simplified BSD License
! A copy of the license is available at https://factorcode.org/license.txt
USING: arrays combinators.short-circuit kernel math math.combinatorics
math.functions math.primes project-euler.common sequences
sequences.extras ;
FROM: project-euler.common => permutations? ;
IN: project-euler.070

! https://projecteuler.net/index.php?section=problems&id=70

! DESCRIPTION
! -----------

! Euler's Totient function, φ(n) [sometimes called the phi function], is used
! to determine the number of positive numbers less than or equal to n which are
! relatively prime to n. For example, as 1, 2, 4, 5, 7, and 8, are all less
! than nine and relatively prime to nine, φ(9)=6. The number 1 is considered to
! be relatively prime to every positive number, so φ(1)=1.

! Interestingly, φ(87109)=79180, and it can be seen that 87109 is a permutation
! of 79180.

! Find the value of n, 1 < n < 10^(7), for which φ(n) is a permutation of n and
! the ratio n/φ(n) produces a minimum.


! SOLUTION
! --------

! For n/φ(n) to be minimised, φ(n) must be as close to n as possible; that is,
! we want to maximize φ(n). The minimal solution for n/φ(n) would be if n was
! prime giving n/(n-1) but since n-1 never is a permutation of n it cannot be
! prime.

! The next best thing would be if n only consisted of 2 prime factors close to
! (in this case) sqrt(10000000). Hence n = p1*p2 and we only need to search
! through a list of known prime pairs. In addition:

!     φ(p1*p2) = p1*p2*(1-1/p1)(1-1/p2) = (p1-1)(p2-1)

! ...so we can compute φ(n) more efficiently.

<PRIVATE

! NOTE: ±1000 is an arbitrary range
: likely-prime-factors ( -- seq )
    7 10^ sqrt >integer 1000 [ - ] [ + ] 2bi primes-between ; inline

: n-and-phi ( seq -- seq' )
    ! ( seq  = { p1, p2 } -- seq' = { n, φ(n) } )
    [ product ] [ [ 1 - ] map product ] bi 2array ;

: fit-requirements? ( seq -- ? )
    first2 { [ drop 7 10^ < ] [ permutations? ] } 2&& ;

: minimum-ratio ( seq -- n )
    [ [ first2 / ] map arg-min ] keep nth first ;

PRIVATE>

: euler070 ( -- answer )
    likely-prime-factors 2 all-combinations [ n-and-phi ] map
    [ fit-requirements? ] filter minimum-ratio ;

! [ euler070 ] 100 ave-time
! 379 ms ave run time - 1.15 SD (100 trials)

SOLUTION: euler070
