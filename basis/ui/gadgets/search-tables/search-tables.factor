! Copyright (C) 2008, 2009 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel delegate fry sequences models models.search
models.delay calendar locals ui.pens ui.pens.image ui.gadgets.editors
ui.gadgets.labels ui.gadgets.scrollers ui.gadgets.tables
ui.gadgets.tracks ui.gadgets.borders ui.gadgets.buttons ui.gadgets ;
IN: ui.gadgets.search-tables

TUPLE: search-field < track field ;

: clear-search-field ( search-field -- )
    field>> editor>> clear-editor ;

: <clear-button-pen> ( -- pen )
    "clear-button" theme-image <image-pen> dup
    "clear-button-clicked" theme-image <image-pen> dup dup <button-pen> ;

: <clear-button> ( search-field -- button )
    [ f ] dip '[ drop _ clear-search-field ] <button>
    <clear-button-pen> >>interior
    dup dup interior>> pen-pref-dim >>min-dim ;

: <search-field> ( model -- gadget )
    horizontal search-field new-track
        { 5 5 } >>gap
        +baseline+ >>align
        swap <model-field> 10 >>min-cols >>field
        dup field>> "Search:" label-on-left 1 track-add
        dup <clear-button> f track-add ;

TUPLE: search-table < track table field ;

! A protocol with customizable slots
SLOT-PROTOCOL: table-protocol
renderer
action
hook
font
gap
selection-color
focus-border-color
mouse-color
column-line-color
selection-required?
single-click?
selected-value
min-rows
min-cols
max-rows
max-cols ;

CONSULT: table-protocol search-table table>> ;

:: <search-table> ( values renderer quot -- gadget )
    f <model> :> search
    vertical search-table new-track
        values >>model
        search <search-field> >>field
        dup field>> { 2 2 } <filled-border> f track-add
        values search 500 milliseconds <delay> quot <search>
        renderer <table> >>table
        dup table>> <scroller> 1 track-add ;

M: search-table model-changed
    nip field>> clear-search-field ;