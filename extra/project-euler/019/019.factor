! Copyright (c) 2007 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar combinators combinators.lib kernel math.ranges sequences ;
IN: project-euler.019

! http://projecteuler.net/index.php?section=problems&id=19

! DESCRIPTION
! -----------

! You are given the following information, but you may prefer to do some
! research for yourself.

!     * 1 Jan 1900 was a Monday.
!     * Thirty days has September,
!       April, June and November.
!       All the rest have thirty-one,
!       Saving February alone,
!       Which has twenty-eight, rain or shine.
!       And on leap years, twenty-nine.
!     * A leap year occurs on any year evenly divisible by 4, but not
!       on a century unless it is divisible by 400.

! How many Sundays fell on the first of the month during the twentieth
! century (1 Jan 1901 to 31 Dec 2000)?

! SOLUTION
! --------

! Use Zeller congruence, which is implemented in the "calendar" module
! already, as "zeller-congruence ( year month day -- n )" where n is
! the day of the week (Sunday is 0).

: euler019 ( -- count )
  1901 2000 [a,b] [ 12 [1,b] [ 1 zeller-congruence ] 1 map-withn ] map concat
  [ 0 = ] subset length ;

! [ euler019 ] 100 ave-time
! 1 ms run / 0 ms GC ave time - 100 trials

MAIN: euler019
