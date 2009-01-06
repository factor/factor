! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors inspector namespaces kernel models
models.filter prettyprint sequences mirrors assocs classes
io io.styles
ui.tools.browser ui.commands ui.gadgets ui.gadgets.panes
ui.gadgets.scrollers ui.gadgets.slots ui.gadgets.tracks
ui.gestures ui.gadgets.buttons ui.gadgets.tables
ui.gadgets.status-bar ui.gadgets.theme ui.gadgets.labelled ;
IN: ui.tools.inspector

TUPLE: inspector-gadget < track table ;

SINGLETON: inspector-renderer

M: inspector-renderer row-columns
    drop [ unparse-short ] map ;

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

DEFER: inspector-window

: <inspector-table> ( model -- table )
    [ make-mirror >alist ] <filter> <table>
        [ second inspector-window ] >>action
        inspector-renderer >>renderer
        monospace-font >>font ;

: <inspector-gadget> ( obj -- gadget )
    { 0 1 } inspector-gadget new-track
        add-toolbar
        swap <model> >>model
        dup model>> <inspector-table> >>table
        dup model>> <summary-gadget> "Object" <labelled-gadget> f track-add
        dup table>> <scroller> "Contents" <labelled-gadget> 1 track-add ;

M: inspector-gadget focusable-child*
    table>> ;

M: inspector-gadget pref-dim*
    drop { 500 300 } ;

: com-refresh ( inspector -- )
    model>> notify-connections ;

: com-push ( inspector -- obj )
    control-value ;

\ com-push H{ { +listener+ t } } define-command

: inspector-help ( -- ) "ui-inspector" com-follow ;

\ inspector-help H{ { +nullary+ t } } define-command

inspector-gadget "toolbar" f {
    { T{ update-object } com-refresh }
    { T{ key-down f f "p" } com-push }
    { T{ key-down f f "F1" } inspector-help }
} define-command-map

: inspector-window ( obj -- )
    <inspector-gadget> "Inspector" open-status-window ;