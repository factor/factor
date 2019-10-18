! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io kernel prettyprint colors.constants ui ui.gadgets
ui.gadgets.panes ui.gadgets.scrollers ui.gestures ui.pens.solid ;
IN: gesture-logger

TUPLE: gesture-logger < gadget stream ;

: <gesture-logger> ( stream -- gadget )
    \ gesture-logger new
    swap >>stream
    { 100 100 } >>dim
    COLOR: black <solid> >>interior ;

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
        { 450 500 } >>pref-dim
        "Gesture log" open-window
        <pane-stream> <gesture-logger>
        "Gesture input" open-window
    ] with-ui ;

MAIN: gesture-logger
