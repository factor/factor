! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Run in a Windows UI image: -run=ui.text.directwrite.stress-test
USING: accessors alien.c-types alien.data arrays assocs byte-arrays
calendar continuations debugger fonts io kernel locals math namespaces
opengl opengl.gl prettyprint sequences sets strings system threads
tools.time ui ui.gadgets ui.gadgets.panes ui.gadgets.scrollers
ui.gadgets.worlds ui.private windows.directwrite
windows.directwrite.indexed windows.directwrite.render ;
IN: ui.text.directwrite.stress-test

: stress-error ( error -- ) print-error nl flush 1 exit ;

:: scroll-frame ( scroller world x y -- )
    x y 2array scroller set-scroll-position
    layout-queued drop
    world set-gl-context world draw-world* glFinish gl-error ;

: frame-times. ( times -- )
    [ sum 20 /f "Mean frame ms: " write . ]
    [ supremum "Maximum frame ms: " write . ] bi flush ;

:: check-framebuffer ( -- )
    GL_VIEWPORT 4 int <c-array> [ glGetIntegerv ] keep fourth :> height
    128 32 * 4 * <byte-array> :> pixels
    0 height 32 - 128 32 GL_RGBA GL_UNSIGNED_BYTE pixels glReadPixels
    gl-error pixels members length 8 > t assert= ;

:: exercise-output ( pane scroller world -- )
    500 milliseconds sleep
    "Printing 20 separate 10,000,000-character rows" print flush
    [ pane <pane-stream> [
        20 [ 10,000,000 CHAR: a <string> print ] times
    ] with-output-stream* ] time flush
    pane output>> children>> length 20 assert=
    monospace-font 10,000,000 CHAR: a <string> cached-directwrite-layout :> line
    line glyph-index>> :> index
    index 60000000 60000640 visible-directwrite-regions length 4 < t assert=
    line size>> first index width>> - 4 < t assert=
    line line size>> first 64 - 0 2array { 64 15 }
    directwrite-layout>region-image bitmap>> members length 8 > t assert=
    scroller world 0 0 scroll-frame
    "Uncached horizontal and vertical scrolling" print
    20 [| i |
        [ scroller world i 3000000 * i 10 * scroll-frame ] benchmark 1000000 /f
    ] map-integers frame-times.
    check-framebuffer
    "Cached vertical scrolling" print
    20 [| i |
        [ scroller world 60000000 i 10 * scroll-frame ] benchmark 1000000 /f
    ] map-integers frame-times.
    check-framebuffer
    scroller world line size>> first 640 - 0 scroll-frame
    check-framebuffer
    "Cached textures: " write world text-handle>> assoc-size .
    close-all-windows ;

: directwrite-stress-test ( -- )
    [ stress-error ] ui-error-hook set-global
    [
        <pane> dup <scroller>
        dup <world-attributes> "DirectWrite 20 x 10M rows" >>title
        { 640 180 } >>pref-dim open-window*
        '[ _ _ _ [ exercise-output ] [ stress-error ] recover ]
        "DirectWrite scrolling stress test" spawn drop
    ] with-ui
    "DirectWrite 20 x 10M scrolling test passed" print ;

MAIN: directwrite-stress-test
