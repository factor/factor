! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays sequences sorting assocs colors.constants combinators
combinators.smart compiler.errors compiler.units fonts kernel io.pathnames
math.parser math.order models models.arrow namespaces summary ui
ui.commands ui.gadgets ui.gadgets.tables ui.gadgets.tracks
ui.gestures ui.operations ui.tools.browser ui.tools.common
ui.gadgets.scrollers ;
IN: ui.tools.compiler-errors

TUPLE: error-list-gadget < tool table ;

SINGLETON: source-file-renderer

M: source-file-renderer row-columns
    drop [ first2 length number>string 2array ] [ { "All" "" } ] if* ;

M: source-file-renderer row-value
    drop first <pathname> ;

M: source-file-renderer column-titles
    drop { "File" "Errors" } ;

: <source-file-table> ( model -- table )
    [ group-by-source-file >alist sort-keys f prefix ] <arrow>
    source-file-renderer <table>
        [ invoke-primary-operation ] >>action
        COLOR: dark-gray >>column-line-color
        { 1 f } >>column-widths
        6 >>gap
        30 >>min-rows
        30 >>max-rows
        80 >>min-cols
        80 >>max-cols ;

SINGLETON: error-renderer

M: error-renderer row-columns
    drop [
        {
            [ file>> ]
            [ line#>> number>string ]
            [ word>> name>> ]
            [ error>> summary ]
        } cleave
    ] output>array ;

M: error-renderer row-value
    drop ;

M: error-renderer column-titles
    drop { "File" "Line" "Word" "Error" } ;

: <error-table> ( model -- table )
    [ [ [ [ file>> ] [ line#>> ] bi 2array ] compare ] sort ] <arrow>
    error-renderer <table>
        [ invoke-primary-operation ] >>action
        COLOR: dark-gray >>column-line-color
        6 >>gap
        30 >>min-rows
        30 >>max-rows
        80 >>min-cols
        80 >>max-cols ;

: <error-list-gadget> ( model -- gadget )
    vertical error-list-gadget new-track
        { 3 3 } >>gap
        swap <source-file-table> >>table
        dup table>> <scroller> 1/2 track-add ;

M: error-list-gadget focusable-child*
    table>> ;

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
    "Compiler errors" open-window ;