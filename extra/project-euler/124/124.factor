! Copyright (c) 2009 Guillaume Nargeot.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel math.primes.factors ranges
project-euler.common sequences sorting ;
IN: project-euler.124

! https://projecteuler.net/problem=124

! DESCRIPTION
! -----------

! The radical of n, rad(n), is the product of distinct prime
! factors of n. For example, 504 = 2^3 × 3^2 × 7, so rad(504) =
! 2 × 3 × 7 = 42.

! If we calculate rad(n) for 1 ≤ n ≤ 10, then sort them on
! rad(n), and sorting on n if the radical values are equal, we
! get:

!   Unsorted          Sorted
!   n  rad(n)       n  rad(n) k
!   1    1          1    1    1
!   2    2          2    2    2
!   3    3          4    2    3
!   4    2          8    2    4
!   5    5          3    3    5
!   6    6          9    3    6
!   7    7          5    5    7
!   8    2          6    6    8
!   9    3          7    7    9
!  10   10         10   10   10

! Let E(k) be the kth element in the sorted n column; for
! example, E(4) = 8 and E(6) = 9.

! If rad(n) is sorted for 1 ≤ n ≤ 100000, find E(10000).


! SOLUTION
! --------

<PRIVATE

: rad ( n -- n )
    unique-factors product ; inline

: rads-upto ( n -- seq )
    [0..b] [ dup rad 2array ] map ;

: (euler124) ( -- seq )
    100000 rads-upto sort-values ;

PRIVATE>

: euler124 ( -- answer )
    10000 (euler124) nth first ;

! [ euler124 ] 100 ave-time
! 373 ms ave run time - 17.61 SD (100 trials)

! TODO: instead of the brute-force method, making the rad
! array in the way of the sieve of eratosthene would scale
! better on bigger values.

SOLUTION: euler124
