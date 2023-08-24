! Copyright (c) 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math ranges sequences project-euler.common ;
IN: project-euler.028

! https://projecteuler.net/index.php?section=problems&id=28

! DESCRIPTION
! -----------

! Starting with the number 1 and moving to the right in a clockwise direction a
! 5 by 5 spiral is formed as follows:

!     21 22 23 24 25
!     20  7  8  9 10
!     19  6  1  2 11
!     18  5  4  3 12
!     17 16 15 14 13

! It can be verified that the sum of both diagonals is 101.

! What is the sum of both diagonals in a 1001 by 1001 spiral formed in the same way?


! SOLUTION
! --------

! For a square sized n by n, the sum of corners is 4n² - 6n + 6

<PRIVATE

: sum-corners ( n -- sum )
    dup 1 = [ [ sq 4 * ] [ 6 * ] bi - 6 + ] unless ;

: sum-diags ( n -- sum )
    1 swap 2 <range> [ sum-corners ] map-sum ;

PRIVATE>

: euler028 ( -- answer )
    1001 sum-diags ;

! [ euler028 ] 100 ave-time
! 0 ms ave run time - 0.39 SD (100 trials)

SOLUTION: euler028
