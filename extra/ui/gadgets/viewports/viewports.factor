! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: ui.gadgets.viewports
USING: arrays ui.gadgets ui.gadgets.borders
kernel math namespaces sequences models math.vectors ;

: viewport-gap { 3 3 } ; inline

TUPLE: viewport ;

: find-viewport [ viewport? ] find-parent ;

: viewport-dim ( viewport -- dim )
    gadget-child pref-dim viewport-gap 2 v*n v+ ;

: <viewport> ( content model -- viewport )
    <gadget> viewport construct-control
    t over set-gadget-clipped?
    [ add-gadget ] keep ;

M: viewport layout*
    dup rect-dim viewport-gap 2 v*n v-
    over gadget-child pref-dim vmax
    swap gadget-child set-layout-dim ;

M: viewport focusable-child*
    gadget-child ;

M: viewport pref-dim* viewport-dim ;

: scroller-value ( scroller -- loc )
    gadget-model range-value [ >fixnum ] map ;

M: viewport model-changed
    dup relayout-1
    dup scroller-value
    vneg viewport-gap v+
    swap gadget-child set-rect-loc ;

: visible-dim ( gadget -- dim )
    dup gadget-parent viewport? [
        gadget-parent rect-dim viewport-gap 2 v*n v-
    ] [
        rect-dim
    ] if ;
