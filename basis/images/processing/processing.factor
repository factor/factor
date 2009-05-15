! Copyright (C) 2009 Marc Fauconneau.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays combinators grouping images
kernel locals math math.order
math.ranges math.vectors sequences sequences.deep fry ;
IN: images.processing

: coord-matrix ( dim -- m )
    [ [0,b) ] map first2 [ [ 2array ] with map ] curry map ;

: map^2 ( m quot -- m' ) '[ _ map ] map ; inline
: each^2 ( m quot -- m' ) '[ _ each ] each ; inline

: matrix-dim ( m -- dim ) [ length ] [ first length ] bi 2array ;
    
: matrix>image ( m -- image )
    <image> over matrix-dim >>dim
    swap flip flatten
    [ 128 * 128 + 0 max 255 min  >fixnum ] map
    >byte-array >>bitmap L >>component-order ;

:: matrix-zoom ( m f -- m' )
    m matrix-dim f v*n coord-matrix
    [ [ f /i ] map first2 swap m nth nth ] map^2 ;

:: image-offset ( x,y image -- xy )
    image dim>> first
    x,y second * x,y first + ;
        
:: draw-grey ( value x,y image -- )
    x,y image image-offset 3 * { 0 1 2 }
    [
        + value 128 + >fixnum 0 max 255 min swap image bitmap>> set-nth
    ] with each ;

:: draw-color ( value x,y color-id image -- )
    x,y image image-offset 3 * color-id + value >fixnum
    swap image bitmap>> set-nth ;

! : matrix. ( m -- ) 10 matrix-zoom matrix>image image. ;
