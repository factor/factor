! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors continuations kernel models namespaces arrays
fry prettyprint ui ui.commands ui.gadgets ui.gadgets.labelled assocs
ui.gadgets.tracks ui.gadgets.buttons ui.gadgets.panes
ui.gadgets.status-bar ui.gadgets.scrollers
ui.gadgets.tables ui.gestures sequences inspector
models.filter fonts ;
QUALIFIED-WITH: ui.tools.inspector i
IN: ui.tools.traceback

TUPLE: stack-entry object string ;

: <stack-entry> ( object -- stack-entry )
    dup unparse-short stack-entry boa ;

SINGLETON: stack-entry-renderer

M: stack-entry-renderer row-columns drop string>> 1array ;

M: stack-entry-renderer row-value drop object>> ;

: <stack-table> ( model -- table )
    [ [ <stack-entry> ] map ] <filter> <table>
        monospace-font >>font
        [ i:inspector ] >>action
        stack-entry-renderer >>renderer
        t >>single-click? ;

: <stack-display> ( model quot title -- gadget )
    [ '[ dup _ when ] <filter> <stack-table> <scroller> ] dip
    <labelled-gadget> ;

: <callstack-display> ( model -- gadget )
    [ [ call>> callstack. ] when* ]
    t "Call stack" <labelled-pane> ;

: <datastack-display> ( model -- gadget )
    [ data>> ] "Data stack" <stack-display> ;

: <retainstack-display> ( model -- gadget )
    [ retain>> ] "Retain stack" <stack-display> ;

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