! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: math math.functions project-euler.common ;
IN: project-euler.097

! https://projecteuler.net/problem=97

! DESCRIPTION
! -----------

! The first known prime found to exceed one million digits was
! discovered in 1999, and is a Mersenne prime of the form
! 2^6972593 − 1; it contains exactly 2,098,960 digits.
! Subsequently other Mersenne primes, of the form 2p − 1, have
! been found which contain more digits.

! However, in 2004 there was found a massive non-Mersenne prime
! which contains 2,357,207 digits: 28433 * 2^7830457 + 1.

! Find the last ten digits of this prime number.


! SOLUTION
! --------

: euler097 ( -- answer )
     2 7830457 10 10 ^ ^mod 28433 * 10 10 ^ mod 1 + ;

! [ euler097 ] 100 ave-time
! 0 ms ave run timen - 0.22 SD (100 trials)

SOLUTION: euler097
