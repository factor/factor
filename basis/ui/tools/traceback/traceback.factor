! Copyright (C) 2006, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays fonts inspector kernel models
models.arrow prettyprint sequences ui.commands ui.gadgets
ui.gadgets.labeled ui.gadgets.panes ui.gadgets.scrollers
ui.gadgets.status-bar ui.gadgets.tables ui.gadgets.toolbar
ui.gadgets.tracks ui.gestures ui.theme ui.tools.common ;
QUALIFIED-WITH: ui.tools.inspector i
IN: ui.tools.traceback

TUPLE: stack-entry object string ;

: <stack-entry> ( object -- stack-entry )
    dup unparse-short stack-entry boa ;

SINGLETON: stack-entry-renderer

M: stack-entry-renderer row-columns drop string>> 1array ;

M: stack-entry-renderer row-value drop object>> ;

: <stack-table> ( model -- table )
    [ [ <stack-entry> ] map ] <arrow> stack-entry-renderer <table>
        10 >>min-rows
        10 >>max-rows
        40 >>min-cols
        40 >>max-cols
        monospace-font >>font
        [ i:inspector ] >>action
        t >>single-click? ;

: <stack-display> ( model quot title color -- gadget )
    [ '[ dup _ when ] <arrow> <stack-table> margins <scroller> white-interior ] 2dip
    <colored-labeled-gadget> ;

: <callstack-display> ( model -- gadget )
    [ [ call>> callstack. ] when* ]
    <pane-control> t >>scrolls? margins <scroller> white-interior
    "Call stack" call-stack-color <colored-labeled-gadget> ;

: <datastack-display> ( model -- gadget )
    [ data>> ] "Data stack" data-stack-color <stack-display> ;

: <retainstack-display> ( model -- gadget )
    [ retain>> ] "Retain stack" retain-stack-color <stack-display> ;

TUPLE: traceback-gadget < tool ;

: <traceback-gadget> ( model -- gadget )
    [
        vertical traceback-gadget new-track
        with-lines
    ] dip
    [ >>model ]
    [
        [ vertical <track> with-lines ] dip
        [
            [ horizontal <track> with-lines ] dip
            [ <datastack-display> 1/2 track-add ]
            [ <retainstack-display> 1/2 track-add ] bi
            1/3 track-add
        ]
        [ <callstack-display> 2/3 track-add ] bi
         1 track-add
    ] bi
    add-toolbar ;

: variables ( traceback -- )
    model>> [ dup [ name>> vars-in-scope ] when ] <arrow> i:inspect-model ;

: traceback-window ( continuation -- )
    <model> <traceback-gadget> "Traceback" open-status-window ;

: inspect-continuation ( traceback -- )
    control-value i:inspector ;

traceback-gadget "toolbar" f {
    { T{ key-down f f "v" } variables }
    { T{ key-down f f "n" } inspect-continuation }
} define-command-map
