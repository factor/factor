! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-viewports
USING: arrays gadgets gadgets-borders generic kernel math
namespaces sequences ;

: viewport-gap { 3 3 } ;

TUPLE: viewport ;

: find-viewport [ viewport? ] find-parent ;

: viewport-dim ( viewport -- dim )
    gadget-child pref-dim viewport-gap 2 v*n v+ ;

C: viewport ( content -- viewport )
    dup delegate>gadget
    [ add-gadget ] keep
    t over set-gadget-clipped? ;

M: viewport layout*
    dup rect-dim over gadget-child pref-dim vmax
    swap gadget-child set-layout-dim ;

M: viewport focusable-child*
    gadget-child ;

M: viewport pref-dim* viewport-dim ;
