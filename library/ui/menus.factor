! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-menus
USING: gadgets gadgets-borders gadgets-buttons gadgets-layouts
gadgets-labels gadgets-theme generic kernel lists math
namespaces sequences ;

: retarget-drag ( gadget -- )
    hand-gadget get-global hand-clicked get-global eq? [
        drop
    ] [
        hand-gadget get-global hand-clicked set-global
        update-hand
    ] if ;

: retarget-click ( gadget -- )
    find-world dup hide-glass update-hand update-clicked ;

: menu-actions ( glass -- )
    ! dup [ retarget-drag ] [ drag ] set-action
    [ retarget-click ] [ button-down ] set-action ;

: menu-loc ( loc menu world -- loc )
    [ rect-dim ] 2apply swap |v-| vmin ;

: show-menu ( loc menu gadget -- )
    find-world 2dup show-glass
    dup world-glass dup menu-actions hand-clicked set-global
    over >r menu-loc r> set-rect-loc ;

: show-hand-menu ( menu gadget -- )
    hand-click-loc get-global -rot show-menu ;

: menu-item-quot ( quot -- quot )
    [ keep find-world hide-glass ] curry ;

: menu-items ( assoc -- pile )
    #! Given an association list mapping labels to quotations.
    #! Prepend a call to hide-menu to each quotation.
    [ first2 menu-item-quot >r <label> r> <roll-button> ] map
    make-pile 1 over set-pack-fill ;

: <menu> ( assoc -- gadget )
    #! Given an association list mapping labels to quotations.
    menu-items <default-border> dup menu-theme ;
