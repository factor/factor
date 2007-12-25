! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math.combinatorics math.parser sequences ;
IN: project-euler.020

! http://projecteuler.net/index.php?section=problems&id=20

! DESCRIPTION
! -----------

! n! means n * (n - 1) * ... * 3 * 2 * 1

! Find the sum of the digits in the number 100!


! SOLUTION
! --------

: euler020 ( -- answer )
    100 factorial number>string string>digits sum ;

! [ euler020 ] 100 ave-time
! 0 ms run / 0 ms GC ave time - 100 trials

MAIN: euler020
