! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors inspector namespaces kernel models fry
models.filter prettyprint sequences mirrors assocs classes
io io.styles arrays hashtables math.order sorting refs fonts
ui.tools.browser ui.commands ui.operations ui.gadgets ui.gadgets.panes
ui.gadgets.scrollers ui.gadgets.slots ui.gadgets.tracks
ui.gestures ui.gadgets.buttons ui.gadgets.tables
ui.gadgets.status-bar ui.gadgets.labeled
ui.tools.common ui ;
IN: ui.tools.inspector

TUPLE: inspector-gadget < tool table ;

{ 500 300 } inspector-gadget set-tool-dim

TUPLE: slot-description key key-string value value-string ;

: <slot-description> ( key value -- slot-description )
    [ dup unparse-short ] bi@ slot-description boa ;

SINGLETON: inspector-renderer

M: inspector-renderer row-columns
    drop [ key-string>> ] [ value-string>> ] bi 2array ;

M: inspector-renderer row-value
    drop value>> ;

M: inspector-renderer column-titles
    drop { "Key" "Value" } ;

: <summary-gadget> ( model -- gadget )
    [
        standard-table-style [
            [
                [
                    [ "Class:" write ] with-cell
                    [ class . ] with-cell
                ] with-row
            ]
            [
                [
                    [ "Object:" write ] with-cell
                    [ short. ] with-cell
                ] with-row
            ]
            [
                [
                    [ "Summary:" write ] with-cell
                    [ summary. ] with-cell
                ] with-row
            ] tri
        ] tabular-output
    ] <pane-control> ;

GENERIC: make-slot-descriptions ( obj -- seq )

M: object make-slot-descriptions
    make-mirror [ <slot-description> ] { } assoc>map ;

M: hashtable make-slot-descriptions
    call-next-method [ [ key-string>> ] compare ] sort ;

: <inspector-table> ( model -- table )
    [ make-slot-descriptions ] <filter> inspector-renderer <table>
        [ dup primary-operation invoke-command ] >>action
        monospace-font >>font ;

: <inspector-gadget> ( model -- gadget )
    vertical inspector-gadget new-track
        { 3 3 } >>gap
        add-toolbar
        swap >>model
        dup model>> <inspector-table> >>table
        dup model>> <summary-gadget> "Object" <labeled-gadget> f track-add
        dup table>> <scroller> "Contents" <labeled-gadget> 1 track-add ;

M: inspector-gadget focusable-child*
    table>> ;

: com-refresh ( inspector -- )
    model>> notify-connections ;

: com-push ( inspector -- obj )
    control-value ;

\ com-push H{ { +listener+ t } } define-command

: slot-editor-window ( close-hook update-hook assoc key key-string -- )
    [ <value-ref> <slot-editor> ] [ "Slot editor: " prepend ] bi*
    open-window ;

: com-edit-slot ( inspector -- )
    [ close-window ] swap
    [ '[ _ com-refresh ] ]
    [ control-value make-mirror ]
    [ table>> (selected-row) ] tri [
        [ key>> ] [ key-string>> ] bi
        slot-editor-window
    ] [ 2drop 2drop ] if ;

: inspector-help ( -- ) "ui-inspector" com-follow ;

\ inspector-help H{ { +nullary+ t } } define-command

inspector-gadget "toolbar" f {
    { T{ update-object } com-refresh }
    { T{ key-down f f "p" } com-push }
    { T{ key-down f f "e" } com-edit-slot }
    { T{ key-down f f "F1" } inspector-help }
} define-command-map

inspector-gadget "multi-touch" f {
    { up-action com-refresh }
} define-command-map

: inspect-model ( model -- )
    <inspector-gadget> "Inspector" open-status-window ;

: inspector ( obj -- )
    <model> inspect-model ;
