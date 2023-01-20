! Copyright (c) 2007, 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: math.functions project-euler.common sequences ;
IN: project-euler.016

! https://projecteuler.net/index.php?section=problems&id=16

! DESCRIPTION
! -----------

! 2^15 = 32768 and the sum of its digits is 3 + 2 + 7 + 6 + 8 = 26.

! What is the sum of the digits of the number 2^1000?


! SOLUTION
! --------

: euler016 ( -- answer )
    2 1000 ^ number>digits sum ;

! [ euler016 ] 100 ave-time
! 0 ms ave run time - 0.67 SD (100 trials)

SOLUTION: euler016
