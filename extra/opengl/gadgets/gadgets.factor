! Copyright (C) 2008 Matthew Willis.
! See http://factorcode.org/license.txt for BSD license.
USING: locals math.functions math namespaces
opengl.gl accessors kernel opengl ui.gadgets
destructors sequences ui.render colors ;
IN: opengl.gadgets

TUPLE: texture-gadget bytes format dim tex ;

: 2^-ceil ( x -- y )
    dup 2 < [ 2 * ] [ 1- log2 1+ 2^ ] if ; foldable flushable

: 2^-bounds ( dim -- dim' )
    [ 2^-ceil ] map ; foldable flushable

: <texture-gadget> ( bytes format dim -- gadget )
    texture-gadget construct-gadget
        swap >>dim
        swap >>format
        swap >>bytes ;

GENERIC: render* ( texture-gadget -- )

M:: texture-gadget render* ( gadget -- )
    GL_ENABLE_BIT [
        GL_TEXTURE_2D glEnable
        GL_TEXTURE_2D gadget tex>> glBindTexture
        GL_TEXTURE_2D
        0
        GL_RGBA
        gadget dim>> 2^-bounds first2
        0
        gadget format>>
        GL_UNSIGNED_BYTE
        gadget bytes>>
        glTexImage2D
        init-texture
        GL_TEXTURE_2D 0 glBindTexture
    ] do-attribs ;

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
            GL_TEXTURE_2D over tex>> glBindTexture
            GL_QUADS [
                dim>> four-corners
            ] do-state
            GL_TEXTURE_2D 0 glBindTexture
        ] do-attribs
    ] with-translation ;

M: texture-gadget graft* ( gadget -- )
    gen-texture >>tex [ render* ]
    [ f >>bytes drop ] bi ;

M: texture-gadget ungraft* ( gadget -- )
    tex>> delete-texture ;

M: texture-gadget pref-dim* ( gadget -- dim ) dim>> ;
