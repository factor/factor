! Copyright (c) 2007 Aaron Schaefer, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators.lib hashtables kernel math math.parser math.ranges
    sequences sorting ;
IN: project-euler.004

! http://projecteuler.net/index.php?section=problems&id=4

! DESCRIPTION
! -----------

! A palindromic number reads the same both ways. The largest palindrome made
! from the product of two 2-digit numbers is 9009 = 91 * 99.

! Find the largest palindrome made from the product of two 3-digit numbers.


! SOLUTION
! --------

: palindrome? ( n -- ? )
    number>string dup reverse = ;

: cartesian-product ( seq1 seq2 -- seq1xseq2 )
    swap [ swap [ 2array ] map-with ] map-with concat ;

<PRIVATE

: source-004 ( -- seq )
    100 999 [a,b] [ 10 mod zero? not ] subset ;

: max-palindrome ( seq -- palindrome )
    natural-sort [ palindrome? ] find-last nip ;

PRIVATE>

: euler004 ( -- answer )
    source-004 dup cartesian-product [ product ] map prune max-palindrome ;

! [ euler004 ] 100 ave-time
! 1608 ms run / 102 ms GC ave time - 100 trials

MAIN: euler004
