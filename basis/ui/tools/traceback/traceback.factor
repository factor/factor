! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations kernel models namespaces
prettyprint ui ui.commands ui.gadgets ui.gadgets.labelled assocs
ui.gadgets.tracks ui.gadgets.buttons ui.gadgets.panes
ui.gadgets.status-bar ui.gadgets.scrollers ui.tools.inspector
ui.gestures sequences hashtables inspector ;
IN: ui.tools.traceback

: <callstack-display> ( model -- gadget )
    [ [ call>> callstack. ] when* ]
    t "Call stack" <labelled-pane> ;

: <datastack-display> ( model -- gadget )
    [ [ data>> stack. ] when* ]
    t "Data stack" <labelled-pane> ;

: <retainstack-display> ( model -- gadget )
    [ [ retain>> stack. ] when* ]
    t "Retain stack" <labelled-pane> ;

TUPLE: traceback-gadget < track ;

M: traceback-gadget pref-dim* drop { 550 600 } ;

: <traceback-gadget> ( model -- gadget )
    vertical traceback-gadget new-track
        swap >>model

    dup model>>
        horizontal <track>
            over <datastack-display> 1/2 track-add
            swap <retainstack-display> 1/2 track-add
        1/3 track-add

    dup model>> <callstack-display> 2/3 track-add

    add-toolbar ;

: <namestack-display> ( model -- gadget )
    [ [ name>> namestack. ] when* ]
    <pane-control> ;

: <variables-gadget> ( model -- gadget )
    <namestack-display>
    <limited-scroller>
        { 400 400 } >>min-dim
        { 400 400 } >>max-dim ;

: variables ( traceback -- )
    model>> <variables-gadget>
    "Dynamic variables" open-status-window ;

: traceback-window ( continuation -- )
    <model> <traceback-gadget> "Traceback" open-status-window ;

: inspect-continuation ( traceback -- )
    control-value inspector ;

traceback-gadget "toolbar" f {
    { T{ key-down f f "v" } variables }
    { T{ key-down f f "n" } inspect-continuation }
} define-command-map