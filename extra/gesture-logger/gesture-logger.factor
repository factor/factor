! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io kernel prettyprint ui ui.gadgets ui.gadgets.panes
ui.gadgets.scrollers ui.gadgets.theme ui.gestures colors ;
IN: gesture-logger

TUPLE: gesture-logger stream ;

: <gesture-logger> ( stream -- gadget )
    \ gesture-logger construct-gadget
    [ set-gesture-logger-stream ] keep
    { 100 100 } over set-rect-dim
    dup black solid-interior ;

M: gesture-logger handle-gesture*
    drop
    dup T{ button-down } = [ over request-focus ] when
    swap gesture-logger-stream [ . ] with-stream*
    t ;

M: gesture-logger user-input*
    gesture-logger-stream [
        "User input: " write print
    ] with-stream* t ;

: gesture-logger ( -- )
    [
        <scrolling-pane> dup <scroller>
        "Gesture log" open-window
        <pane-stream> <gesture-logger>
        "Gesture input" open-window
    ] with-ui ;

MAIN: gesture-logger
