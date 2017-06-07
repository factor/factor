! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes colors colors.constants
combinators fonts fry hashtables inspector io io.styles kernel
math math.order math.parser mirrors models models.arrow
namespaces prettyprint refs sequences sorting ui ui.commands
ui.gadgets ui.gadgets.buttons ui.gadgets.labeled
ui.gadgets.panes ui.gadgets.scrollers ui.gadgets.slots
ui.gadgets.status-bar ui.gadgets.tables
ui.gadgets.tables.private ui.gadgets.toolbar ui.gadgets.tracks
ui.gadgets.worlds ui.gestures ui.operations ui.theme
ui.theme.images ui.tools.browser ui.tools.common ;
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

M: hashtable make-slot-descriptions
    call-next-method [ key-string>> ] sort-with ;

! If model is a sequence, get its maximum index, measure its width
! and use that as the first column width (or the first column title
! width, whichever is greater). This improves performance when
! inspecting big arrays.
: first-column-width ( table model -- width )
    value>> dup sequence? [
        length 1 - 1array
    ] [
        make-mirror keys
    ] if [ unparse-short ] map
    over renderer>> column-titles first suffix
    row-column-widths supremum ;

: <inspector-table> ( model -- table )
    [
        [ make-slot-descriptions ] <arrow> inspector-renderer <table>
            [ invoke-primary-operation ] >>action
            line-color >>column-line-color
            6 >>gap
            15 >>min-rows
            15 >>max-rows
            40 >>min-cols
            40 >>max-cols
            monospace-font >>font
            dup
    ] keep first-column-width 0 2array >>fixed-column-widths ;

: <inspector-gadget> ( model -- gadget )
    vertical inspector-gadget new-track with-lines
        add-toolbar
        swap >>model
        dup model>> <inspector-table> >>table
        dup model>> <summary-gadget> margins white-interior "Object" object-color <labeled> f track-add
        dup table>> <scroller> margins white-interior "Contents" contents-color <labeled> 1 track-add ;

M: inspector-gadget focusable-child*
    table>> ;

: com-refresh ( inspector -- )
    model>> notify-connections ;

: com-push ( inspector -- obj )
    control-value ;

\ com-push H{ { +listener+ t } } define-command

: slot-editor-window ( close-hook update-hook assoc key key-string -- )
    [ <value-ref> <slot-editor> ]
    [
        <world-attributes>
            swap "Slot editor: " prepend >>title
            [ { dialog-window } append ] change-window-controls
    ] bi*
    open-status-window ;

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

inspector-gadget { 550 400 } set-tool-dim
