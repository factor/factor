! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: ui.pens ui.gadgets.tracks ui.gadgets.buttons
ui.gadgets.buttons.private ui.gadgets.books ui.gadgets.packs
ui.gadgets.borders ui.gadgets.icons ui.gadgets ui.pens.image
sequences models accessors kernel colors colors.constants ;
IN: ui.gadgets.tabbed

TUPLE: tabbed-gadget < track tabs book ;

<PRIVATE

: <lip> ( -- gadget )
    "active-tab-lip" theme-image <icon> ;

CONSTANT: active-tab-background
    T{ rgba
        f
        0.6745098039215687
        0.6549019607843137
        0.5764705882352941
        1.0
    }

: <tab-pen> ( -- pen )
    "inactive-tab" button-background f <border-button-state-pen> dup dup
    "active-tab" active-tab-background f <border-button-state-pen> dup
    <button-pen> ;

: tab-theme ( gadget -- gadget )
    horizontal >>orientation
    <tab-pen> >>interior
    dup dup interior>> pen-pref-dim >>min-dim
    { 30 0 } >>size ; inline

: <tab> ( value model label -- gadget )
    <radio-control> tab-theme ;

: add-tab/book ( tabbed child -- tabbed )
    [ dup book>> ] dip add-gadget drop ;

: add-tab/button ( tabbed label -- tabbed )
    [ [ dup tabs>> dup children>> length ] [ model>> ] bi ] dip
    <tab> add-gadget drop ;

PRIVATE>

: <tabbed-gadget> ( -- gadget )
    vertical tabbed-gadget new-track
        0 <model> >>model
        <shelf> >>tabs
        horizontal <track>
            over tabs>> f track-add
            <lip> 1 track-add
        f track-add
        dup model>> <empty-book> >>book
        dup book>> { 3 3 } <filled-border> 1 track-add ;

: add-tab ( tabbed child label -- tabbed )
    [ add-tab/book ] [ add-tab/button ] bi* ;
