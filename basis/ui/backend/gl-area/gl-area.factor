! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data byte-arrays continuations
destructors kernel locals math math.vectors namespaces opengl
opengl.framebuffers opengl.gl opengl.textures sequences
specialized-arrays ui.gadgets.worlds ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
IN: ui.backend.gl-area

! GTK can repaint or replace its backing texture independently of Factor's
! graft/layout/render cycle. Present a completed frame, without running user
! drawing code from inside GTK's paint callback.
TUPLE: gl-area-frame < disposable
    { texture integer initial: 0 }
    { framebuffer integer initial: 0 }
    dim ;

M: gl-area-frame dispose*
    [ texture>> delete-texture ] [ framebuffer>> delete-framebuffer ] bi ;

<PRIVATE

: gl-integer ( enum -- value )
    { int } [ glGetIntegerv ] with-out-parameters ;

: <gl-area-frame> ( -- frame )
    gl-area-frame new-disposable window-resource
        gen-texture >>texture
        gen-framebuffer >>framebuffer ;

:: copy-frame ( frame source dim -- )
    GL_READ_FRAMEBUFFER_BINDING gl-integer :> previous-read
    GL_TEXTURE_BINDING_2D gl-integer :> previous-texture
    frame dim>> :> previous-dim
    f frame dim<<
    [
        GL_READ_FRAMEBUFFER source glBindFramebuffer
        GL_READ_BUFFER gl-integer :> previous-buffer
        [
            GL_COLOR_ATTACHMENT0 glReadBuffer
            GL_TEXTURE_2D frame texture>> glBindTexture
            previous-dim dim = [
                GL_TEXTURE_2D 0 0 0 0 0 dim first2 glCopyTexSubImage2D
            ] [
                GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
                GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
                GL_TEXTURE_2D 0 GL_RGBA8 0 0 dim first2 0 glCopyTexImage2D
            ] if
            GL_READ_FRAMEBUFFER frame framebuffer>> glBindFramebuffer
            GL_READ_FRAMEBUFFER GL_COLOR_ATTACHMENT0 GL_TEXTURE_2D
            frame texture>> 0 glFramebufferTexture2D
            GL_READ_FRAMEBUFFER glCheckFramebufferStatus
            dup GL_FRAMEBUFFER_COMPLETE = [ drop ] [ framebuffer-error ] if
            gl-error
            dim frame dim<<
        ] [
            GL_READ_FRAMEBUFFER source glBindFramebuffer
            previous-buffer glReadBuffer
        ] finally
    ] [
        GL_READ_FRAMEBUFFER previous-read glBindFramebuffer
        GL_TEXTURE_2D previous-texture glBindTexture
    ] finally ;

:: clear-frame ( background -- )
    GL_COLOR_WRITEMASK 4 <byte-array> [ glGetBooleanv ] keep :> mask
    GL_COLOR_CLEAR_VALUE 4 float <c-array> [ glGetFloatv ] keep :> color
    [
        GL_TRUE GL_TRUE GL_TRUE GL_TRUE glColorMask
        background gl-clear
    ] [
        mask first4 glColorMask
        color first4 glClearColor
    ] finally ;

PRIVATE>

:: cache-gl-area-frame ( frame/f framebuffer native-dim -- frame/f )
    ! A native allocation can still be catching up with the world's logical
    ! size. Copy only pixels inside both the rendered and allocated rectangles.
    world get-global dim>> [ gl-scale >fixnum ] map native-dim vmin :> dim
    framebuffer 0 > dim [ 0 > ] all? and [
        frame/f [
            dup disposed>> [ drop <gl-area-frame> ] when
        ] [ <gl-area-frame> ] if* :> frame
        frame framebuffer dim copy-frame
        frame
    ] [ frame/f ] if ;

:: present-gl-area-frame ( frame/f dim background -- )
    GL_READ_FRAMEBUFFER_BINDING gl-integer :> previous-read
    GL_READ_BUFFER gl-integer :> previous-read-buffer
    GL_DRAW_BUFFER0 gl-integer :> previous-buffer
    GL_SCISSOR_TEST glIsEnabled GL_TRUE = :> scissor?
    GL_FRAMEBUFFER_SRGB glIsEnabled GL_TRUE = :> srgb?
    GL_RASTERIZER_DISCARD glIsEnabled GL_TRUE = :> discard?
    [
        GL_SCISSOR_TEST glDisable
        GL_FRAMEBUFFER_SRGB glDisable
        GL_RASTERIZER_DISCARD glDisable
        GL_COLOR_ATTACHMENT0 glDrawBuffer
        frame/f [
            [ disposed>> not ] [ dim>> >boolean ] bi and
        ] [ f ] if* [
            GL_READ_FRAMEBUFFER frame/f framebuffer>> glBindFramebuffer
            GL_COLOR_ATTACHMENT0 glReadBuffer
            0 0 frame/f dim>> first2 0 0 dim first2
            GL_COLOR_BUFFER_BIT GL_NEAREST glBlitFramebuffer
        ] [ background clear-frame ] if
        gl-error
    ] [
        GL_READ_FRAMEBUFFER previous-read glBindFramebuffer
        previous-read-buffer glReadBuffer
        previous-buffer glDrawBuffer
        GL_SCISSOR_TEST scissor? [ glEnable ] [ glDisable ] if
        GL_FRAMEBUFFER_SRGB srgb? [ glEnable ] [ glDisable ] if
        GL_RASTERIZER_DISCARD discard? [ glEnable ] [ glDisable ] if
    ] finally ;
