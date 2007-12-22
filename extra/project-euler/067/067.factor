! Copyright (c) 2007 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.files math.parser project-euler.018 sequences splitting ;
IN: project-euler.067

! http://projecteuler.net/index.php?section=problems&id=67

! DESCRIPTION
! -----------

! By starting at the top of the triangle below and moving to adjacent
! numbers on the row below, the maximum total from top to bottom is
! 23.

! 3
! 7 5
! 2 4 6
! 8 5 9 3

! That is, 3 + 7 + 4 + 9 = 23.

! Find the maximum total from top to bottom in triangle.txt, a 15K
! text file containing a triangle with one-hundred rows.

! SOLUTION
! --------

! Propagate from bottom to top the longest cumulative path as is done in
! problem 18.

<PRIVATE

: pyramid ( -- seq )
  "resource:extra/project-euler/067/triangle.txt" ?resource-path <file-reader>
  lines [ " " split [ string>number ] map ] map ;

PRIVATE>

: euler067 ( -- best )
  pyramid propagate-all first first ;

! [ euler067 ] 100 ave-time
! 18 ms run / 0 ms GC time

MAIN: euler067
