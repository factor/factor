! Copyright (c) 2007, 2009 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: math.functions project-euler.common ranges sequences ;
IN: project-euler.005

! https://projecteuler.net/index.php?section=problems&id=5

! DESCRIPTION
! -----------

! 2520 is the smallest number that can be divided by each of the numbers from 1
! to 10 without any remainder.

! What is the smallest number that is evenly divisible by all of the numbers from 1 to 20?


! SOLUTION
! --------

: euler005 ( -- answer )
    20 [1..b] 1 [ lcm ] reduce ;

! [ euler005 ] 100 ave-time
! 0 ms ave run time - 0.14 SD (100 trials)

SOLUTION: euler005
