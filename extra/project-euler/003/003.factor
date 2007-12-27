! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: math.primes.factors sequences ;
IN: project-euler.003

! http://projecteuler.net/index.php?section=problems&id=3

! DESCRIPTION
! -----------

! The prime factors of 13195 are 5, 7, 13 and 29.

! What is the largest prime factor of the number 317584931803?


! SOLUTION
! --------

: largest-prime-factor ( n -- factor )
  factors supremum ;

: euler003 ( -- answer )
  317584931803 largest-prime-factor ;

! [ euler003 ] time
! 2 ms run / 0 ms GC time

MAIN: euler003
