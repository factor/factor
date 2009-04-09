! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays sequences sorting assocs colors.constants
combinators combinators.smart combinators.short-circuit editors
compiler.errors compiler.units fonts kernel io.pathnames
stack-checker.errors math.parser math.order models models.arrow
models.search debugger namespaces summary locals ui ui.commands
ui.gadgets ui.gadgets.panes ui.gadgets.tables ui.gadgets.labeled
ui.gadgets.tracks ui.gestures ui.operations ui.tools.browser
ui.tools.common ui.gadgets.scrollers ui.tools.inspector
ui.gadgets.status-bar ui.operations ui.gadgets.buttons
ui.gadgets.borders ui.images ;
IN: ui.tools.compiler-errors

TUPLE: error-list-gadget < tool source-file error source-file-table error-table error-display ;

SINGLETON: source-file-renderer

M: source-file-renderer row-columns
    drop [ first2 length number>string 2array ] [ { "All" "" } ] if* ;

M: source-file-renderer row-value
    drop dup [ first <pathname> ] when ;

M: source-file-renderer column-titles
    drop { "File" "Errors" } ;

M: source-file-renderer column-alignment drop { 0 1 } ;

M: source-file-renderer filled-column drop 0 ;

: <source-file-model> ( model -- model' )
    [ group-by-source-file >alist sort-keys f prefix ] <arrow> ;

:: <source-file-table> ( error-list -- table )
    error-list model>> <source-file-model>
    source-file-renderer
    <table>
        [ invoke-primary-operation ] >>action
        COLOR: dark-gray >>column-line-color
        6 >>gap
        30 >>min-rows
        30 >>max-rows
        60 >>min-cols
        60 >>max-cols
        t >>selection-required?
        error-list source-file>> >>selected-value ;

SINGLETON: error-renderer

GENERIC: error-icon ( error -- icon )

: <error-icon> ( name -- image-name )
    "vocab:ui/tools/error-list/icons/" ".tiff" surround <image-name> ;

M: inference-error error-icon
    type>> {
        { +error+ [ "compiler-error" ] }
        { +warning+ [ "compiler-warning" ] }
    } case <error-icon> ;

M: object error-icon drop "HAI" ;

M: compiler-error error-icon error>> error-icon ;

M: error-renderer row-columns
    drop [
        {
            [ error-icon ]
            [ line#>> number>string ]
            [ word>> name>> ]
            [ error>> summary ]
        } cleave
    ] output>array ;

M: error-renderer prototype-row
    drop [ "compiler-error" <error-icon> "" "" "" ] output>array ;

M: error-renderer row-value
    drop ;

M: error-renderer column-titles
    drop { "" "Line" "Word" "Error" } ;

M: error-renderer column-alignment drop { 0 1 0 0 } ;

: sort-errors ( seq -- seq' )
    [ [ [ file>> ] [ line#>> ] bi 2array ] compare ] sort ;

: <error-table-model> ( error-list -- model )
    [ model>> [ values ] <arrow> ] [ source-file>> ] bi
    [ swap { [ drop not ] [ [ string>> ] [ file>> ] bi* = ] } 2|| ] <search>
    [ sort-errors ] <arrow> ;

:: <error-table> ( error-list -- table )
    error-list <error-table-model>
    error-renderer
    <table>
        [ invoke-primary-operation ] >>action
        COLOR: dark-gray >>column-line-color
        6 >>gap
        30 >>min-rows
        30 >>max-rows
        60 >>min-cols
        60 >>max-cols
        t >>selection-required?
        error-list error>> >>selected-value ;

TUPLE: error-display < track ;

: <error-display> ( error-list -- gadget )
    vertical error-display new-track
        add-toolbar
        swap error>> >>model
        dup model>> [ print-error ] <pane-control> <scroller> 1 track-add ;

: com-inspect ( error-display -- )
    model>> value>> inspector ;

: com-help ( error-display -- )
    model>> value>> error>> error-help-window ;

: com-edit ( error-display -- )
    model>> value>> edit-error ;

error-display "toolbar" f {
    { f com-inspect }
    { f com-help }
    { f com-edit }
} define-command-map

:: <error-list-gadget> ( model -- gadget )
    vertical error-list-gadget new-track
        model >>model
        f <model> >>source-file
        f <model> >>error
        dup <source-file-table> >>source-file-table
        dup <error-table> >>error-table
        dup <error-display> >>error-display
    :> error-list
    error-list vertical <track>
        { 5 5 } >>gap
        error-list source-file-table>> <scroller> "Source files" <labeled-gadget> 1/4 track-add
        error-list error-table>> <scroller> "Errors" <labeled-gadget> 1/2 track-add
        error-list error-display>> "Details" <labeled-gadget> 1/4 track-add
    { 5 5 } <filled-border> 1 track-add ;

M: error-list-gadget focusable-child*
    source-file-table>> ;

: error-list-help ( -- ) "ui-error-list" com-browse ;

\ error-list-help H{ { +nullary+ t } } define-command

error-list-gadget "toolbar" f {
    { T{ key-down f f "F1" } error-list-help }
} define-command-map

SYMBOL: compiler-error-model

compiler-error-model [ f <model> ] initialize

SINGLETON: updater

M: updater definitions-changed
    2drop
    compiler-errors get-global
    compiler-error-model get-global
    set-model ;

updater remove-definition-observer
updater add-definition-observer

: error-list-window ( -- )
    compiler-error-model get-global <error-list-gadget>
    "Compiler errors" open-status-window ;