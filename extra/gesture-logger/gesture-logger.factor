! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io kernel prettyprint ui ui.gadgets
ui.gadgets.panes ui.gadgets.scrollers ui.gadgets.theme
ui.gestures colors ;
IN: gesture-logger

TUPLE: gesture-logger < gadget stream ;

: <gesture-logger> ( stream -- gadget )
    \ gesture-logger new-gadget
    swap >>stream
    { 100 100 } >>dim
    black solid-interior ;

M: gesture-logger handle-gesture
    over T{ button-down } = [ dup request-focus ] when
    stream>> [ . ] with-output-stream*
    t ;

M: gesture-logger user-input*
    stream>> [
        "User input: " write print
    ] with-output-stream* t ;

: gesture-logger ( -- )
    [
        <pane> t >>scrolls? dup <scroller>
        "Gesture log" open-window
        <pane-stream> <gesture-logger>
        "Gesture input" open-window
    ] with-ui ;

MAIN: gesture-logger
