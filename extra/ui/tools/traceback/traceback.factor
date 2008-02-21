! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations kernel models namespaces prettyprint ui
ui.commands ui.gadgets ui.gadgets.labelled assocs
ui.gadgets.tracks ui.gestures sequences hashtables inspector ;
IN: ui.tools.traceback

: <callstack-display> ( model -- gadget )
    [ [ continuation-call callstack. ] when* ]
    t "Call stack" <labelled-pane> ;

: <datastack-display> ( model -- gadget )
    [ [ continuation-data stack. ] when* ]
    t "Data stack" <labelled-pane> ;

: <retainstack-display> ( model -- gadget )
    [ [ continuation-retain stack. ] when* ]
    t "Retain stack" <labelled-pane> ;

: <namestack-display> ( model -- gadget )
    [ [ continuation-name namestack. ] when* ]
    f "Dynamic variables" <labelled-pane> ;

TUPLE: traceback-gadget ;

M: traceback-gadget pref-dim* drop { 550 600 } ;

: <traceback-gadget> ( model -- gadget )
    { 0 1 } <track> traceback-gadget construct-control [
        [
            [
                g gadget-model <datastack-display> 1/2 track,
                g gadget-model <retainstack-display> 1/2 track,
            ] { 1 0 } make-track 1/5 track,
            g gadget-model <callstack-display> 2/5 track,
            g gadget-model <namestack-display> 2/5 track,
        ] with-gadget
    ] keep ;

: traceback-window ( continuation -- )
    <model> <traceback-gadget> "Traceback" open-window ;
