! Copyright (C) 2006, 2009 Slava Pestov, 2015 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors.constants fonts kernel ui.gadgets
ui.gadgets.borders ui.gadgets.colors ui.gadgets.corners ui.gadgets.frames
ui.gadgets.grids ui.gadgets.labels
ui.gadgets.tracks ui.gadgets.packs ui.tools.common 
ui.pens.gradient ui.pens.image ui.pens.solid ui.render ;
IN: ui.gadgets.labeled

TUPLE: labeled-gadget < track content color ;

<PRIVATE

M: labeled-gadget focusable-child* content>> ;

: add-title-bar ( title track -- track )
    swap >label
    [ t >>bold? ] change-font
    { 0 4 } <border>
    title-bar-gradient <gradient> >>interior
    f track-add ;

: add-content ( content track -- track )
    swap 1 track-add ;

: add-color-line ( color track -- track )
    <shelf> { 0 1.5 } <border>
    rot <solid> >>interior 
    f track-add ;

: add-content-area ( labeled -- labeled )
    [ ] [ content>> ] [ color>> ] tri
    vertical <track>
    add-color-line
    add-content
    1 track-add ;

PRIVATE>

: <labeled-gadget> ( gadget title color -- labeled )
    vertical labeled-gadget new-track with-lines
    swap >>color
    add-title-bar
    swap >>content
    add-content-area ;
    
: <framed-labeled-gadget> ( gadget title color -- labeled )
    <labeled-gadget>
    COLOR: grey85 <solid> >>boundary ;
