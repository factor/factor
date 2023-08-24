! Copyright (c) 2007 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: project-euler.common ;
IN: project-euler.007

! https://projecteuler.net/index.php?section=problems&id=7

! DESCRIPTION
! -----------

! By listing the first six prime numbers: 2, 3, 5, 7, 11, and 13, we can see
! that the 6th prime is 13.

! What is the 10001st prime number?


! SOLUTION
! --------

: euler007 ( -- answer )
    10001 nth-prime ;

! [ euler007 ] 100 ave-time
! 5 ms ave run time - 1.13 SD (100 trials)

SOLUTION: euler007
