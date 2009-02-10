! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators images.bitmap kernel math
math.functions namespaces opengl opengl.gl ui ui.gadgets
ui.gadgets.panes ui.render images.tiff sequences multiline
images.backend images io.pathnames strings ;
IN: images.viewer

TUPLE: image-gadget < gadget { image image } ;

GENERIC: draw-image ( image -- )

M: image-gadget pref-dim*
    image>>
    [ width>> ] [ height>> ] bi
    [ abs ] bi@ 2array ;

M: image-gadget draw-gadget* ( gadget -- )
    origin get [ image>> draw-image ] with-translation ;

: <image-gadget> ( image -- gadget )
    \ image-gadget new-gadget
        swap >>image ;

: bits>gl-params ( n -- gl-bgr gl-format )
    {
        { 32 [ GL_BGRA GL_UNSIGNED_BYTE ] }
        { 24 [ GL_BGR GL_UNSIGNED_BYTE ] }
        { 8 [ GL_BGR GL_UNSIGNED_BYTE ] }
        { 4 [ GL_BGR GL_UNSIGNED_BYTE ] }
    } case ;

M: bitmap-image draw-image ( bitmap -- )
    {
        [
            height>> dup 0 < [
                drop
                0 0 glRasterPos2i
                1.0 -1.0 glPixelZoom
            ] [
                0 swap abs glRasterPos2i
                1.0 1.0 glPixelZoom
            ] if
        ]
        [ width>> abs ]
        [ height>> abs ]
        [ depth>> bits>gl-params ]
        [ buffer>> ]
    } cleave glDrawPixels ;

: image-window ( path -- gadget )
    [ <image> <image-gadget> dup ] [ open-window ] bi ;

M: tiff-image draw-image ( tiff -- )
    0 0 glRasterPos2i 1.0 -1.0 glPixelZoom
    {
        [ height>> ]
        [ width>> ]
        [ depth>> bits>gl-params ]
        [ buffer>> ]
    } cleave glDrawPixels ;

GENERIC: image. ( image -- )

M: string image. ( image -- ) <image> <image-gadget> gadget. ;

M: pathname image. ( image -- ) <image> <image-gadget> gadget. ;

M: image image. ( image -- ) <image-gadget> gadget. ;
