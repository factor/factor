! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ui.gadgets.buttons ui.gadgets.borders
ui.gadgets.labels ui.gadgets.panes ui.gadgets.scrollers
ui.gadgets.tracks ui.gadgets.theme io kernel math models namespaces
sequences sequences words classes.tuple ui.gadgets ui.render
colors colors.constants accessors ;
IN: ui.gadgets.labelled

TUPLE: labelled-gadget < track content ;

: <labelled-gadget> ( gadget title -- newgadget )
    vertical labelled-gadget new-track
        swap <label> reverse-video-theme f track-add
        swap >>content
        dup content>> 1 track-add ;

M: labelled-gadget focusable-child* content>> ;

: <labelled-scroller> ( gadget title -- gadget )
    [ <scroller> ] dip <labelled-gadget> ;

: <labelled-pane> ( model quot scrolls? title -- gadget )
    [ [ <pane-control> ] dip >>scrolls? ] dip
    <labelled-scroller> ;
