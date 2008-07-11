! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations kernel models namespaces
prettyprint ui ui.commands ui.gadgets ui.gadgets.labelled assocs
ui.gadgets.tracks ui.gadgets.buttons ui.gadgets.panes
ui.gadgets.status-bar ui.gadgets.scrollers ui.gestures sequences
hashtables inspector ;
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

TUPLE: traceback-gadget < track ;

M: traceback-gadget pref-dim* drop { 550 600 } ;

: <traceback-gadget> ( model -- gadget )
    { 0 1 } traceback-gadget new-track
        swap >>model
    [
        g model>>
        [
            [
                [ <datastack-display> 1/2 track, ]
                [ <retainstack-display> 1/2 track, ]
                bi
            ] { 1 0 } make-track 1/3 track,
        ]
        [ <callstack-display> 2/3 track, ] bi
        toolbar,
    ] make-gadget ;

: <namestack-display> ( model -- gadget )
    [ [ continuation-name namestack. ] when* ]
    <pane-control> ;

: <variables-gadget> ( model -- gadget )
    <namestack-display> { 400 400 } <limited-scroller> ;

: variables ( traceback -- )
    gadget-model <variables-gadget>
    "Dynamic variables" open-status-window ;

: traceback-window ( continuation -- )
    <model> <traceback-gadget> "Traceback" open-window ;
