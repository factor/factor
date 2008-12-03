! Copyright (C) 2008 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: locals math.functions math namespaces
opengl.gl opengl.demo-support accessors kernel opengl ui.gadgets
fry assocs
destructors sequences ui.render colors ;
IN: opengl.gadgets

TUPLE: texture-gadget < gadget ;

GENERIC: render* ( gadget -- texture dims )
GENERIC: cache-key* ( gadget -- key )

M: texture-gadget cache-key* ;

SYMBOL: textures
SYMBOL: refcounts

: init-cache ( symbol -- )
    dup get [ drop ] [ H{ } clone swap set-global ] if ;

textures init-cache
refcounts init-cache

: refcount-change ( gadget quot -- )
    >r cache-key* refcounts get
    [ [ 0 ] unless* ] r> compose change-at ;

TUPLE: cache-entry tex dims ;
C: <entry> cache-entry

: make-entry ( gadget -- entry )
    dup render* <entry>
    [ swap cache-key* textures get set-at ] keep ;

: get-entry ( gadget -- {texture,dims} )
    dup cache-key* textures get at
    [ nip ] [ make-entry ] if* ;

: get-dims ( gadget -- dims )
    get-entry dims>> ;

: get-texture ( gadget -- texture )
    get-entry tex>> ;

: release-texture ( gadget -- )
    cache-key* textures get delete-at*
    [ tex>> delete-texture ] [ drop ] if ;

: clear-textures ( -- )
    textures get values [ tex>> delete-texture ] each
    H{ } clone textures set-global
    H{ } clone refcounts set-global ;

M: texture-gadget graft* ( gadget -- ) [ 1+ ] refcount-change ;

M: texture-gadget ungraft* ( gadget -- )
    dup [ 1- ] refcount-change
    dup cache-key* refcounts get at
    zero? [ release-texture ] [ drop ] if ;

: 2^-ceil ( x -- y )
    dup 2 < [ 2 * ] [ 1- log2 1+ 2^ ] if ; foldable flushable

: 2^-bounds ( dim -- dim' )
    [ 2^-ceil ] map ; foldable flushable

:: (render-bytes) ( dims bytes format texture -- )
    GL_ENABLE_BIT [
        GL_TEXTURE_2D glEnable
        GL_TEXTURE_2D texture glBindTexture
        GL_TEXTURE_2D
        0
        GL_RGBA
        dims 2^-bounds first2
        0
        format
        GL_UNSIGNED_BYTE
        bytes
        glTexImage2D
        init-texture
        GL_TEXTURE_2D 0 glBindTexture
    ] do-attribs ;

: render-bytes ( dims bytes format -- texture )
    gen-texture [ (render-bytes) ] keep ;

: render-bytes* ( dims bytes format -- texture dims )
    pick >r render-bytes r> ;

:: four-corners ( dim -- )
    [let* | w [ dim first ]
            h [ dim second ]
            dim' [ dim dup 2^-bounds [ /f ] 2map ]
            w' [ dim' first ]
            h' [ dim' second ] |
        0  0  glTexCoord2d 0 0 glVertex2d
        0  h' glTexCoord2d 0 h glVertex2d
        w' h' glTexCoord2d w h glVertex2d
        w' 0  glTexCoord2d w 0 glVertex2d
    ] ;

M: texture-gadget draw-gadget* ( gadget -- )
    origin get [
        GL_ENABLE_BIT [
            white gl-color
            1.0 -1.0 glPixelZoom
            GL_TEXTURE_2D glEnable
            GL_TEXTURE_2D over get-texture glBindTexture
            GL_QUADS [
                get-dims four-corners
            ] do-state
            GL_TEXTURE_2D 0 glBindTexture
        ] do-attribs
    ] with-translation ;

M: texture-gadget pref-dim* ( gadget -- dim ) get-dims ;
