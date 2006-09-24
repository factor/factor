! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-viewports
USING: arrays gadgets gadgets-borders generic kernel math
namespaces sequences ;

TUPLE: viewport ;

: find-viewport [ viewport? ] find-parent ;

: viewport-dim ( viewport -- dim ) gadget-child pref-dim ;

C: viewport ( content -- viewport )
    dup delegate>gadget
    [ >r 3 <border> r> add-gadget ] keep
    t over set-gadget-clipped? ;

M: viewport layout* gadget-child prefer ;

M: viewport focusable-child*
    gadget-child ;

M: viewport pref-dim* viewport-dim ;

: viewport-rect ( rect -- rect ) { 3 3 } offset-rect ;
