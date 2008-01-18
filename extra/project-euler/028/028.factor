! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.lib kernel math math.ranges ;
IN: project-euler.028

! http://projecteuler.net/index.php?section=problems&id=28

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

! Noticed patterns in the diagnoal numbers starting from the origin going to
! the corners and used these instead of generating the entire spiral:
!     ne -> (2n + 1)²                from 0 .. n
!     se -> (4 * n²) - (10 * n) + 7  from 1 .. n
!     sw -> (4 * n²) + 1             from 0 .. n
!     nw -> (4 * n²) - (6 * n) + 3   from 1 .. n

<PRIVATE

: ne ( m -- n )
    2 * 1+ sq ;

: se ( m -- n )
    [ sq 4 * ] keep 10 * - 7 + ;

: sw ( m -- n )
    sq 4 * 1+ ;

: nw ( m -- n )
    [ sq 4 * ] keep 6 * - 3 + ;

: spiral-diags ( n -- sum )
    1+ 2 / [ [ ne ] sigma ] keep [ [ sw ] sigma ] keep
    [1,b] [ [ se ] sigma ] keep [ nw ] sigma 3 - [ + ] 3apply ;

PRIVATE>

: euler028 ( -- answer )
    1001 spiral-diags ;

! [ euler027 ] 100 ave-time
! 0 ms run / 0 ms GC ave time - 100 trials

MAIN: euler028
