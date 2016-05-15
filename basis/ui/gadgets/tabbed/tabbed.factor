! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors.constants kernel models sequences
ui.gadgets ui.gadgets.books ui.gadgets.borders
ui.gadgets.buttons ui.gadgets.buttons.private ui.gadgets.icons
ui.gadgets.packs ui.gadgets.tracks ui.pens ui.theme.images ;
IN: ui.gadgets.tabbed

TUPLE: tabbed-gadget < track tabs book ;

<PRIVATE

: <lip> ( -- gadget )
    "active-tab-lip" theme-image <icon> ;

CONSTANT: button-background COLOR: FactorTan
CONSTANT: active-tab-background COLOR: FactorDarkTan

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
