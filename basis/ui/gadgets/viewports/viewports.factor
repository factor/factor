! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: ui.gadgets.viewports
USING: accessors arrays ui.gadgets ui.gadgets.borders
kernel math namespaces sequences models math.vectors math.geometry.rect ;

: viewport-gap { 3 3 } ; inline

TUPLE: viewport < gadget ;

: find-viewport ( gadget -- viewport )
    [ viewport? ] find-parent ;

: viewport-dim ( viewport -- dim )
    gadget-child pref-dim viewport-gap 2 v*n v+ ;

: <viewport> ( content model -- viewport )
    viewport new-gadget
        swap >>model
        t >>clipped?
        swap add-gadget ;

M: viewport layout*
    dup rect-dim viewport-gap 2 v*n v-
    over gadget-child pref-dim vmax
    swap gadget-child (>>dim) ;

M: viewport focusable-child*
    gadget-child ;

M: viewport pref-dim* viewport-dim ;

: scroller-value ( scroller -- loc )
    model>> range-value [ >fixnum ] map ;

M: viewport model-changed
    nip
    dup relayout-1
    dup scroller-value
    vneg viewport-gap v+
    swap gadget-child (>>loc) ;

: visible-dim ( gadget -- dim )
    dup parent>> viewport?
      [ parent>> rect-dim viewport-gap 2 v*n v- ]
      [ rect-dim ]
    if ;
