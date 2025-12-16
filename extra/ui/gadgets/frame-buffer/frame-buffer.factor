USING: accessors alien.c-types alien.data grouping kernel
math math.vectors namespaces opengl opengl.gl sequences
specialized-arrays ui.gadgets ui.render ui.render.gl3 ;
SPECIALIZED-ARRAY: uint
IN: ui.gadgets.frame-buffer

TUPLE: frame-buffer < gadget pixels last-dim texture-id ;

: <frame-buffer> ( -- frame-buffer ) frame-buffer new ;

GENERIC: update-frame-buffer ( frame-buffer -- )

: init-frame-buffer-pixels ( frame-buffer -- )
  dup dim>> [ gl-scale ] map product >integer 4 * uint <c-array> >>pixels
  drop ;

! GL3-compatible: upload pixels to texture and draw as textured quad
:: draw-pixels-gl3 ( FRAME-BUFFER -- )
    FRAME-BUFFER dim>> first2 [ gl-scale >fixnum ] bi@ :> ( width height )
    ! Create or update texture
    FRAME-BUFFER texture-id>> [
        ! Update existing texture
        GL_TEXTURE_2D over glBindTexture
        GL_TEXTURE_2D 0 0 0 width height
        GL_RGBA GL_UNSIGNED_INT FRAME-BUFFER pixels>>
        glTexSubImage2D
    ] [
        ! Create new texture
        1 { uint } [ glGenTextures ] with-out-parameters :> tex-id
        tex-id FRAME-BUFFER texture-id<<
        GL_TEXTURE_2D tex-id glBindTexture
        GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
        GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
        GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP_TO_EDGE glTexParameteri
        GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP_TO_EDGE glTexParameteri
        GL_TEXTURE_2D 0 GL_RGBA width height 0
        GL_RGBA GL_UNSIGNED_INT FRAME-BUFFER pixels>>
        glTexImage2D
        tex-id
    ] if*
    drop
    ! Draw the texture using GL3 texture drawing
    { 0 0 } FRAME-BUFFER dim>> FRAME-BUFFER texture-id>> f gl3-draw-texture
    GL_TEXTURE_2D 0 glBindTexture ;

! Legacy GL: use glDrawPixels directly
:: draw-pixels-legacy ( FRAME-BUFFER -- )
    FRAME-BUFFER dim>> first2 [ gl-scale >fixnum ] bi@
    GL_RGBA
    GL_UNSIGNED_INT
    FRAME-BUFFER pixels>>
    glDrawPixels ;

:: draw-pixels ( FRAME-BUFFER -- )
    gl3-mode? get-global
    [ FRAME-BUFFER draw-pixels-gl3 ]
    [ FRAME-BUFFER draw-pixels-legacy ] if ;

:: read-pixels ( FRAME-BUFFER -- )
    0
    0
    FRAME-BUFFER dim>> first2 [ gl-scale >fixnum ] bi@
    GL_RGBA
    GL_UNSIGNED_INT
    FRAME-BUFFER pixels>>
    glReadPixels ;

:: copy-row ( OLD NEW -- )
    OLD NEW min-length :> LEN
    OLD LEN head-slice 0 NEW copy ;

: copy-pixels ( old-pixels old-width new-pixels new-width -- )
    [ [ drop { } ] [ 16 * <groups> ] if-zero ] 2bi@
    [ copy-row ] 2each ;

M:: frame-buffer layout* ( FRAME-BUFFER -- )
    FRAME-BUFFER last-dim>> [
        FRAME-BUFFER dim>> = [
            FRAME-BUFFER pixels>> :> OLD-PIXELS
            FRAME-BUFFER last-dim>> first gl-scale >fixnum :> OLD-WIDTH
            FRAME-BUFFER init-frame-buffer-pixels
            FRAME-BUFFER [ dim>> ] [ last-dim<< ] bi
            FRAME-BUFFER pixels>> :> NEW-PIXELS
            FRAME-BUFFER last-dim>> first gl-scale >fixnum :> NEW-WIDTH
            OLD-PIXELS OLD-WIDTH NEW-PIXELS NEW-WIDTH copy-pixels
            ! Delete old texture if exists, will be recreated
            FRAME-BUFFER texture-id>> [ 1 swap uint <ref> glDeleteTextures ] when*
            f FRAME-BUFFER texture-id<<
        ] unless
    ] [
        FRAME-BUFFER init-frame-buffer-pixels
        FRAME-BUFFER [ dim>> ] [ last-dim<< ] bi
    ] if* ;

M:: frame-buffer draw-gadget* ( FRAME-BUFFER -- )
    gl3-mode? get-global [
        ! GL3 path: draw texture
        FRAME-BUFFER draw-pixels
        FRAME-BUFFER update-frame-buffer
        glFlush
        FRAME-BUFFER read-pixels
    ] [
        ! Legacy path
        FRAME-BUFFER dim>> { 0 1 } v* first2 glRasterPos2i
        FRAME-BUFFER draw-pixels
        FRAME-BUFFER update-frame-buffer
        glFlush
        FRAME-BUFFER read-pixels
    ] if ;
