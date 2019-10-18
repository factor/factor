! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-menus
USING: gadgets gadgets-borders gadgets-buttons gadgets-layouts
gadgets-labels gadgets-theme generic kernel lists math
namespaces sequences ;

: retarget-drag ( -- )
    hand get [ hand-gadget ] keep 2dup hand-clicked eq?
    [ 2dup set-hand-clicked update-hand ] unless 2drop ;

: menu-actions ( glass -- )
    dup [ drop retarget-drag ] [ drag 1 ] set-action
    [ drop hide-glass ] [ button-down 1 ] set-action ;

: fit-bounds ( loc dim max -- loc )
    #! Adjust loc to fit inside max.
    swap |v-| vmin ;

: menu-loc ( menu loc -- loc )
    swap rect-dim world get rect-dim fit-bounds ;

: show-menu ( menu loc -- )
    >r dup dup show-glass r>
    menu-loc swap set-rect-loc
    world get world-glass dup menu-actions
    hand get set-hand-clicked ;

: show-hand-menu ( menu -- ) hand get rect-loc show-menu ;

: menu-items ( assoc -- pile )
    #! Given an association list mapping labels to quotations.
    #! Prepend a call to hide-menu to each quotation.
    [ uncons \ hide-glass swons >r <label> r> <roll-button> ] map
    make-pile 1 over set-pack-fill ;

: <menu> ( assoc -- gadget )
    #! Given an association list mapping labels to quotations.
    menu-items <border> dup menu-theme ;

: menu-button-actions ( gadget -- )
    dup [ button-clicked ] [ button-down 1 ] set-action
    [ button-update ] [ button-up 1 ] set-action ;
