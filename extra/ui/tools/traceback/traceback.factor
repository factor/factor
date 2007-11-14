! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations kernel models namespaces prettyprint ui
ui.commands ui.gadgets ui.gadgets.labelled
ui.gadgets.tracks ui.gestures ;
IN: ui.tools.traceback

: <callstack-display> ( model -- )
    [ [ continuation-call callstack. ] when* ]
    "Call stack" <labelled-pane> ;

: <datastack-display> ( model -- )
    [ [ continuation-data stack. ] when* ]
    "Data stack" <labelled-pane> ;

: <retainstack-display> ( model -- )
    [ [ continuation-retain stack. ] when* ]
    "Retain stack" <labelled-pane> ;

TUPLE: traceback-gadget ;

M: traceback-gadget pref-dim* drop { 300 400 } ;

: <traceback-gadget> ( model -- gadget )
    { 0 1 } <track> traceback-gadget construct-control [
        [
            [
                g gadget-model <datastack-display> 1/2 track,
                g gadget-model <retainstack-display> 1/2 track,
            ] { 1 0 } make-track 1/3 track,
            g gadget-model <callstack-display> 2/3 track,
        ] with-gadget
    ] keep ;

: traceback-window ( continuation -- )
    <model> <traceback-gadget> "Traceback" open-window ;
