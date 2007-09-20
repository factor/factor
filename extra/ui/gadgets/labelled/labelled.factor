! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ui.gadgets.buttons ui.gadgets.borders
ui.gadgets.labels ui.gadgets.panes ui.gadgets.scrollers
ui.gadgets.tracks ui.gadgets.theme ui.gadgets.frames
ui.gadgets.grids io kernel math models namespaces prettyprint
sequences sequences words tuples ui.gadgets ui.render colors ;
IN: ui.gadgets.labelled

TUPLE: labelled-gadget content ;

: <labelled-gadget> ( gadget title -- newgadget )
    labelled-gadget construct-empty
    [
        <label> dup reverse-video-theme f track,
        g-> set-labelled-gadget-content 1 track,
    ] { 0 1 } build-track ;

M: labelled-gadget focusable-child* labelled-gadget-content ;

: <labelled-scroller> ( gadget title -- gadget )
    >r <scroller> r> <labelled-gadget> ;

: <labelled-pane> ( model quot title -- gadget )
    >r <pane-control> t over set-pane-scrolls? r>
    <labelled-scroller> ;

: <close-box> ( quot -- button/f )
    gray close-box <polygon-gadget> swap <bevel-button> ;

: title-theme ( gadget -- )
    { 1 0 } over set-gadget-orientation
    T{ gradient f {
        { 0.65 0.65 1.0 1.0 }
        { 0.65 0.45 1.0 1.0 }
    } } swap set-gadget-interior ;

: <title-label> <label> dup title-theme ;

: <title-bar> ( title quot -- gadget )
    [
        [ <close-box> @left frame, ] when*
        <title-label> @center frame,
    ] make-frame ;

TUPLE: closable-gadget content ;

: find-closable-gadget ( parent -- child )
    [ [ closable-gadget? ] is? ] find-parent ;

: <closable-gadget> ( gadget title quot -- gadget )
    closable-gadget construct-empty
    [
        <title-bar> @top frame,
        g-> set-closable-gadget-content @center frame,
    ] build-frame ;

M: closable-gadget focusable-child* closable-gadget-content ;

: build-closable-gadget ( tuple quot title -- tuple )
    pick >r >r with-gadget
    r> [ find-closable-gadget unparent ] <closable-gadget> r>
    [ set-gadget-delegate ] keep ; inline
