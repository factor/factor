! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel math grouping fry columns locals accessors
images math math.vectors arrays ;
IN: images.tesselation

: group-rows ( bitmap bitmap-dim -- rows )
    first <sliced-groups> ; inline

: tesselate-rows ( bitmap-rows tess-dim -- bitmaps )
    second <sliced-groups> ; inline

: tesselate-columns ( bitmap-rows tess-dim -- bitmaps )
    first '[ _ <sliced-groups> ] map flip ; inline

: tesselate-bitmap ( bitmap bitmap-dim tess-dim -- bitmap-grid )
    [ group-rows ] dip
    [ tesselate-rows ] keep
    '[ _ tesselate-columns ] map ;

: tile-width ( tile-bitmap original-image -- width )
    [ first length ] [ component-order>> bytes-per-pixel ] bi* /i ;

: <tile-image> ( tile-bitmap original-image -- tile-image )
    clone
        swap
        [ concat >>bitmap ]
        [ [ over tile-width ] [ length ] bi 2array >>dim ] bi ;

:: tesselate ( image tess-dim -- image-grid )
    image component-order>> bytes-per-pixel :> bpp
    image dim>> { bpp 1 } v* :> image-dim'
    tess-dim { bpp 1 } v* :> tess-dim'
    image bitmap>> image-dim' tess-dim' tesselate-bitmap
    [ [ image <tile-image> ] map ] map ;