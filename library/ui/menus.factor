! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sequences ;

: show-menu ( menu -- )
    hand screen-loc over set-rect-loc show-glass ;

: menu-items ( assoc -- pile )
    #! Given an association list mapping labels to quotations.
    #! Prepend a call to hide-menu to each quotation.
    [ uncons \ hide-glass swons >r <label> r> <roll-button> ] map
    1 <pile> [ add-gadgets ] keep ;

: menu-theme ( menu -- )
    << gradient f { 1 0 0 } { 240 240 255 } { 216 216 216 } >>
    interior set-paint-prop ;

: <menu> ( assoc -- gadget )
    #! Given an association list mapping labels to quotations.
    menu-items line-border dup menu-theme ;
