! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Run in a Windows UI image: -run=ui.text.directwrite.stress-test
USING: accessors alien.c-types alien.data arrays assocs byte-arrays
calendar continuations debugger fonts io kernel locals math math.functions namespaces
opengl opengl.gl prettyprint sequences sets strings system threads
tools.time ui ui.gadgets ui.gadgets.panes ui.gadgets.scrollers
ui.gadgets.worlds ui.private ui.render ui.text.directwrite.transforms windows.directwrite
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

:: framebuffer-strip ( width -- pixels )
    GL_VIEWPORT 4 int <c-array> [ glGetIntegerv ] keep fourth :> height
    width 32 * 4 * <byte-array> :> pixels
    0 height 32 - width 32 GL_RGBA GL_UNSIGNED_BYTE pixels glReadPixels
    gl-error pixels ;

: check-framebuffer ( -- )
    128 framebuffer-strip members length 8 > t assert= ;

:: check-run-boundary ( line scroller world -- )
    ! These two offsets have the same glyph phase. The far strip crosses
    ! a native 16K run boundary, which used to overlap by about 24 pixels.
    256 line directwrite-offset>x floor 128 - gl-unscale :> near-x
    32000 line directwrite-offset>x floor 128 - gl-unscale :> far-x
    scroller world near-x 0 scroll-frame 512 framebuffer-strip :> near
    scroller world far-x 0 scroll-frame 512 framebuffer-strip near assert= ;

:: check-distant-tiles ( line scroller world -- )
    ! Compare identical glyph phases near both ends of the actual 10M line.
    ! Large GPU vertices/modelview translations used to lose whole pixels.
    1024 line directwrite-offset>x floor 128 - gl-unscale :> near-x
    { 32768 8960000 9999360 } [| offset |
        offset line directwrite-offset>x floor 128 - gl-unscale :> far-x
        { 0 1 127 255 } [| delta |
            scroller world near-x delta gl-unscale + 0 scroll-frame
            512 framebuffer-strip :> near
            near members length 8 > t assert=
            scroller world far-x delta gl-unscale + 0 scroll-frame
            512 framebuffer-strip near assert=
        ] each
    ] each ;

:: check-transform-scopes ( world -- )
    world set-gl-context world gl-draw-init
    native-directwrite-transform :> original
    { -59114872.75 7 } [
        current-directwrite-transform :> outer
        { 1.25 2 } [
            current-directwrite-transform
            outer { 1.25 2 } translate-directwrite-transform assert=
        ] with-translation
        current-directwrite-transform outer assert=
        [
            1.25 1.5 gl-scale-2d
            current-directwrite-transform
            outer { 1.25 0 0 0 0 1.5 0 0 0 0 1 0 0 0 0 1 }
            multiply-directwrite-transforms assert=
        ] with-matrix
        current-directwrite-transform outer assert=
        [ [ "transform test" throw ] with-matrix ] [ drop ] recover
        current-directwrite-transform outer assert=
    ] with-translation
    native-directwrite-transform original assert=
    directwrite-transform get f assert=
    gl-error ;

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
    line scroller world check-run-boundary
    line scroller world check-distant-tiles
    world check-transform-scopes
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
