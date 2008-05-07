! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel accessors math ui.gadgets ui.render
opengl.gl byte-arrays namespaces opengl cairo.ffi cairo.lib
inspector sequences combinators io.backend ;
IN: cairo.png

TUPLE: png surface width height cairo-t array ;
TUPLE: png-gadget png ;

ERROR: cairo-error string ;

: check-zero ( n -- n )
    dup zero? [
        "PNG dimension is 0" cairo-error
    ] when ;

: cairo-png-error ( n -- )
    {
        { CAIRO_STATUS_NO_MEMORY [ "Cairo: no memory" cairo-error ] }
        { CAIRO_STATUS_FILE_NOT_FOUND [ "Cairo: file not found" cairo-error ] }
        { CAIRO_STATUS_READ_ERROR [ "Cairo: read error" cairo-error ] }
        [ drop ]
    } case ;

: <png> ( path -- png )
    normalize-path
    cairo_image_surface_create_from_png
    dup cairo_surface_status cairo-png-error
    dup [ cairo_image_surface_get_width check-zero ]
    [ cairo_image_surface_get_height check-zero ] [ ] tri
    cairo-surface>array png boa ;

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
        ! [ height>> GL_BGRA GL_UNSIGNED_BYTE ]
        [ array>> ] tri
        glDrawPixels
    ] with-translation ;

M: png-gadget graft* ( gadget -- )
    drop ;

M: png-gadget ungraft* ( gadget -- )
    png>> surface>> cairo_destroy ;

! "resource:misc/icons/Factor_1x16.png" USE: cairo.png <png-gadget> gadget.
