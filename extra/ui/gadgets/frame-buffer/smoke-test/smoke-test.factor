! Requires a display. Run with -run=ui.gadgets.frame-buffer.smoke-test [--legacy].
USING: accessors alien.c-types alien.data arrays calendar colors command-line
concurrency.promises continuations debugger destructors io kernel locals
math math.bitwise math.order math.vectors namespaces opengl opengl.gl sequences
specialized-arrays system threads ui ui.backend ui.gadgets
ui.gadgets.borders ui.gadgets.frame-buffer ui.gadgets.worlds ui.pixel-formats ;
SPECIALIZED-ARRAY: uint
IN: ui.gadgets.frame-buffer.smoke-test

TUPLE: test-frame-buffer < frame-buffer paint? ;

ERROR: resize-timeout window-dim gadget-dim expected-dim ;

M: test-frame-buffer pref-dim* drop { 128 96 } ;

M: test-frame-buffer update-frame-buffer
    dup paint?>> [
        f >>paint? drop
        1.0 0.25 0.0 0.5 <rgba> gl-color
        { 7 11 } { 23 17 } gl-fill-rect
        0.0 0.5 1.0 1.0 <rgba> gl-color
        { 45 37 } { 13 9 } gl-fill-rect
    ] [ drop ] if ;

:: await-window-size ( window gadget dim -- )
    250 [
        drop
        window draw-world? window dim>> dim = and
        gadget dim>> dim { 10 18 } v- [ number= ] 2all? and
        [ t ] [ 20 milliseconds sleep f ] if
    ] find-integer [ drop ] [
        window dim>> gadget dim>> dim resize-timeout
    ] if* ;

:: saved-frame ( window gadget -- pixels )
    window set-gl-context
    window draw-world*
    gl-error
    gadget pixels>> clone ;

:: check-saved-frames ( window gadget pixels -- )
    5 [ window gadget saved-frame pixels assert= ] times ;

! An independent coordinate-based oracle, rather than the production row copier.
:: resized-pixels ( pixels old-dim dim -- resized )
    old-dim first2 :> ( old-width old-height )
    dim product 4 * <iota> [| i |
        i 4 /mod :> ( pixel component )
        pixel dim first /mod :> ( row column )
        row old-height < column old-width < and [
            row old-width * column + 4 * component + pixels nth
        ] [ 0 ] if
    ] uint-array{ } map-as ;

:: check-resize ( window gadget dim -- )
    gadget pixels>> clone :> before
    gadget pixel-dim>> :> old-dim
    window dim resize-window
    window gadget dim await-window-size
    before old-dim gadget frame-buffer-dim resized-pixels :> expected
    window gadget expected check-saved-frames ;

:: sample-pixel ( gadget point -- rgba )
    gadget pixel-dim>> first2 :> ( width height )
    point [ gl-scale >fixnum ] map first2 :> ( x y )
    height y - 1 - width * x + 4 * :> index
    index index 4 + gadget pixels>> subseq [ -24 shift ] map >array ;

:: check-paint ( gadget -- )
    ! The opaque marker checks actual colors and readback position.
    gadget { 50 40 } sample-pixel first4 :> ( r g b a )
    r 0 assert= g 127 128 between? t assert= b 255 assert= a 255 assert=
    ! The translucent marker must have been blended onto transparent black.
    gadget { 10 15 } sample-pixel first4 :> ( r2 g2 b2 a2 )
    r2 127 128 between? t assert= g2 31 32 between? t assert=
    b2 0 assert= a2 63 64 between? t assert= ;

:: check-frame-buffer ( window gadget -- )
    window gadget { 138 114 } await-window-size
    gadget t >>paint? drop
    window gadget saved-frame :> painted
    gadget check-paint
    window gadget painted check-saved-frames
    GL_BLEND glIsEnabled GL_TRUE assert=
    GL_BLEND glDisable
    window gadget painted check-saved-frames
    GL_BLEND glIsEnabled GL_FALSE assert=
    GL_BLEND glEnable
    window gadget { 186 150 } check-resize
    window gadget { 110 90 } check-resize
    window gadget { 154 126 } check-resize ;

:: close-test-window ( window gadget -- )
    gadget texture>> :> texture
    window close-window
    window promise>> ?promise drop
    texture [ texture disposed>> t assert= ] when ;

:: open-test-window ( gadget legacy? -- window )
    gadget { 5 9 } <filled-border>
    <world-attributes> "Frame-buffer regression" >>title
    legacy? [ { legacy-context } >>pixel-format-attributes ] when open-window* ;

:: detach-test-gadget ( gadget -- )
    gadget parent>> :> border
    border clear-gadget
    border <gadget> { 128 96 } >>dim add-gadget drop ;

:: check-move ( window gadget legacy? -- )
    gadget texture>> :> old-texture
    gadget pixels>> clone :> pixels
    gadget pixel-dim>> :> dim
    gadget detach-test-gadget
    gadget legacy? open-test-window :> destination
    destination gadget { 138 114 } await-window-size
    pixels dim gadget frame-buffer-dim resized-pixels :> expected
    destination gadget expected check-saved-frames
    old-texture [
        gadget texture>> old-texture eq? f assert=
        old-texture disposed>> f assert=
    ] when
    window close-window window promise>> ?promise drop
    old-texture [
        old-texture disposed>> t assert=
        gadget texture>> disposed>> f assert=
    ] when
    destination gadget expected check-saved-frames
    destination gadget close-test-window ;

:: check-reopen ( gadget legacy? -- )
    gadget pixels>> clone :> pixels
    gadget pixel-dim>> :> dim
    gadget detach-test-gadget
    gadget legacy? open-test-window :> window
    window gadget { 138 114 } await-window-size
    pixels dim gadget frame-buffer-dim resized-pixels :> expected
    window gadget expected check-saved-frames
    window gadget close-test-window ;

: smoke-error ( error -- ) print-error nl flush 1 exit ;

:: frame-buffer-smoke-test ( -- )
    [ smoke-error ] ui-error-hook set-global
    command-line get "--legacy" swap member? :> legacy?
    [
        ! Keep the event loop alive while the test gadget moves between windows.
        <gadget> { 48 32 } >>dim "Frame-buffer smoke tests" open-window
        test-frame-buffer new { 128 96 } >>dim :> gadget
        gadget legacy? open-test-window :> window
        [
            [
                window gadget check-frame-buffer
                window gadget legacy? check-move
                gadget legacy? check-reopen
                "Frame-buffer smoke test passed (colors, repaint, resize, move, cleanup, reopen)"
                print flush close-all-windows 0 exit
            ] [ smoke-error ] recover
        ] "Frame-buffer smoke test" spawn drop
    ] with-ui ;

MAIN: frame-buffer-smoke-test
