! Copyright (c) 2007 Samuel Tardieu, Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: io.files math.parser project-euler.common
io.encodings.ascii sequences splitting ;
IN: project-euler.067

! https://projecteuler.net/index.php?section=problems&id=67

! DESCRIPTION
! -----------

! By starting at the top of the triangle below and moving to adjacent numbers
! on the row below, the maximum total from top to bottom is 23.

!        3
!       7 5
!      2 4 6
!     8 5 9 3

! That is, 3 + 7 + 4 + 9 = 23.

! Find the maximum total from top to bottom in triangle.txt (right click and
! 'Save Link/Target As...'), a 15K text file containing a triangle with
! one-hundred rows.

! NOTE: This is a much more difficult version of Problem 18. It is not possible
! to try every route to solve this problem, as there are 2^99 altogether! If you
! could check one trillion (10^12) routes every second it would take over twenty
! billion years to check them all. There is an efficient algorithm to solve it. ;o)


! SOLUTION
! --------

! Propagate from bottom to top the longest cumulative path as is done in
! problem 18.

<PRIVATE

: source-067 ( -- seq )
    "resource:extra/project-euler/067/triangle.txt"
    ascii file-lines [ split-words [ string>number ] map ] map ;

PRIVATE>

: euler067 ( -- answer )
    source-067 propagate-all first first ;

! [ euler067 ] 100 ave-time
! 20 ms ave run time - 2.12 SD (100 trials)


! ALTERNATE SOLUTIONS
! -------------------

: euler067a ( -- answer )
    source-067 max-path ;

! [ euler067a ] 100 ave-time
! 21 ms ave run time - 2.65 SD (100 trials)

SOLUTION: euler067a
