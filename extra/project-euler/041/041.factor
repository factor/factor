! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math.combinatorics math.primes sequences
project-euler.common ;
IN: project-euler.041

! https://projecteuler.net/problem=41

! DESCRIPTION
! -----------

! We shall say that an n-digit number is pandigital if it makes
! use of all the digits 1 to n exactly once. For example, 2143
! is a 4-digit pandigital and is also prime.

! What is the largest n-digit pandigital prime that exists?


! SOLUTION
! --------

! Check 7-digit pandigitals because if the sum of the digits in
! any number add up to a multiple of three, then it is a
! multiple of three and can't be prime. I assumed there would be
! a 7-digit answer, but technically a higher 4-digit pandigital
! than the one given in the description was also possible.

!     1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 = 45
!     1 + 2 + 3 + 4 + 5 + 6 + 7 + 8     = 36
!     1 + 2 + 3 + 4 + 5 + 6 + 7         = 28  *** not divisible by 3 ***
!     1 + 2 + 3 + 4 + 5 + 6             = 21
!     1 + 2 + 3 + 4 + 5                 = 15
!     1 + 2 + 3 + 4                     = 10  *** not divisible by 3 ***

: euler041 ( -- answer )
    { 7 6 5 4 3 2 1 } all-permutations
    [ digits>number ] map [ prime? ] find nip ;

! [ euler041 ] 100 ave-time
! 64 ms ave run time - 4.22 SD (100 trials)

SOLUTION: euler041
