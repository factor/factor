! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel models sequences ui.gadgets
ui.gadgets.books ui.gadgets.borders ui.gadgets.buttons.private
ui.gadgets.packs ui.gadgets.toolbar.private ui.gadgets.tracks
ui.pens.solid ui.theme ui.tools.common ;
IN: ui.gadgets.tabbed

TUPLE: tabbed-gadget < track tabs book ;

<PRIVATE

: <tab> ( value model label -- gadget )
    <radio-control> toolbar-button-theme ;

: add-tab/book ( tabbed child -- tabbed )
    [ dup book>> ] dip add-gadget drop ;

: add-tab/button ( tabbed label -- tabbed )
    [ [ dup tabs>> dup children>> length ] [ model>> ] bi ] dip
    <tab> add-gadget drop ;

PRIVATE>

: <tabbed-gadget> ( -- gadget )
    vertical tabbed-gadget new-track
        0 <model> >>model
        toolbar-button-pressed-background <solid> >>interior
        { 0 3 } >>gap
        <shelf> toolbar-background <solid> >>interior >>tabs
        horizontal <track>
            over tabs>> 1 track-add
        f track-add
        dup model>> <empty-book> >>book
        dup book>> { 5 5 } <filled-border> white-interior 1 track-add ;

: add-tab ( tabbed child label -- tabbed )
    [ add-tab/book ] [ add-tab/button ] bi* ;
