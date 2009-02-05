! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations kernel models namespaces
prettyprint ui ui.commands ui.gadgets ui.gadgets.labelled assocs
ui.gadgets.tracks ui.gadgets.buttons ui.gadgets.panes
ui.gadgets.status-bar ui.gadgets.scrollers
ui.gestures sequences inspector models.filter ;
QUALIFIED-WITH: ui.tools.inspector i
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
    [ vertical traceback-gadget new-track ] dip
    [ >>model ]
    [
        [ horizontal <track> ] dip
        [ <datastack-display> 1/2 track-add ]
        [ <retainstack-display> 1/2 track-add ] bi
        1/3 track-add
    ]
    [ <callstack-display> 2/3 track-add ] tri
    add-toolbar ;

: variables ( traceback -- )
    model>> [ dup [ name>> vars-in-scope ] when ] <filter> i:inspect-model ;

: traceback-window ( continuation -- )
    <model> <traceback-gadget> "Traceback" open-status-window ;

: inspect-continuation ( traceback -- )
    control-value i:inspector ;

traceback-gadget "toolbar" f {
    { T{ key-down f f "v" } variables }
    { T{ key-down f f "n" } inspect-continuation }
} define-command-map