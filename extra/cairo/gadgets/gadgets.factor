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
    r> with-cairo-from-surface ;

TUPLE: cairo-gadget < texture-gadget quot ;

: <cairo-gadget> ( dim quot -- gadget )
    cairo-gadget construct-gadget
        swap >>quot
        swap >>dim ;

M: cairo-gadget graft* ( gadget -- )
    GL_BGRA >>format dup
    [ dim>> 2^-bounds ] [ quot>> copy-cairo ] bi
    >>bytes call-next-method ;

! maybe also texture>png
! : cairo>png ( gadget path -- )
!    >r [ cairo>bytes CAIRO_FORMAT_ARGB32 ] [ width>> ]
!    [ height>> ] tri over width>stride
!    cairo_image_surface_create_for_data
!    r> [ cairo_surface_write_to_png check-cairo ] curry with-surface ;

: copy-surface ( surface -- )
    cr swap 0 0 cairo_set_source_surface
    cr cairo_paint ;

: <png-gadget> ( path -- gadget )
    normalize-path cairo_image_surface_create_from_png
    [ cairo_image_surface_get_width ]
    [ cairo_image_surface_get_height 2array dup 2^-bounds ]
    [ [ copy-surface ] curry copy-cairo ] tri
    GL_BGRA rot <texture-gadget> ;


