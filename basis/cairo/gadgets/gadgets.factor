! Copyright (C) 2008 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences math kernel byte-arrays cairo.ffi cairo
io.backend ui.gadgets accessors opengl.gl arrays fry
classes ui.render namespaces ;

IN: cairo.gadgets

: width>stride ( width -- stride ) 4 * ;
    
GENERIC: render-cairo* ( gadget -- )

: render-cairo ( gadget -- byte-array )
    dup dim>> first2 over width>stride
    [ * nip <byte-array> dup CAIRO_FORMAT_ARGB32 ] 
    [ cairo_image_surface_create_for_data ] 3bi
    rot '[ _ render-cairo* ] with-cairo-from-surface ; inline

TUPLE: cairo-gadget < gadget ;

: <cairo-gadget> ( dim -- gadget )
    cairo-gadget new-gadget
        swap >>dim ;

M: cairo-gadget draw-gadget*
    [ dim>> ] [ render-cairo ] bi
    origin get first2 glRasterPos2i
    1.0 -1.0 glPixelZoom
    [ first2 GL_BGRA GL_UNSIGNED_BYTE ] dip
    glDrawPixels ;

: copy-surface ( surface -- )
    cr swap 0 0 cairo_set_source_surface
    cr cairo_paint ;
