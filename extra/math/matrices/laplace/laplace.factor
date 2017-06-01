! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays fry kernel locals math math.matrices
math.vectors sequences sequences.private ;
IN: math.matrices.laplace

<PRIVATE

: 2x2-determinant ( matrix -- x )
    first2 [ first2 ] bi@ -rot [ * ] 2bi@ - ;

! using a virtual "missing element" sequence for performance
TUPLE: missing seq i ;
C: <missing> missing
M: missing nth-unsafe
    [ i>> dupd >= [ 1 + ] when ] [ seq>> nth-unsafe ] bi ;
M: missing length seq>> length 1 - ;
INSTANCE: missing immutable-sequence

: first-sub-matrix ( matrix -- first-row seq )
    [ unclip-slice swap ] [ length <iota> ] bi
    [ '[ _ <missing> ] map ] with map ;

:: laplace-expansion ( row matrix -- x )
    matrix length 2 =
    [ matrix 2x2-determinant ] [
        matrix first-sub-matrix ! cheat, always expand on first row
        [ row swap laplace-expansion ] map
        v* [ odd? [ neg ] when ] map-index sum
    ] if ;

ERROR: not-a-square-matrix matrix ;

: check-square-matrix ( matrix -- matrix )
    dup square-matrix? [ not-a-square-matrix ] unless ; inline

PRIVATE>

: determinant ( matrix -- x )
    check-square-matrix 0 swap laplace-expansion ;
