! Copyright (c) 2007 Aaron Schaefer, Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: math.primes sequences ;
IN: project-euler.010

! http://projecteuler.net/index.php?section=problems&id=10

! DESCRIPTION
! -----------

! The sum of the primes below 10 is 2 + 3 + 5 + 7 = 17.

! Find the sum of all the primes below two million.


! SOLUTION
! --------

: euler010 ( -- answer )
    2000000 primes-upto sum ;

! [ euler010 ] time
! 266425 ms run / 10001 ms GC time

! TODO: this takes well over one minute now that they changed the problem to
! two million instead of one. the primes vocab could use some improvements

MAIN: euler010
