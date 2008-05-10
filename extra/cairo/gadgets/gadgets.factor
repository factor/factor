USING: cairo cairo.lib ui.render kernel opengl.gl opengl
math byte-arrays ui.gadgets accessors arrays 
namespaces io.backend ;

IN: cairo.gadgets

! We need two kinds of gadgets:
! one performs the cairo ops once and caches the bytes, the other
! performs cairo ops every refresh

TUPLE: cairo-gadget width height quot cache? bytes ;
PREDICATE: cached-cairo < cairo-gadget cache?>> ;
: <cairo-gadget> ( width height quot -- cairo-gadget )
    cairo-gadget construct-gadget 
    swap >>quot
    swap >>height
    swap >>width ;

: <cached-cairo> ( width height quot -- cairo-gadget )
    <cairo-gadget> t >>cache? ;

: width>stride ( width -- stride ) 4 * ;
    
: copy-cairo ( width height quot -- byte-array )
    >r over width>stride
    [ * nip <byte-array> dup CAIRO_FORMAT_ARGB32 ]
    [ cairo_image_surface_create_for_data ] 3bi
    r> with-cairo-from-surface ;

: (cairo>bytes) ( gadget -- byte-array )
    [ width>> ] [ height>> ] [ quot>> ] tri copy-cairo ;

GENERIC: cairo>bytes
M: cairo-gadget cairo>bytes ( gadget -- byte-array )
    (cairo>bytes) ;

M: cached-cairo cairo>bytes ( gadget -- byte-array )
    dup bytes>> [ ] [
        dup (cairo>bytes) [ >>bytes drop ] keep
    ] ?if ;

: cairo>png ( gadget path -- )
    >r [ cairo>bytes CAIRO_FORMAT_ARGB32 ] [ width>> ]
    [ height>> ] tri over width>stride
    cairo_image_surface_create_for_data
    r> [ cairo_surface_write_to_png check-cairo ] curry with-surface ;

M: cairo-gadget draw-gadget* ( gadget -- )
    origin get [
        0 0 glRasterPos2i
        1.0 -1.0 glPixelZoom
        [ width>> ] [ height>> GL_BGRA GL_UNSIGNED_BYTE ]
        [ cairo>bytes ] tri glDrawPixels
    ] with-translation ;
    
M: cairo-gadget pref-dim* ( gadget -- rect )
    [ width>> ] [ height>> ] bi 2array ;

: copy-surface ( surface -- )
    cr swap 0 0 cairo_set_source_surface
    cr cairo_paint ;

: <bytes-gadget> ( width height bytes -- cairo-gadget )
    >r [ ] <cached-cairo> r> >>bytes ;

: <png-gadget> ( path -- gadget )
    normalize-path cairo_image_surface_create_from_png
    [ cairo_image_surface_get_width ]
    [ cairo_image_surface_get_height 2dup ]
    [ [ copy-surface ] curry copy-cairo ] tri
    <bytes-gadget> ;