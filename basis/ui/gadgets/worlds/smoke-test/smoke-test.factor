! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Requires a display. Run with -run=ui.gadgets.worlds.smoke-test [--legacy].
USING: accessors alien.c-types alien.data arrays calendar colors
command-line continuations debugger io kernel locals math
math.vectors namespaces opengl opengl.gl opengl.textures sequences
specialized-arrays system threads ui ui.backend ui.gadgets
ui.gadgets.worlds ui.pixel-formats ui.render ;
SPECIALIZED-ARRAY: uchar
IN: ui.gadgets.worlds.smoke-test

TUPLE: resize-marker < gadget ;

M: resize-marker pref-dim* drop { 128 96 } ;

M: resize-marker draw-gadget*
    dim>> { 13 11 } v- { 13 11 }
    COLOR: red gl-color gl-fill-rect ;

:: check-pixels ( window -- )
    window dim>> [ gl-scale >fixnum ] map first2 :> ( width height )
    { 13 11 } [ gl-scale >fixnum ] map first2 :> ( marker-width marker-height )
    width height * 4 * uchar <c-array> :> pixels
    0 0 width height GL_RGBA GL_UNSIGNED_BYTE pixels glReadPixels
    gl-error
    width height * <iota> [| i |
        i width /mod :> ( y x )
        x width marker-width - >= y marker-height < and
        [ { 255 0 0 255 } ] [ { 0 0 255 255 } ] if
        i 4 * dup 4 + pixels subseq >array assert=
    ] each ;

:: check-resizes ( window -- )
    window set-gl-context
    gen-texture :> texture
    GL_TEXTURE_2D texture glBindTexture
    GL_TEXTURE_2D 0 GL_RGBA8 256 gl-scale >fixnum 192 gl-scale >fixnum
    0 GL_RGBA GL_UNSIGNED_BYTE f glTexImage2D
    1 { uint } [ glGenFramebuffers ] with-out-parameters :> framebuffer
    [
        GL_FRAMEBUFFER framebuffer glBindFramebuffer
        GL_FRAMEBUFFER GL_COLOR_ATTACHMENT0 GL_TEXTURE_2D texture 0
        glFramebufferTexture2D
        GL_FRAMEBUFFER glCheckFramebufferStatus GL_FRAMEBUFFER_COMPLETE assert=
        ! Model a native resize followed immediately by paint, before the UI
        ! thread drains its layout queue. No sleep or layout between these calls.
        { { 128 96 } { 186 150 } { 110 90 } { 154 126 } } [| dim |
            window dim >>dim drop
            ! Resizing may reselect a toolkit-owned presentation framebuffer.
            GL_FRAMEBUFFER framebuffer glBindFramebuffer
            window draw-world*
            window check-pixels
        ] each
    ] [
        window handle>> window-framebuffer GL_FRAMEBUFFER swap glBindFramebuffer
        1 framebuffer uint <ref> glDeleteFramebuffers
        texture delete-texture
    ] finally ;

: smoke-error ( error -- ) print-error nl flush 1 exit ;

:: worlds-smoke-test ( -- )
    [ smoke-error ] ui-error-hook set-global
    command-line get "--legacy" swap member? :> legacy?
    [
        resize-marker new <world-attributes> "Window resize regression" >>title
        legacy? [
            { windowed double-buffered legacy-context } >>pixel-format-attributes
        ] when
        open-window* :> window
        window COLOR: blue >>background-color drop
        [
            [
                250 milliseconds sleep
                window check-resizes
                "World resize smoke test passed" print flush
                close-all-windows 0 exit
            ] [ smoke-error ] recover
        ] "World resize smoke test" spawn drop
    ] with-ui ;

MAIN: worlds-smoke-test
