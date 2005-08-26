! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic kernel lists math namespaces sequences ;

: show-menu ( menu -- )
    hand screen-loc over set-rect-loc show-glass ;

: menu-item-border ( child -- border )
    <plain-gadget> { 1 1 0 } <border> ;

: <menu-item> ( label quot -- gadget )
    >r <label> menu-item-border dup roll-button-theme dup
    r> button-gestures ;

TUPLE: menu ;

: menu-actions ( menu -- )
    [ drop hide-glass ] [ button-down 1 ] set-action ;

: assoc>menu ( assoc menu -- )
    #! Given an association list mapping labels to quotations.
    #! Prepend a call to hide-menu to each quotation.
    [
        uncons \ hide-glass swons <menu-item> swap add-gadget
    ] each-with ;

: menu-theme ( menu -- )
    << gradient f { 1 0 0 } { 240 240 255 } { 216 216 216 } >>
    interior set-paint-prop ;

C: menu ( assoc -- gadget )
    #! Given an association list mapping labels to quotations.
    [ f line-border swap set-delegate ] keep
    0 1 <pile> [ swap add-gadget ] 2keep
    rot assoc>menu dup menu-actions
    dup menu-theme ;
