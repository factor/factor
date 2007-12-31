! Copyright (c) 2007 Aaron Schaefer, Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math.primes sequences ;
IN: project-euler.010

! http://projecteuler.net/index.php?section=problems&id=10

! DESCRIPTION
! -----------

! The sum of the primes below 10 is 2 + 3 + 5 + 7 = 17.

! Find the sum of all the primes below one million.


! SOLUTION
! --------

: euler010 ( -- answer )
    1000000 primes-upto sum ;

! [ euler010 ] 100 ave-time
! 14 ms run / 0 ms GC ave time - 100 trials

MAIN: euler010
