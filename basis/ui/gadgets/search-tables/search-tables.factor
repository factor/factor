! Copyright (C) 2008, 2009 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit kernel models
models.search ui.gadgets ui.gadgets.borders ui.gadgets.buttons
ui.gadgets.editors ui.gadgets.scrollers ui.gadgets.tables
ui.gadgets.tracks ui.gestures ui.tools.common ;
IN: ui.gadgets.search-tables

TUPLE: search-table < track table field ;

: find-search-table ( gadget -- search-table/f )
    [ search-table? ] find-parent ;

TUPLE: search-field < track field ;

: clear-search-field ( search-field -- )
    field>> editor>> clear-editor ;

: <clear-button> ( search-field -- button )
    [ "ⓧ" ] dip '[ drop _ clear-search-field ] <roll-button> ;

: <search-field> ( model -- gadget )
    horizontal search-field new-track
        1 >>fill
        { 5 5 } >>gap
        0 >>align
        swap <model-field> 10 >>min-cols "Search" >>default-text
        white-interior
        [ >>field ] keep 1 track-add
        dup <clear-button> f track-add ;

M: search-field focusable-child* field>> ;

: pass-to-table ( gesture gadget -- ? )
    find-search-table table>> handle-gesture ;

M: search-field handle-gesture
    over key-gesture? [
        { [ pass-to-table ] [ call-next-method ] } 2&&
    ] [ call-next-method ] if ;

:: <search-table> ( values renderer quot -- gadget )
    f <model> :> search
    vertical search-table new-track
        values >>model
        search <search-field> >>field
        dup field>> { 2 2 } <filled-border> f track-add
        values search quot <string-search>
        renderer <table> f >>takes-focus? >>table
        dup table>> white-interior <scroller> 1 track-add ; inline

M: search-table model-changed
    nip field>> clear-search-field ;

M: search-table focusable-child* field>> ;
