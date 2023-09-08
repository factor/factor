! Copyright (c) 2009 Guillaume Nargeot.
! See https://factorcode.org/license.txt for BSD license.
USING: io.encodings.ascii io.files kernel math math.order
math.parser project-euler.common sequences splitting ;
IN: project-euler.081

! https://projecteuler.net/problem=81

! DESCRIPTION
! -----------

! In the 5 by 5 matrix below, the minimal path sum from the top
! left to the bottom right, by only moving to the right and
! down, is indicated in bold red and is equal to 2427.

! 131 673 234 103  18
! 201  96 342 965 150
! 630 803 746 422 111
! 537 699 497 121 956
! 805 732 524  37 331

! Find the minimal path sum, in matrix.txt (right click and
! 'Save Link/Target As...'), a 31K text file containing a 80 by
! 80 matrix, from the top left to the bottom right by only
! moving right and down.


! SOLUTION
! --------

! Shortest path problem solved using Dijkstra algorithm.

<PRIVATE

: source-081 ( -- matrix )
    "resource:extra/project-euler/081/matrix.txt"
    ascii file-lines [ "," split [ string>number ] map ] map ;

: get-matrix ( x y matrix -- n ) nth nth ;

: change-matrix ( x y matrix quot -- )
    [ nth ] dip change-nth ; inline

:: minimal-path-sum-to ( x y matrix -- n )
    x y + zero? [ 0 ] [
        x zero? [ 0 y 1 - matrix get-matrix
        ] [
            y zero? [
                x 1 - 0 matrix get-matrix
            ] [
                x 1 - y matrix get-matrix
                x y 1 - matrix get-matrix
                min
            ] if
        ] if
    ] if ;

: update-minimal-path-sum ( x y matrix -- )
    3dup minimal-path-sum-to '[ _ + ] change-matrix ;

: (euler081) ( matrix -- n )
    dup first length <iota> dup
    [ pick update-minimal-path-sum ] cartesian-each
    last last ;

PRIVATE>

: euler081 ( -- answer )
    source-081 (euler081) ;

! [ euler081 ] 100 ave-time
! 9 ms ave run time - 0.39 SD (100 trials)

SOLUTION: euler081
