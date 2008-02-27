! Copyright (c) 2007 Samuel Tardieu, Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar combinators kernel math math.ranges namespaces sequences
    sequences.lib ;
IN: project-euler.019

! http://projecteuler.net/index.php?section=problems&id=19

! DESCRIPTION
! -----------

! You are given the following information, but you may prefer to do some
! research for yourself.

!     * 1 Jan 1900 was a Monday.
!     * Thirty days has September, April, June and November.  All the rest have
!       thirty-one, Saving February alone, Which has twenty-eight, rain or
!       shine.  And on leap years, twenty-nine.
!     * A leap year occurs on any year evenly divisible by 4, but not on a
!       century unless it is divisible by 400.

! How many Sundays fell on the first of the month during the twentieth century
! (1 Jan 1901 to 31 Dec 2000)?


! SOLUTION
! --------

! Use Zeller congruence, which is implemented in the "calendar" module
! already, as "zeller-congruence ( year month day -- n )" where n is
! the day of the week (Sunday is 0).

: euler019 ( -- answer )
    1901 2000 [a,b] [
        12 [1,b] [ 1 zeller-congruence ] map-with
    ] map concat [ zero? ] count ;

! [ euler019 ] 100 ave-time
! 1 ms run / 0 ms GC ave time - 100 trials


! ALTERNATE SOLUTIONS
! -------------------

<PRIVATE

: start-date ( -- timestamp )
    1901 1 1 0 0 0 0 <timestamp> ;

: end-date ( -- timestamp )
    2000 12 31 0 0 0 0 <timestamp> ;

: (first-days) ( end-date start-date -- )
    2dup time- 0 >= [
        dup day-of-week , 1 months time+ (first-days)
    ] [
        2drop
    ] if ;

: first-days ( start-date end-date -- seq )
    [ swap (first-days) ] { } make ;

PRIVATE>

: euler019a ( -- answer )
    start-date end-date first-days [ zero? ] count ;

! [ euler019a ] 100 ave-time
! 131 ms run / 3 ms GC ave time - 100 trials

MAIN: euler019
