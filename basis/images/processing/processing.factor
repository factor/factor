! Copyright (C) 2009 Marc Fauconneau.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays images kernel math
math.order math.vectors sequences sequences.deep ;
IN: images.processing

: coord-matrix ( dim -- m )
    [ <iota> ] map first2 cartesian-product ;

: map^2 ( m quot -- m' ) '[ _ map ] map ; inline
: each^2 ( m quot -- m' ) '[ _ each ] each ; inline

: matrix-dim ( m -- dim ) [ length ] [ first length ] bi 2array ;

: matrix>image ( m -- image )
    <image> over matrix-dim >>dim
    swap flip flatten
    [ 128 * 128 + 0 255 clamp >fixnum ] map
    >byte-array >>bitmap L >>component-order ubyte-components >>component-type ;

:: matrix-zoom ( m f -- m' )
    m matrix-dim f v*n coord-matrix
    [ [ f /i ] map first2 swap m nth nth ] map^2 ;

:: image-offset ( x,y image -- xy )
    image dim>> first
    x,y second * x,y first + ;

:: draw-grey ( value x,y image -- )
    x,y image image-offset 3 * { 0 1 2 }
    [
        + value 128 + >fixnum 0 255 clamp swap image bitmap>> set-nth
    ] with each ;

:: draw-color ( value x,y color-id image -- )
    x,y image image-offset 3 * color-id + value >fixnum
    swap image bitmap>> set-nth ;

! : matrix. ( m -- ) 10 matrix-zoom matrix>image image. ;
