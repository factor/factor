! Copyright (c) 2007 Aaron Schaefer, Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel lazy-lists math math.erato math.functions math.ranges
       namespaces sequences ;
IN: project-euler.010

! http://projecteuler.net/index.php?section=problems&id=10

! DESCRIPTION
! -----------

! The sum of the primes below 10 is 2 + 3 + 5 + 7 = 17.

! Find the sum of all the primes below one million.


! SOLUTION
! --------

! Sieve of Eratosthenes and lazy summing

: euler010 ( -- answer )
    0 1000000 lerato [ + ] leach ;

! [ euler010 ] time
! 765 ms run / 7 ms GC time

MAIN: euler010
