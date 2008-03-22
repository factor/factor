! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators.cleave kernel
accessors math ui.gadgets ui.render opengl.gl byte-arrays
namespaces opengl cairo.ffi cairo.lib ;
IN: cairo.png

TUPLE: png surface width height cairo-t array ;
TUPLE: png-gadget png ;

: <png> ( path -- png )
    cairo_image_surface_create_from_png
    dup [ cairo_image_surface_get_width ]
    [ cairo_image_surface_get_height ] [ ] tri
    cairo-surface>array png construct-boa ;

: write-png ( png path -- )
    >r png-surface r>
    cairo_surface_write_to_png
    zero? [ "write png failed" throw ] unless ;

: <png-gadget> ( path -- gadget )
    png-gadget construct-gadget swap
    <png> >>png ;

M: png-gadget pref-dim* ( gadget -- )
    png>>
    [ width>> ] [ height>> ] bi 2array ;

M: png-gadget draw-gadget* ( gadget -- )
    origin get [
        0 0 glRasterPos2i
        1.0 -1.0 glPixelZoom
        png>>
        [ width>> ]
        [ height>> GL_RGBA GL_UNSIGNED_BYTE ]
        [ array>> ] tri
        glDrawPixels
    ] with-translation ;

M: png-gadget graft* ( gadget -- )
    drop ;

M: png-gadget ungraft* ( gadget -- )
    png>> surface>> cairo_destroy ;
