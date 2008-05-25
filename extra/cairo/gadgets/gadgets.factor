! Copyright (C) 2008 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: cairo cairo.ffi ui.render kernel opengl.gl opengl
math byte-arrays ui.gadgets accessors arrays 
namespaces io.backend memoize colors ;

IN: cairo.gadgets

! We need two kinds of gadgets:
! one performs the cairo ops once and caches the bytes, the other
! performs cairo ops every refresh

TUPLE: cairo-gadget width height quot cache? texture ;
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

: cairo>bytes ( gadget -- byte-array )
    [ width>> ] [ height>> ] [ quot>> ] tri copy-cairo ;

: cairo>png ( gadget path -- )
    >r [ cairo>bytes CAIRO_FORMAT_ARGB32 ] [ width>> ]
    [ height>> ] tri over width>stride
    cairo_image_surface_create_for_data
    r> [ cairo_surface_write_to_png check-cairo ] curry with-surface ;

: with-cairo-gl ( quot -- )
    >r origin get [
        0 0 glRasterPos2i
        1.0 -1.0 glPixelZoom
    ] r> compose with-translation ;

M: cairo-gadget draw-gadget* ( gadget -- )
    [
        [ width>> ] [ height>> GL_BGRA GL_UNSIGNED_BYTE ]
        [ cairo>bytes ] tri glDrawPixels
    ] with-cairo-gl ;

MEMO: render-to-texture ( gadget -- )
    GL_TEXTURE_BIT [
        GL_TEXTURE_2D over texture>> glBindTexture
        >r GL_TEXTURE_2D 0 GL_RGBA r>
        [ width>> ] [ height>> 0 GL_BGRA GL_UNSIGNED_BYTE ]
        [ cairo>bytes ] tri glTexImage2D
        init-texture
        GL_TEXTURE_2D 0 glBindTexture
    ] do-attribs ;

M: cached-cairo draw-gadget* ( gadget -- )
    GL_TEXTURE_2D [
        [
            dup render-to-texture
            white gl-color
            GL_TEXTURE_2D over texture>> glBindTexture
            GL_QUADS [
                [ width>> ] [ height>> ] bi 2array four-sides
            ] do-state
            GL_TEXTURE_2D 0 glBindTexture
        ] with-cairo-gl
    ] do-enabled ;

M: cached-cairo graft* ( gadget -- )
    gen-texture >>texture drop ;

M: cached-cairo ungraft* ( gadget -- )
    [ texture>> delete-texture ]
    [ \ render-to-texture invalidate-memoized ] bi ;
    
M: cairo-gadget pref-dim* ( gadget -- rect )
    [ width>> ] [ height>> ] bi 2array ;

: copy-surface ( surface -- )
    cr swap 0 0 cairo_set_source_surface
    cr cairo_paint ;

: <bytes-gadget> ( width height bytes -- cairo-gadget )
    >r [ ] <cached-cairo> r> >>texture ;

: <png-gadget> ( path -- gadget )
    normalize-path cairo_image_surface_create_from_png
    [ cairo_image_surface_get_width ]
    [ cairo_image_surface_get_height 2dup ]
    [ [ copy-surface ] curry copy-cairo ] tri
    <bytes-gadget> ;


