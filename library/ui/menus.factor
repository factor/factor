! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: kernel lists math namespaces ;

: hide-menu ( world -- )
    dup world-menu [ unparent ] when* f swap set-world-menu ;

: show-menu ( menu -- )
    world get dup hide-menu
    2dup set-world-menu
    2dup world-hand screen-pos >rect rot move-gadget
    add-gadget ;

: menu-item-border ( child -- border )
    0 0 0 0 <plain-rect> <gadget> 1 <border> ;

: <menu-item> ( label quot -- gadget )
    >r <label> menu-item-border dup r> button-actions ;

TUPLE: menu delegate ;

: menu-actions ( menu -- )
    [ drop world get hide-menu ] [ button-up 1 ] set-action ;

C: menu ( assoc -- gadget )
    #! Given an association list mapping labels to quotations.
    [ f line-border swap set-menu-delegate ] keep
    <line-pile> [ swap add-gadget ] 2keep
    rot [ uncons <menu-item> swap add-gadget ] each-with
    dup menu-actions ;

! While a menu is open, clicking anywhere sends the click to
! the menu.
M: menu inside? ( point menu -- ? ) 2drop t ;
