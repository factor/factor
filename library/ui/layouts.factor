! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists math namespaces ;

GENERIC: layout* ( gadget -- )
M: gadget layout* drop ;

: layout ( gadget -- )
    #! Set the gadget's width and height to its preferred width
    #! and height. The gadget's children are laid out first.
    #! Note that nothing is done if the gadget does not need to
    #! be laid out.
    dup gadget-relayout? [
        dup gadget-paint [
            f over set-gadget-relayout?
            dup gadget-children [ layout ] each
            layout*
        ] bind
    ] [
        drop
    ] ifte ;

! A pile is a box that lays out its contents vertically.
TUPLE: pile delegate ;

C: pile ( shape -- pile )
    [ >r <gadget> r> set-pile-delegate ] keep ;

M: pile layout* ( pile -- )
    dup gadget-children run-heights >r >r
    dup gadget-children max-width r> pick resize-gadget
    gadget-children r> zip [
        uncons 0 swap rot move-gadget
    ] each ;

! A shelf is a box that lays out its contents horizontally.
TUPLE: shelf delegate ;

C: shelf ( shape -- pile )
    [ >r <gadget> r> set-shelf-delegate ] keep ;

M: shelf layout* ( pile -- )
    dup gadget-children run-widths >r >r
    dup gadget-children max-height r> swap pick resize-gadget
    gadget-children r> zip [
        uncons 0 rot move-gadget
    ] each ;

! A border lays out its children on top of each other, all with
! a 5-pixel padding.
TUPLE: border size delegate ;

C: border ( delegate size -- border )
    [ set-border-size ] keep [ set-border-delegate ] keep ;

: standard-border ( child delegate -- border )
    5 <border> [ add-gadget ] keep ;

: empty-border ( child -- border )
    0 0 0 0 <rectangle> <gadget> standard-border ;

: bevel-border ( child -- border )
    3 0 0 0 0 <bevel-rect> <gadget> standard-border ;

: size-border ( border -- )
    dup gadget-children
    dup max-width pick border-size 2 * +
    swap max-height pick border-size 2 * +
    rot resize-gadget ;

: layout-border-x/y ( border -- )
    dup gadget-children [
        >r border-size dup r> move-gadget
    ] each-with ;

: layout-border-w/h ( border -- )
    [
        dup shape-h over border-size 2 * - >r
        dup shape-w swap border-size 2 * - r>
    ] keep
    gadget-children [ >r 2dup r> resize-gadget ] each 2drop ;

M: border layout* ( border -- )
    dup size-border dup layout-border-x/y layout-border-w/h ;
