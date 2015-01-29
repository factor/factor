! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fonts kernel ui.gadgets ui.gadgets.borders
ui.gadgets.corners ui.gadgets.frames ui.gadgets.grids
ui.gadgets.labels ui.pens.image ui.render ;
IN: ui.gadgets.labeled

TUPLE: labeled-gadget < frame content ;

<PRIVATE

: <labeled-title> ( gadget -- label )
    >label
    [ panel-background-color font-with-background ] change-font
    { 0 2 } <border>
    "title-middle" corner-image
    <image-pen> t >>fill? >>interior ;

: /-FOO-\ ( title labeled -- labeled )
    "title-left" corner-icon @top-left grid-add
    swap <labeled-title> @top grid-add
    "title-right" corner-icon @top-right grid-add ;

M: labeled-gadget focusable-child* content>> ;

PRIVATE>

: <labeled-gadget> ( gadget title -- newgadget )
    labeled-gadget "labeled-block" [
        pick >>content
        /-FOO-\
        |-----|
        \-----/
    ] make-corners ;
