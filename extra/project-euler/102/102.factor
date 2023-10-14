! Copyright (c) 2009 Guillaume Nargeot.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays grouping io.encodings.ascii io.files kernel math
math.parser sequences splitting project-euler.common ;
IN: project-euler.102

! https://projecteuler.net/problem=102

! DESCRIPTION
! -----------

! Three distinct points are plotted at random on a Cartesian
! plane, for which -1000 ≤ x, y ≤ 1000, such that a triangle is
! formed.

! Consider the following two triangles:

! A(-340,495), B(-153,-910), C(835,-947)
! X(-175,41), Y(-421,-714), Z(574,-645)

! It can be verified that triangle ABC contains the origin,
! whereas triangle XYZ does not.

! Using triangles.txt (right click and 'Save Link/Target
! As...'), a 27K text file containing the coordinates of one
! thousand "random" triangles, find the number of triangles for
! which the interior contains the origin.

! NOTE: The first two examples in the file represent the
! triangles in the example given above.


! SOLUTION
! --------

! A triangle of coordinates (x1, y1) (x2, y2) (x3, y3) contains
! the origin when (ab * bc > 0) and (bc * ca > 0) where:
! ab = x1 * (y2 - y1) - y1 * (x2 - x1)
! bc = x2 * (y3 - y2) - y2 * (x3 - x2)
! ca = x3 * (y1 - y3) - y3 * (x1 - x3)

<PRIVATE

: source-102 ( -- seq )
    "resource:extra/project-euler/102/triangles.txt"
    ascii file-lines [
        "," split [ string>number ] map 2 group
    ] map ;

: det ( coord coord -- n )
    dupd [ [ last ] bi@ - ] [ [ first ] bi@ - ] 2bi 2array
    [ [ first ] bi@ * ] [ [ last ] bi@ * ] 2bi - ;

: include-origin? ( coord-seq -- ? )
    dup first suffix 2 clump [ [ first ] [ last ] bi det ] map
    2 clump [ product 0 > ] all? ;

PRIVATE>

: euler102 ( -- answer )
    source-102 [ include-origin? ] count ;

! [ euler102 ] 100 ave-time
! 12 ms ave run time - 0.92 SD (100 trials)

SOLUTION: euler102
