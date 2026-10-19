! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Exercised by both GTK backend smoke tests, with a real current GL context.
USING: accessors alien.c-types alien.data arrays byte-arrays calendar
colors combinators concurrency.promises continuations destructors kernel locals make math
namespaces opengl opengl.framebuffers opengl.gl opengl.textures sequences
specialized-arrays system threads ui ui.backend ui.backend.gl-area ui.gadgets
ui.gadgets.packs ui.gadgets.worlds ui.render ;
FROM: alien.c-types => float ;
SPECIALIZED-ARRAY: float
IN: ui.backend.gl-area.smoke-test

ERROR: gl-area-check-failed check actual expected ;

:: check= ( actual expected check -- )
    actual expected = [ check actual expected gl-area-check-failed ] unless ;

: gl-integer ( enum -- value )
    { int } [ glGetIntegerv ] with-out-parameters ;

: bindings ( -- draw read )
    GL_DRAW_FRAMEBUFFER_BINDING gl-integer
    GL_READ_FRAMEBUFFER_BINDING gl-integer ;

:: check-framebuffer-scopes ( -- )
    bindings :> ( draw read )
    gen-framebuffer :> first
    gen-framebuffer :> second
    [
        first [
            bindings read = swap first = and t "draw scope preserves read binding" check=
            second [
                GL_DRAW_FRAMEBUFFER_BINDING gl-integer second
                "nested draw scope" check=
            ] with-framebuffer
            GL_DRAW_FRAMEBUFFER_BINDING gl-integer first
            "nested draw scope restores outer binding" check=
            [ second [ "framebuffer test" throw ] with-framebuffer ]
            [ "framebuffer test" "draw scope propagates error" check= ] recover
            GL_DRAW_FRAMEBUFFER_BINDING gl-integer first
            "draw scope restores binding after error" check=
        ] with-framebuffer
        bindings read = swap draw = and t "draw scope restores native binding" check=
        [
            first second [
                bindings second = swap first = and t "draw/read scope" check=
                "framebuffer test" throw
            ] with-draw-read-framebuffers
        ] [ "framebuffer test" "draw/read scope propagates error" check= ] recover
        bindings read = swap draw = and t "draw/read scope restores both bindings" check=
        gl-error
    ] [ first delete-framebuffer second delete-framebuffer ] finally ;

! Check all pixels, including alpha, rather than sampling a few corners.
:: native-pixels ( dim -- pixels )
    GL_READ_FRAMEBUFFER_BINDING gl-integer :> previous-read
    [
        GL_READ_FRAMEBUFFER GL_DRAW_FRAMEBUFFER_BINDING gl-integer glBindFramebuffer
        dim product 4 * <byte-array> :> pixels
        0 0 dim first2 GL_RGBA GL_UNSIGNED_BYTE pixels glReadPixels
        gl-error pixels
    ] [ GL_READ_FRAMEBUFFER previous-read glBindFramebuffer ] finally ;

: presentation-state ( -- state )
    [
        bindings [ , ] bi@
        GL_READ_BUFFER gl-integer ,
        GL_DRAW_BUFFER0 gl-integer ,
        GL_TEXTURE_BINDING_2D gl-integer ,
        GL_SCISSOR_TEST glIsEnabled ,
        GL_FRAMEBUFFER_SRGB glIsEnabled ,
        GL_RASTERIZER_DISCARD glIsEnabled ,
        GL_COLOR_WRITEMASK 4 <byte-array> [ glGetBooleanv ] keep ,
        GL_COLOR_CLEAR_VALUE 4 float <c-array> [ glGetFloatv ] keep >array ,
    ] { } make ;

