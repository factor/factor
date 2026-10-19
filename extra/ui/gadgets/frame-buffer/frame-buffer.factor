USING: accessors alien.c-types alien.data continuations destructors
grouping kernel math math.vectors namespaces opengl opengl.gl
opengl.textures sequences specialized-arrays ui.gadgets
ui.gadgets.worlds ui.render ;
SPECIALIZED-ARRAY: uint
IN: ui.gadgets.frame-buffer

TUPLE: frame-buffer < gadget pixels pixel-dim texture ;

: <frame-buffer> ( -- frame-buffer ) frame-buffer new ;

GENERIC: update-frame-buffer ( frame-buffer -- )

: frame-buffer-dim ( frame-buffer -- dim )
    dim>> [ gl-scale >fixnum ] map ;

:: copy-row ( old new -- )
    old new min-length :> count
    old count head-slice 0 new copy ;

: copy-pixels ( old-pixels old-width new-pixels new-width -- )
    ! Widths count pixels; each uint-array pixel has four components.
    [ [ drop { } ] [ 4 * <groups> ] if-zero ] 2bi@
    [ copy-row ] 2each ;

:: resize-frame-buffer ( buffer -- )
    buffer frame-buffer-dim :> dim
    buffer pixel-dim>> dim = [
        dim product 4 * uint <c-array> :> pixels
        buffer pixel-dim>> [
            buffer pixels>> swap first pixels dim first copy-pixels
        ] when*
        buffer pixels >>pixels dim >>pixel-dim drop
    ] unless ;

M: frame-buffer layout* resize-frame-buffer ;

<PRIVATE

! The window owns the GL object; the gadget only caches a reference to it.
TUPLE: frame-buffer-texture < disposable id dim owner ;

M: frame-buffer-texture dispose* id>> delete-texture ;

: <frame-buffer-texture> ( -- texture )
    frame-buffer-texture new-disposable
        gen-texture >>id
        world get-global >>owner
        window-resource
    GL_TEXTURE0 glActiveTexture
    dup id>> GL_TEXTURE_2D swap glBindTexture
    GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP_TO_EDGE glTexParameteri
    GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP_TO_EDGE glTexParameteri ;

: current-frame-buffer-texture? ( texture -- ? )
    [ disposed>> not ] [ owner>> world get-global eq? ] bi and ;

:: ensure-frame-buffer-texture ( buffer -- texture )
    buffer texture>> :> texture
    texture [ texture current-frame-buffer-texture? ] [ f ] if
    [ texture ] [ <frame-buffer-texture> dup buffer texture<< ] if ;

:: upload-frame-buffer ( buffer texture -- )
    GL_TEXTURE0 glActiveTexture
    GL_TEXTURE_2D texture id>> glBindTexture
    buffer pixel-dim>> first2 :> ( width height )
    texture dim>> buffer pixel-dim>> = [
        GL_TEXTURE_2D 0 0 0 width height
        GL_RGBA GL_UNSIGNED_INT buffer pixels>> glTexSubImage2D
    ] [
        GL_TEXTURE_2D 0 GL_RGBA8 width height 0
        GL_RGBA GL_UNSIGNED_INT buffer pixels>> glTexImage2D
        texture buffer pixel-dim>> >>dim drop
    ] if ;

:: without-frame-buffer-blending ( ..a quot: ( ..a -- ..b ) -- ..b )
    ! Captured pixels are already composited. Reblending fades the saved image.
    GL_BLEND glIsEnabled GL_TRUE = :> blending?
    GL_BLEND glDisable
    quot [ GL_BLEND blending? [ glEnable ] [ glDisable ] if ] finally ; inline

PRIVATE>

:: draw-pixels-gl3 ( buffer -- )
    buffer ensure-frame-buffer-texture :> texture
    buffer texture upload-frame-buffer
    ! Readback stores the bottom row first; the UI's texture coordinates do not.
    { 0 0 } buffer dim>> texture id>> t gl3-draw-texture ;

:: draw-pixels-legacy ( buffer -- )
    buffer dim>> { 0 1 } v* first2 glRasterPos2i
    buffer pixel-dim>> first2 GL_RGBA GL_UNSIGNED_INT
    buffer pixels>> glDrawPixels ;

: draw-pixels ( buffer -- )
    gl3-mode? get-global [ draw-pixels-gl3 ] [ draw-pixels-legacy ] if ;

:: read-pixels ( buffer -- )
    origin get first gl-scale >fixnum
    viewport-translation get second origin get second -
    buffer dim>> second - gl-scale >fixnum
    buffer pixel-dim>> first2 GL_RGBA GL_UNSIGNED_INT
    buffer pixels>> glReadPixels ;

M: frame-buffer draw-gadget*
    ! Recheck device dimensions in the owning context, including scale changes.
    dup resize-frame-buffer
    [ [ draw-pixels ] without-frame-buffer-blending ]
    [ update-frame-buffer ]
    [ glFlush read-pixels ] tri ;
