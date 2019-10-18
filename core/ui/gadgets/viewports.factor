! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-viewports
USING: arrays gadgets gadgets-borders generic kernel math
namespaces sequences models ;

: viewport-gap { 3 3 } ; inline

TUPLE: viewport ;

: find-viewport [ viewport? ] find-parent ;

: viewport-dim ( viewport -- dim )
    gadget-child pref-dim viewport-gap 2 v*n v+ ;

C: viewport ( content model -- viewport )
    dup rot <gadget> delegate>control
    t over set-gadget-clipped?
    [ add-gadget ] keep
    [ model-changed ] keep ;

M: viewport layout*
    dup rect-dim viewport-gap 2 v*n v-
    over gadget-child pref-dim vmax
    swap gadget-child set-layout-dim ;

M: viewport focusable-child*
    gadget-child ;

M: viewport pref-dim* viewport-dim ;

M: viewport model-changed
    dup control-value vneg viewport-gap v+
    swap gadget-child set-rect-loc ;