:: check-presentation-state ( w -- )
    w set-gl-context
    w window-resources>> [ gl-area-frame? ] filter last :> frame
    frame dim>> :> dim
    dim native-pixels :> expected
    gen-texture :> texture
    bindings :> ( draw read )
    [
        GL_READ_FRAMEBUFFER frame framebuffer>> glBindFramebuffer
        GL_NONE glReadBuffer
        GL_TEXTURE_2D texture glBindTexture
        GL_SCISSOR_TEST glEnable
        GL_FRAMEBUFFER_SRGB glEnable
        GL_RASTERIZER_DISCARD glEnable
        GL_FALSE GL_FALSE GL_FALSE GL_FALSE glColorMask
        0.125 0.25 0.5 0.75 glClearColor
        presentation-state :> state
        frame draw dim cache-gl-area-frame frame eq? t "cache reuses its resources" check=
        presentation-state state "capture preserves GL state" check=
        f dim COLOR: white present-gl-area-frame
        presentation-state state "initial-frame clear preserves GL state" check=
        dim native-pixels [ 255 = ] all? t "initial frame clears every pixel" check=
        frame dim COLOR: white present-gl-area-frame
        presentation-state state "presentation preserves GL state" check=
        dim native-pixels expected "presentation restores the completed frame" check=
        gl-error
    ] [
        GL_DRAW_FRAMEBUFFER draw glBindFramebuffer
        GL_READ_FRAMEBUFFER read glBindFramebuffer
        GL_COLOR_ATTACHMENT0 glDrawBuffer
        GL_SCISSOR_TEST glDisable
        GL_FRAMEBUFFER_SRGB glDisable
        GL_RASTERIZER_DISCARD glDisable
        GL_TRUE GL_TRUE GL_TRUE GL_TRUE glColorMask
        GL_TEXTURE_2D 0 glBindTexture
        texture delete-texture
    ] finally ;

TUPLE: tracked-gadget < gadget { paints initial: 0 } { premature-paints initial: 0 } grafted? ;
M: tracked-gadget pref-dim* drop { 128 96 } ;
M: tracked-gadget graft* t >>grafted? drop ;
M: tracked-gadget ungraft* f >>grafted? drop ;
M: tracked-gadget draw-gadget*
    dup grafted?>> [ [ 1 + ] change-premature-paints ] unless
    [ 1 + ] change-paints drop
    COLOR: red gl-color { 0 0 } { 13 11 } gl-fill-rect
    COLOR: green gl-color { 17 19 } { 29 23 } gl-fill-rect
    0.25 0.5 0.75 0.5 <rgba> gl-color { 67 53 } { 11 17 } gl-fill-rect ;

:: await-paint ( gadget check -- )
    nano-count 10,000,000,000 + :> deadline
    [ gadget paints>> zero? nano-count deadline < and ] [ 20 milliseconds sleep ] while
    gadget paints>> 0 > t check check= ;

:: check-paint-order ( paint: ( world -- ) -- )
    tracked-gadget new :> child
    <pile> child add-gadget :> pile
    pile <world-attributes> "GLArea presentation ordering" >>title
    { 320 240 } >>pref-dim open-window* :> w
    w COLOR: blue >>background-color drop
    child "initial graft renders" await-paint
    200 milliseconds sleep
    child 0 >>paints drop
    w relayout-1
    child "relayout renders" await-paint
    150 milliseconds sleep
    child paints>> 1 "one scene render per relayout request" check=
    w set-gl-context
    check-framebuffer-scopes
    w check-presentation-state
    tracked-gadget new { 80 50 } >>dim :> pending
    pile pending add-gadget drop
    ! Do not yield: the native callback must not draw the pending graft.
    w paint call
    pending paints>> 0 "native paint does not render the gadget tree" check=
    pending "queued graft renders" await-paint
    pending premature-paints>> 0 "drawing follows grafting" check=
    w window-resources>> [ gl-area-frame? ] filter last :> frame
    w close-window
    w promise>> ?promise drop
    frame disposed>> t "window closes its presentation cache" check=
    w window-resources>> empty? t "window releases its resources" check= ; inline
