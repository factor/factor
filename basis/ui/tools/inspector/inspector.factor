! Copyright (C) 2006, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes combinators fonts
formatting hashtables inspector io io.styles kernel math
math.parser math.vectors mirrors models models.arrow namespaces
prettyprint sequences sorting strings ui ui.commands ui.gadgets
ui.gadgets.labeled ui.gadgets.panes ui.gadgets.scrollers
ui.gadgets.status-bar ui.gadgets.tables
ui.gadgets.tables.private ui.gadgets.toolbar ui.gadgets.tracks
ui.gestures ui.operations ui.theme ui.tools.browser
ui.tools.common ui.tools.inspector.slots unicode ;
IN: ui.tools.inspector

TUPLE: inspector-gadget < tool table ;

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
            {
                [
                    [
                        [ "Class:" write ] with-cell
                        [ class-of pprint ] with-cell
                    ] with-row
                ]
                [
                    [
                        [ "Object:" write ] with-cell
                        [ pprint-short ] with-cell
                    ] with-row
                ]
                [
                    [
                        [ "Summary:" write ] with-cell
                        [ print-summary ] with-cell
                    ] with-row
                ]
                [
                    content-gadget [
                        [
                            [ "Content:" write ] with-cell
                            [ output-stream get write-gadget ] with-cell
                        ] with-row
                    ] when*
                ]
            } cleave
        ] tabular-output
    ] <pane-control> ;

GENERIC: make-slot-descriptions ( obj -- seq )

M: object make-slot-descriptions
    make-mirror [ <slot-description> ] { } assoc>map ;

M: string make-slot-descriptions
    [
        swap [ dup number>string ] dip dup
        dup unicode:printable? [ 1string ] [
            dup 0xff <= [
                H{
                    { CHAR: \a "\\a" }
                    { CHAR: \b "\\b" }
                    { CHAR: \e "\\e" }
                    { CHAR: \f "\\f" }
                    { CHAR: \n "\\n" }
                    { CHAR: \r "\\r" }
                    { CHAR: \t "\\t" }
                    { CHAR: \v "\\v" }
                    { CHAR: \0 "\\0" }
                } ?at [ "\\x%02x" sprintf ] unless
            ] [
                "\\u{%x}" sprintf
            ] if
        ] if slot-description boa
    ] { } map-index-as ;

M: hashtable make-slot-descriptions
    call-next-method [ key-string>> ] sort-by ;

TUPLE: inspector-table < table ;

! Improve performance for big arrays or large hashtables by
! only calculating column width for the longest key.
M: inspector-table compute-column-widths
    dup rows>> [ drop 0 { } ] [
        [ drop gap>> ]
        [ initial-widths ]
        [ keys longest "" 2array row-column-widths ] 2tri
        vmax [ compute-total-width ] keep
    ] if-empty ;

: <inspector-table> ( model -- table )
    [ make-slot-descriptions ] <arrow> inspector-renderer
    inspector-table new-table
        [ invoke-primary-operation ] >>action
        monospace-font >>font
        line-color >>column-line-color
        6 >>gap
        15 >>min-rows
        15 >>max-rows
        40 >>min-cols
        40 >>max-cols ;

: <inspector-gadget> ( model -- gadget )
    vertical inspector-gadget new-track with-lines
        add-toolbar
        swap >>model
        dup model>> <inspector-table> >>table
        dup model>> <summary-gadget> margins white-interior
        "Object" object-color <colored-labeled-gadget> f track-add
        dup table>> <scroller> margins white-interior
        "Contents" contents-color <colored-labeled-gadget> 1 track-add ;

M: inspector-gadget focusable-child*
    table>> ;

: com-refresh ( inspector -- )
    model>> notify-connections ;

: com-push ( inspector -- obj )
    control-value ;

\ com-push H{ { +listener+ t } } define-command

: com-edit-slot ( inspector -- )
    [ close-window ] swap
    [ '[ _ com-refresh ] ]
    [ control-value make-mirror ]
    [ table>> (selected-row) ] tri [
        [ key>> ] [ key-string>> ] bi
        slot-editor-window
    ] [ 4drop ] if ;

: inspector-help ( -- ) "ui-inspector" com-browse ;

\ inspector-help H{ { +nullary+ t } } define-command

inspector-gadget "toolbar" f {
    { T{ key-down f f "r" } com-refresh }
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

inspector-gadget default-font-size { 46 33 } n*v set-tool-dim
