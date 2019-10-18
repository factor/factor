! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: arrays errors gadgets gadgets-buttons gadgets-borders
gadgets-labels gadgets-theme gadgets-panes gadgets-scrolling
gadgets-tracks generic hashtables io kernel math models
namespaces prettyprint queues sequences test threads help
sequences words timers ;

TUPLE: labelled-gadget content ;

C: labelled-gadget ( gadget title -- newgadget )
    [
        <label> dup reverse-video-theme f track,
        g-> set-labelled-gadget-content 1 track,
    ] { 0 1 } build-track ;

M: labelled-gadget focusable-child* labelled-gadget-content ;

: <labelled-pane> ( model quot title -- gadget )
    >r <pane-control> t over set-pane-scrolls? <scroller> r>
    <labelled-gadget> ;

: <close-box> ( quot -- button/f )
    gray close-box <polygon-gadget> swap <bevel-button> ;

: <title-label> <label> dup title-theme ;

: <title-bar> ( title quot -- gadget )
    [
        [ <close-box> @left grid, ] when*
        <title-label> @center grid,
    ] make-frame ;

TUPLE: closable-gadget content ;

: find-closable-gadget ( parent -- child )
    [ [ closable-gadget? ] is? ] find-parent ;

C: closable-gadget ( gadget title quot -- gadget )
    [
        <title-bar> @top grid,
        g-> set-closable-gadget-content @center grid,
    ] build-frame ;

M: closable-gadget focusable-child* closable-gadget-content ;

: build-closable-gadget ( tuple quot title -- tuple )
    pick >r >r with-gadget
    r> [ find-closable-gadget unparent ] <closable-gadget> r>
    [ set-gadget-delegate ] keep ; inline
