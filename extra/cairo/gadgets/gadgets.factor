! Copyright (C) 2008 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences math opengl.gadgets kernel
byte-arrays cairo.ffi cairo io.backend
ui.gadgets accessors opengl.gl
arrays ;

IN: cairo.gadgets

: width>stride ( width -- stride ) 4 * ;
    
: copy-cairo ( dim quot -- byte-array )
    >r first2 over width>stride
    [ * nip <byte-array> dup CAIRO_FORMAT_ARGB32 ]
    [ cairo_image_surface_create_for_data ] 3bi
    r> with-cairo-from-surface ; inline

TUPLE: cairo-gadget < texture-gadget dim quot ;

: <cairo-gadget> ( dim quot -- gadget )
    cairo-gadget construct-gadget
        swap >>quot
        swap >>dim ;

M: cairo-gadget cache-key* [ dim>> ] [ quot>> ] bi 2array ;

: render-cairo ( dim quot -- bytes format )
    >r 2^-bounds r> copy-cairo GL_BGRA ;

M: cairo-gadget render*
    [ dim>> dup ] [ quot>> ] bi
    render-cairo render-bytes* ;

! maybe also texture>png
! : cairo>png ( gadget path -- )
!    >r [ cairo>bytes CAIRO_FORMAT_ARGB32 ] [ width>> ]
!    [ height>> ] tri over width>stride
!    cairo_image_surface_create_for_data
!    r> [ cairo_surface_write_to_png check-cairo ] curry with-surface ;

: copy-surface ( surface -- )
    cr swap 0 0 cairo_set_source_surface
    cr cairo_paint ;

TUPLE: png-gadget < texture-gadget path ;
: <png> ( path -- gadget )
    png-gadget construct-gadget
        swap >>path ;

M: png-gadget render*
    path>> normalize-path cairo_image_surface_create_from_png
    [ cairo_image_surface_get_width ]
    [ cairo_image_surface_get_height 2array dup 2^-bounds ]
    [ [ copy-surface ] curry copy-cairo ] tri
    GL_BGRA render-bytes* ;

M: png-gadget cache-key* path>> ;
