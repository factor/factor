! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors hash-sets kernel math sequences sets vectors ;

IN: benchmark.ant

! There is an ant which can walk around on a planar grid. The ant
! can move one space at a time left, right, up or down. That is,
! from (x, y) the ant can go to (x+1, y), (x-1, y), (x, y+1), and
! (x, y-1).
!
! Points where the sum of the digits of the x coordinate plus the
! sum of the digits of the y coordinate are greater than 25 are
! inaccessible to the ant.  For example, the point (59,79) is
! inaccessible because 5 + 9 + 7 + 9 = 30, which is greater than
! 25.
!
! How many points can the ant access if it starts at (1000, 1000),
! including (1000, 1000) itself?

: sum-digits ( n -- x )
    0 swap [ 10 /mod swap [ + ] dip ] until-zero ;

TUPLE: point x y ;
C: <point> point

! USE: alien.c-types
! USE: classes.struct
! STRUCT: point { x uint } { y uint } ;
! : <point> ( x y -- point ) point <struct-boa> ; inline

: walkable? ( point -- ? )
    [ x>> ] [ y>> ] bi [ sum-digits ] bi@ + 25 <= ; inline

:: ant-benchmark ( -- )
    200000 <hash-set> :> seen
    100000 <vector> :> stack
    0 :> total!

    1000 1000 <point> stack push

    [ stack empty? ] [
        stack pop :> p
        p seen ?adjoin [
            p walkable? [
                total 1 + total!
                p clone [ 1 + ] change-x stack push
                p clone [ 1 - ] change-x stack push
                p clone [ 1 + ] change-y stack push
                p clone [ 1 - ] change-y stack push
            ] when
        ] when
    ] until total 148848 assert= ;

MAIN: ant-benchmark
