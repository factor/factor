! Copyright (C) 2008 Matthew Willis.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors cairo cairo.ffi destructors kernel libc math
namespaces opengl.gl sequences ui.gadgets ui.render ;
IN: cairo-gadgets

SYMBOL: current-cairo

: cr ( -- cairo )
    current-cairo get ;

<PRIVATE

: width>stride ( width -- stride ) 4 * ;

: image-dims ( gadget -- width height stride )
    dim>> first2 over width>stride ; inline

: image-buffer ( width height stride -- alien )
    * nip malloc &free ; inline

: with-cairo ( cairo quot -- )
    [ &cairo_destroy current-cairo ] dip
    '[ @ current-cairo get check-cairo ] with-variable ; inline

: with-surface ( cairo_surface quot -- alien )
    [ &cairo_surface_destroy ] dip [ check-surface ] bi ; inline

: with-cairo-from-surface ( cairo_surface quot -- )
    '[ cairo_create _ with-cairo ] with-surface ; inline

PRIVATE>

GENERIC: render-cairo* ( gadget -- )

: render-cairo ( gadget -- alien )
    [
        image-dims
        [ image-buffer dup CAIRO_FORMAT_ARGB32 ]
        [ cairo_image_surface_create_for_data ] 3bi
    ] [ '[ _ render-cairo* ] with-cairo-from-surface ] bi ;

TUPLE: cairo-gadget < gadget ;

: <cairo-gadget> ( dim -- gadget )
    cairo-gadget new
        swap >>dim ;

M: cairo-gadget draw-gadget*
    [
        [ dim>> ] [ render-cairo ] bi
        0 0 glRasterPos2i
        1.0 -1.0 glPixelZoom
        [ first2 GL_BGRA GL_UNSIGNED_BYTE ] dip
        glDrawPixels
    ] with-destructors ;

: copy-surface ( surface -- )
    cr swap 0 0 cairo_set_source_surface
    cr cairo_paint ;
