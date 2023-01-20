! Copyright (C) 2006, 2009 Slava Pestov, 2015 Nicolas Pénet.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel system ui.gadgets ui.gadgets.borders
ui.gadgets.labels ui.gadgets.packs ui.gadgets.tracks
ui.pens.gradient ui.pens.solid ui.theme ;
IN: ui.gadgets.labeled

TUPLE: labeled-gadget < track content ;

<PRIVATE

M: labeled-gadget focusable-child* content>> ;

: <title-bar> ( title -- title-bar )
    >label [ t >>bold? ] change-font
    { 0 4 } <border>
    title-bar-gradient <gradient> >>interior ;

PRIVATE>

: <labeled-gadget> ( content title -- labeled )
    vertical labeled-gadget new-track
        swap <title-bar> f track-add
        swap [ >>content ] [ 1 track-add ] bi ;

: <colored-labeled-gadget> ( content title color -- labeled )
    [ <labeled-gadget> ] dip <solid> >>interior { 0 3 } >>gap ;

: <framed-labeled-gadget> ( content title color -- labeled )
    <colored-labeled-gadget> labeled-border-color <solid> >>boundary ;
