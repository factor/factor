! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit kernel math.parser ranges
project-euler.common sequences ;
IN: project-euler.036

! https://projecteuler.net/problem=36

! DESCRIPTION
! -----------

! The decimal number, 585 = 1001001001 (binary), is palindromic
! in both bases.

! Find the sum of all numbers, less than one million, which are
! palindromic in base 10 and base 2.

! (Please note that the palindromic number, in either base, may
! not include leading zeros.)


! SOLUTION
! --------

! Only check odd numbers since the binary number must begin and
! end with 1

<PRIVATE

: both-bases? ( n -- ? )
    { [ palindrome? ] [ >bin dup reverse = ] } 1&& ;

PRIVATE>

: euler036 ( -- answer )
    1 1000000 2 <range> [ both-bases? ] filter sum ;

! [ euler036 ] 100 ave-time
! 1703 ms ave run time - 96.6 SD (100 trials)

SOLUTION: euler036
