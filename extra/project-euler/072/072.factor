! Copyright (c) 2009 Guillaume Nargeot.
! See https://factorcode.org/license.txt for BSD license.
USING: math.primes.factors project-euler.common ranges sequences
;
IN: project-euler.072

! https://projecteuler.net/problem=72

! DESCRIPTION
! -----------

! Consider the fraction, n/d, where n and d are positive
! integers. If n<d and HCF(n,d)=1, it is called a reduced proper
! fraction.

! If we list the set of reduced proper fractions for d ≤ 8 in
! ascending order of size, we get:

! 1/8, 1/7, 1/6, 1/5, 1/4, 2/7, 1/3, 3/8, 2/5, 3/7, 1/2, 4/7,
! 3/5, 5/8, 2/3, 5/7, 3/4, 4/5, 5/6, 6/7, 7/8

! It can be seen that there are 21 elements in this set.

! How many elements would be contained in the set of reduced
! proper fractions for d ≤ 1,000,000?


! SOLUTION
! --------

! The answer can be found by adding totient(n) for 2 ≤ n ≤ 1e6

: euler072 ( -- answer )
    2 1000000 [a..b] [ totient ] map-sum ;

! [ euler072 ] 100 ave-time
! 5274 ms ave run time - 102.7 SD (100 trials)

SOLUTION: euler072
