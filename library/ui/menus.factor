! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-menus
USING: gadgets gadgets-borders gadgets-buttons gadgets-layouts
gadgets-labels generic kernel lists math namespaces sequences ;

: retarget-drag ( -- )
    hand [ rect-loc world get pick-up ] keep
    2dup hand-clicked eq? [
        2dup set-hand-clicked dup update-hand
    ] unless 2drop ;

: menu-actions ( glass -- )
    dup [ drop retarget-drag ] [ drag 1 ] set-action
    [ drop hide-glass ] [ button-down 1 ] set-action ;

: fit-bounds ( loc dim max -- loc )
    #! Adjust loc to fit inside max.
    swap v- { 0 0 0 } vmax vmin ;

: menu-loc ( menu -- loc )
    hand rect-loc swap rect-dim world get rect-dim fit-bounds ;

: show-menu ( menu -- )
    dup show-glass
    dup menu-loc swap set-rect-loc
    world get world-glass dup menu-actions
    hand set-hand-clicked ;

: menu-items ( assoc -- pile )
    #! Given an association list mapping labels to quotations.
    #! Prepend a call to hide-menu to each quotation.
    [ uncons \ hide-glass swons >r <label> r> <roll-button> ] map
    <pile> 1 over set-pack-fill [ add-gadgets ] keep ;

: menu-theme ( menu -- )
    << solid >> interior set-paint-prop ;

: <menu> ( assoc -- gadget )
    #! Given an association list mapping labels to quotations.
    menu-items line-border dup menu-theme ;
