! Copyright (c) 2007 Aaron Schaefer, Samuel Tardieu.
! See https://factorcode.org/license.txt for BSD license.
USING: math.primes sequences project-euler.common ;
IN: project-euler.010

! https://projecteuler.net/problem=10

! DESCRIPTION
! -----------

! The sum of the primes below 10 is 2 + 3 + 5 + 7 = 17.

! Find the sum of all the primes below two million.


! SOLUTION
! --------

: euler010 ( -- answer )
    2000000 primes-upto sum ;

! [ euler010 ] 100 ave-time
! 15 ms ave run time - 0.41 SD (100 trials)

SOLUTION: euler010
