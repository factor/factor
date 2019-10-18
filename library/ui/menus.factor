! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces ;

: hide-menu ( -- )
    world get
    dup world-menu [ unparent ] when* f swap set-world-menu ;

: show-menu ( menu -- )
    hide-menu
    world get
    2dup set-world-menu
    2dup world-hand screen-pos >rect rot move-gadget
    add-gadget ;

: menu-item-border ( child -- border )
    0 0 0 0 <plain-rect> <gadget> 1 <border> ;

: <menu-item> ( label quot -- gadget )
    >r <label> menu-item-border dup r> button-actions ;

TUPLE: menu ;

: menu-actions ( menu -- )
    [ drop world get hide-menu ] [ button-down 1 ] set-action ;

: assoc>menu ( assoc menu -- )
    #! Given an association list mapping labels to quotations.
    #! Prepend a call to hide-menu to each quotation.
    [
        uncons \ hide-menu swons <menu-item> swap add-gadget
    ] each-with ;

C: menu ( assoc -- gadget )
    #! Given an association list mapping labels to quotations.
    [ f line-border swap set-delegate ] keep
    <line-pile> [ swap add-gadget ] 2keep
    rot assoc>menu dup menu-actions ;

! While a menu is open, clicking anywhere sends the click to
! the menu.
M: menu inside? ( point menu -- ? ) 2drop t ;

: actionize ( obj assoc -- assoc )
    #! Prepends an object to each cdr of the assoc list. Utility
    #! word for constructing menu action association lists.
    [
        unswons >r >r unit [ car ] cons r> append r> swons
    ] map-with ;
