! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
! Run with a GTK3/GTK4 image and a display: -run=ui.text.pango.smoke-test
USING: accessors alien.c-types alien.data arrays byte-arrays calendar
continuations debugger fonts images io kernel locals math namespaces
opengl opengl.gl sequences sets strings system threads ui ui.gadgets.panes
ui.gadgets.scrollers ui.gadgets.worlds ui.text.pango ui.text.pango.indexed
ui.text.pango.private ;
IN: ui.text.pango.smoke-test

: smoke-error ( error -- ) print-error nl flush 1 exit ;

:: check-long-row ( text scroller world -- )
    500 milliseconds sleep
    monospace-font text cached-layout :> line
    line 9990000 line-offset>x :> x
    line x x>line-offset 9990000 assert=
    line { 0 0 } { 64 8 } draw-layout-region bitmap>> :> near
    line x 0 2array { 64 8 } draw-layout-region bitmap>> :> far
    near far assert=
    far members length 8 > t assert=
    x gl-unscale 0 2array scroller set-scroll-position
    500 milliseconds sleep
    world set-gl-context world draw-world*
    GL_VIEWPORT 4 int <c-array> [ glGetIntegerv ] keep fourth :> height
    128 32 * 4 * <byte-array> :> pixels
    0 height 32 - 128 32 GL_RGBA GL_UNSIGNED_BYTE pixels glReadPixels
    gl-error
    pixels members length 8 > t assert=
    line glyph-index>> x 1600 visible-glyph-regions length 16 < t assert=
    close-all-windows ;

: pango-smoke-test ( -- )
    [ smoke-error ] ui-error-hook set-global
    [
        10000000 CHAR: a <string>
        dup '[ _ print ] make-pane <scroller>
        dup <world-attributes> "Pango 10M row smoke test" >>title
        { 640 120 } >>pref-dim open-window*
        '[ _ _ _ [ check-long-row ] [ smoke-error ] recover ]
        "Pango long-row smoke test" spawn drop
    ] with-ui
    "Pango 10M row smoke test passed" print ;

MAIN: pango-smoke-test
