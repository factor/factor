! Copyright (c) 2007 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: math.primes.factors sequences project-euler.common ;
IN: project-euler.003

! https://projecteuler.net/problem=3

! DESCRIPTION
! -----------

! The prime factors of 13195 are 5, 7, 13 and 29.

! What is the largest prime factor of the number 600851475143 ?


! SOLUTION
! --------

: euler003 ( -- answer )
    600851475143 factors supremum ;

! [ euler003 ] 100 ave-time
! 1 ms ave run time - 0.49 SD (100 trials)

SOLUTION: euler003
