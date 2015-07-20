! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors.constants fonts kernel ui.gadgets
ui.gadgets.borders ui.gadgets.corners ui.gadgets.frames
ui.gadgets.grids ui.gadgets.labels ui.gadgets.lines
ui.gadgets.tracks ui.tools.common ui.pens.gradient ui.pens.image ui.render ;
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

: <labeled-gadget-old> ( gadget title -- newgadget )
    labeled-gadget "labeled-block" [
        pick >>content
        /-FOO-\
        |-----|
        \-----/
    ] make-corners ;



<PRIVATE

CONSTANT: title-bar-gradient { COLOR: white COLOR: grey90 }

: add-title-bar ( title track -- track )
    swap >label
    [ t >>bold? ] change-font
    { 0 5 } <border>
    title-bar-gradient <gradient> >>interior
    f track-add ;

: add-content ( content track -- track )
    swap white-interior 1 track-add ;

PRIVATE>

: <labeled-gadget> ( gadget title -- newgadget )
    vertical <track> with-lines
    add-title-bar 
    add-content ;
