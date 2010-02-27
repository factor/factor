! Copyright (c) 2007 Aaron Schaefer, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: hashtables kernel math math.functions math.ranges project-euler.common
    sequences sorting sets ;
IN: project-euler.004

! http://projecteuler.net/index.php?section=problems&id=4

! DESCRIPTION
! -----------

! A palindromic number reads the same both ways. The largest palindrome made
! from the product of two 2-digit numbers is 9009 = 91 * 99.

! Find the largest palindrome made from the product of two 3-digit numbers.


! SOLUTION
! --------

<PRIVATE

: source-004 ( -- seq )
    100 999 [a,b] [ 10 divisor? not ] filter ;

: max-palindrome ( seq -- palindrome )
    natural-sort [ palindrome? ] find-last nip ;

PRIVATE>

: euler004 ( -- answer )
    source-004 dup [ * ] cartesian-map combine max-palindrome ;

! [ euler004 ] 100 ave-time
! 1164 ms ave run time - 39.35 SD (100 trials)

SOLUTION: euler004
