! Copyright (C) 2006, 2009 Slava Pestov, 2015 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors colors.constants kernel system ui.gadgets
ui.gadgets.borders ui.gadgets.labels ui.gadgets.packs
ui.theme ui.gadgets.tracks ui.pens.gradient
ui.pens.solid ui.tools.common ;
IN: ui.gadgets.labeled

TUPLE: labeled-gadget < track content color ;

<PRIVATE

M: labeled-gadget focusable-child* content>> ;

! gradients don't work as backgrounds on windows, see #152 and #1397
: title-bar-interior ( -- interior )
    os windows?
    [ toolbar-background <solid> ]
    [ title-bar-gradient <gradient> ]
    if ;

: add-title-bar ( title track -- track )
    swap >label
    [ t >>bold? ] change-font
    { 0 4 } <border>
    title-bar-interior >>interior
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

: <labeled> ( gadget title color -- labeled )
    vertical labeled-gadget new-track with-lines
    swap >>color
    add-title-bar
    swap >>content
    add-content-area ;

: <framed-labeled> ( gadget title color -- labeled )
    <labeled> labeled-border-color <solid> >>boundary ;

: <labeled-gadget> ( gadget title -- labeled )
    vertical labeled-gadget new-track with-lines
    add-title-bar
    swap [ >>content ] keep
    vertical <track>
    add-content
    { 5 5 } <border>
    content-background <solid> >>interior
    1 track-add
    labeled-border-color <solid> >>boundary
    { 3 3 } <border> ;
