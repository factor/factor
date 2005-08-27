! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sequences ;

: menu-actions ( glass -- )
    [ drop hide-glass ] [ button-down 1 ] set-action ;

: fit-bounds ( loc dim max -- loc )
    #! Adjust loc to fit inside max.
    swap v- { 0 0 0 } vmax vmin ;

: menu-loc ( menu -- loc )
    hand rect-loc swap rect-dim world get rect-dim fit-bounds ;

: show-menu ( menu -- )
    dup show-glass
    dup menu-loc swap set-rect-loc
    world get world-glass menu-actions ;

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
