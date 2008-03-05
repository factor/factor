! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations kernel models namespaces prettyprint ui
ui.commands ui.gadgets ui.gadgets.labelled assocs
ui.gadgets.tracks ui.gadgets.buttons ui.gadgets.panes
ui.gadgets.status-bar ui.gadgets.scrollers
ui.gestures sequences hashtables inspector ;
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

TUPLE: traceback-gadget ;

M: traceback-gadget pref-dim* drop { 550 600 } ;

: <traceback-gadget> ( model -- gadget )
    { 0 1 } <track> traceback-gadget construct-control [
        [
            [
                g gadget-model <datastack-display> 1/2 track,
                g gadget-model <retainstack-display> 1/2 track,
            ] { 1 0 } make-track 1/3 track,
            g gadget-model <callstack-display> 2/3 track,
            toolbar,
        ] with-gadget
    ] keep ;

: <namestack-display> ( model -- gadget )
    [ [ continuation-name namestack. ] when* ]
    <pane-control> ;

TUPLE: variables-gadget ;

: <variables-gadget> ( model -- gadget )
    <namestack-display> <scroller>
    variables-gadget construct-empty
    [ set-gadget-delegate ] keep ;

M: variables-gadget pref-dim* drop { 400 400 } ;

: variables ( traceback -- )
    gadget-model <variables-gadget>
    "Dynamic variables" open-status-window ;

: traceback-window ( continuation -- )
    <model> <traceback-gadget> "Traceback" open-window ;
