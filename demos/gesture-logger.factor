! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel gadgets gadgets-panes gadgets-scrolling
gadgets-theme io prettyprint namespaces ;
IN: gesture-logger

TUPLE: gesture-logger stream ;

C: gesture-logger ( stream -- gadget )
    [ set-gesture-logger-stream ] keep
    dup delegate>gadget
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
    <scrolling-pane> dup <scroller> "Gesture log" open-window
    <pane-stream> <gesture-logger> gadget. ;

PROVIDE: demos/gesture-logger ;

MAIN: demos/gesture-logger gesture-logger ;
