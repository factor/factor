! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ui.gadgets ui.gadgets.borders
kernel math namespaces sequences models math.vectors
math.geometry.rect ;
IN: ui.gadgets.viewports

CONSTANT: viewport-gap { 3 3 }
CONSTANT: scroller-border { 1 1 }

TUPLE: viewport < gadget ;

: find-viewport ( gadget -- viewport )
    [ viewport? ] find-parent ;

: viewport-padding ( -- padding )
    viewport-gap 2 v*n scroller-border v+ ;

: viewport-dim ( viewport -- dim )
    gadget-child pref-dim viewport-padding v+ ;

: <viewport> ( content model -- viewport )
    viewport new-gadget
        swap >>model
        t >>clipped?
        swap add-gadget ;

M: viewport layout*
    [ gadget-child ] [
        [ dim>> viewport-padding v- ]
        [ gadget-child pref-dim ]
        bi vmax
    ] bi >>dim drop ;

M: viewport focusable-child*
    gadget-child ;

M: viewport pref-dim* viewport-dim ;

: scroller-value ( scroller -- loc )
    model>> range-value [ >fixnum ] map ;

M: viewport model-changed
    nip
    [ relayout-1 ]
    [
        [ gadget-child ]
        [
            scroller-value vneg
            viewport-gap v+
            scroller-border v+
        ] bi
        >>loc drop
    ] bi ;

: visible-dim ( gadget -- dim )
    dup parent>> viewport?
    [ parent>> rect-dim viewport-gap 2 v*n v- ] [ dim>> ] if ;
