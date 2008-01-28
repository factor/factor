! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: math math.functions sequences ;
IN: project-euler.005

! http://projecteuler.net/index.php?section=problems&id=5

! DESCRIPTION
! -----------

! 2520 is the smallest number that can be divided by each of the numbers from 1
! to 10 without any remainder.

! What is the smallest number that is evenly divisible by all of the numbers from 1 to 20?


! SOLUTION
! --------

: euler005 ( -- answer )
    20 1 [ 1+ lcm ] reduce ;

! [ euler005 ] 100 ave-time
! 0 ms run / 0 ms GC ave time - 100 trials

MAIN: euler005
