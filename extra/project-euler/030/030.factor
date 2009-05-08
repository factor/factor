! Copyright (c) 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions math.ranges project-euler.common sequences ;
IN: project-euler.030

! http://projecteuler.net/index.php?section=problems&id=30

! DESCRIPTION
! -----------

! Surprisingly there are only three numbers that can be written as the sum of
! fourth powers of their digits:

!     1634 = 1^4 + 6^4 + 3^4 + 4^4
!     8208 = 8^4 + 2^4 + 0^4 + 8^4
!     9474 = 9^4 + 4^4 + 7^4 + 4^4

!     As 1 = 1^4 is not a sum it is not included.

! The sum of these numbers is 1634 + 8208 + 9474 = 19316.

! Find the sum of all the numbers that can be written as the sum of fifth
! powers of their digits.


! SOLUTION
! --------

! if n is the number of digits
! n * 9^5 = 10^n  when n ≈ 5.513
! 10^5.513 ≈ 325537

<PRIVATE

: sum-fifth-powers ( n -- sum )
    number>digits [ 5 ^ ] sigma ;

PRIVATE>

: euler030 ( -- answer )
    325537 [0,b) [ dup sum-fifth-powers = ] filter sum 1- ;

! [ euler030 ] 100 ave-time
! 1700 ms ave run time - 64.84 SD (100 trials)

SOLUTION: euler030
