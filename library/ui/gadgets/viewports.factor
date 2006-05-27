! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-viewports
USING: arrays gadgets gadgets-layouts generic kernel math
namespaces sequences ;

TUPLE: viewport ;

: find-viewport [ viewport? ] find-parent ;

: viewport-dim gadget-child pref-dim ;

C: viewport ( content -- viewport )
    dup delegate>gadget [ add-gadget ] keep ;

M: viewport layout* ( viewport -- )
    gadget-child prefer ;

M: viewport focusable-child* ( viewport -- gadget )
    gadget-child ;

M: viewport pref-dim* ( viewport -- dim ) viewport-dim ;
