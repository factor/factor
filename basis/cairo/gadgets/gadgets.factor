! Copyright (C) 2008 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences math kernel byte-arrays cairo.ffi cairo
io.backend ui.gadgets accessors opengl.gl arrays fry
classes ui.render namespaces destructors libc ;
IN: cairo.gadgets

<PRIVATE
: width>stride ( width -- stride ) 4 * ;

: image-dims ( gadget -- width height stride )
    dim>> first2 over width>stride ; inline
: image-buffer ( width height stride -- alien )
    * nip malloc ; inline
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
        [ dim>> ] [ render-cairo &free ] bi
        origin get first2 glRasterPos2i
        1.0 -1.0 glPixelZoom
        [ first2 GL_BGRA GL_UNSIGNED_BYTE ] dip
        glDrawPixels
    ] with-destructors ;

: copy-surface ( surface -- )
    cr swap 0 0 cairo_set_source_surface
    cr cairo_paint ;
