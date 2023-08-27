! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays fry grouping images kernel locals math
math.vectors sequences ;
IN: images.tessellation

: group-rows ( bitmap bitmap-dim -- rows )
    first <groups> ; inline

: tesselate-rows ( bitmap-rows tess-dim -- bitmaps )
    second <groups> ; inline

: tesselate-columns ( bitmap-rows tess-dim -- bitmaps )
    first '[ _ <groups> ] map flip ; inline

: tesselate-bitmap ( bitmap bitmap-dim tess-dim -- bitmap-grid )
    [ group-rows ] dip
    [ tesselate-rows ] keep
    '[ _ tesselate-columns ] map ;

: tile-width ( tile-bitmap original-image -- width )
    [ first length ] [ bytes-per-pixel ] bi* /i ;

: <tile-image> ( tile-bitmap original-image -- tile-image )
    clone
        swap
        [ concat >>bitmap ]
        [ [ over tile-width ] [ length ] bi 2array >>dim ] bi ;

:: tesselate ( image tess-dim -- image-grid )
    image bytes-per-pixel :> bpp
    image dim>> { bpp 1 } v* :> image-dim'
    tess-dim { bpp 1 } v* :> tess-dim'
    image bitmap>> image-dim' tess-dim' tesselate-bitmap
    [ [ image <tile-image> ] map ] map ;
