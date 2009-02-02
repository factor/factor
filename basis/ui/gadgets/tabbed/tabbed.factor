! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: ui.gadgets.tracks ui.gadgets.buttons ui.gadgets.books
ui.gadgets.packs ui.gadgets sequences models accessors kernel ;
IN: ui.gadgets.tabbed

TUPLE: tabbed-gadget < track tabs book ;

: <tabbed-gadget> ( -- gadget )
    vertical tabbed-gadget new-track
        0 <model> >>model
        <shelf> >>tabs
        dup tabs>> f track-add
        dup model>> <empty-book> >>book
        dup book>> 1 track-add ;

: add-tab/book ( tabbed child -- tabbed )
    [ dup book>> ] dip add-gadget drop ;

: add-tab/button ( tabbed label -- tabbed )
    [ [ dup tabs>> dup children>> length ] [ model>> ] bi ] dip
    <toggle-button> add-gadget drop ;

: add-tab ( tabbed child label -- tabbed )
    [ add-tab/book ] [ add-tab/button ] bi* ;
