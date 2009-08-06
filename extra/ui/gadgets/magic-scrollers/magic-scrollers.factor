! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math models sequences
ui.gadgets ui.gadgets.scrollers ui.gadgets.sliders ;
IN: ui.gadgets.magic-scrollers

TUPLE: magic-slider < slider ;
: <magic-slider> ( range orientation -- slider ) magic-slider new-slider ;
: get-dim ( orientation dims -- dim )
    swap {
        { horizontal [ first ] }
        { vertical [ second ] }
    } case ;

! do this with pref-dim*, not draw-gadget
M: magic-slider model-changed [ call-next-method ] 2keep swap value>>
    [ second ] [ fourth ] bi < [ show-gadget ] [ hide-gadget ] if ;

TUPLE: magic-scroller < scroller ;
: <magic-scroller> ( gadget -- scroller ) magic-scroller new-scroller ;
M: magic-scroller (build-children) <magic-slider> ;