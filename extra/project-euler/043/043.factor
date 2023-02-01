! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit kernel math math.functions math.combinatorics
    ranges project-euler.common sequences sets sorting ;
IN: project-euler.043

! https://projecteuler.net/index.php?section=problems&id=43

! DESCRIPTION
! -----------

! The number, 1406357289, is a 0 to 9 pandigital number because it is made up
! of each of the digits 0 to 9 in some order, but it also has a rather
! interesting sub-string divisibility property.

! Let d1 be the 1st digit, d2 be the 2nd digit, and so on. In this way, we note
! the following:

!     * d2d3d4  = 406 is divisible by 2
!     * d3d4d5  = 063 is divisible by 3
!     * d4d5d6  = 635 is divisible by 5
!     * d5d6d7  = 357 is divisible by 7
!     * d6d7d8  = 572 is divisible by 11
!     * d7d8d9  = 728 is divisible by 13
!     * d8d9d10 = 289 is divisible by 17

! Find the sum of all 0 to 9 pandigital numbers with this property.


! SOLUTION
! --------

! Brute force generating all the pandigitals then checking 3-digit divisiblity
! properties...this is very slow!

<PRIVATE

: subseq-divisible? ( n index seq -- ? )
    [ 1 - dup 3 + ] dip subseq digits>number swap divisor? ;

: interesting? ( seq -- ? )
    {
        [ [ 17 8 ] dip subseq-divisible? ]
        [ [ 13 7 ] dip subseq-divisible? ]
        [ [ 11 6 ] dip subseq-divisible? ]
        [ [ 7  5 ] dip subseq-divisible? ]
        [ [ 5  4 ] dip subseq-divisible? ]
        [ [ 3  3 ] dip subseq-divisible? ]
        [ [ 2  2 ] dip subseq-divisible? ]
    } 1&& ;

PRIVATE>

: euler043 ( -- answer )
    1234567890 number>digits 0 [
        dup interesting? [
            digits>number +
        ] [ drop ] if
    ] reduce-permutations ;

! [ euler043 ] time
! 60280 ms run / 59 ms GC time


! ALTERNATE SOLUTIONS
! -------------------

! Build the number from right to left, generating the next 3-digits according
! to the divisiblity rules and combining them with the previous digits if they
! overlap and still have all unique digits. When done with that, add whatever
! missing digit is needed to make the number pandigital.

<PRIVATE

: candidates ( n -- seq )
    1000 over <range> [ number>digits 3 0 pad-head ] map [ all-unique? ] filter ;

: overlap? ( seq -- ? )
    [ first 2 tail* ] [ second 2 head ] bi = ;

: clean ( seq -- seq )
    [ unclip 1 head prefix concat ] map [ all-unique? ] filter ;

: add-missing-digit ( seq -- seq )
    dup sort 10 <iota> swap diff prepend ;

: interesting-pandigitals ( -- seq )
    17 candidates { 13 11 7 5 3 2 } [
        candidates swap cartesian-product concat
        [ overlap? ] filter clean
    ] each [ add-missing-digit ] map ;

PRIVATE>

: euler043a ( -- answer )
    interesting-pandigitals [ digits>number ] map-sum ;

! [ euler043a ] 100 ave-time
! 10 ms ave run time - 1.37 SD (100 trials)

SOLUTION: euler043a
