! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists math namespaces ;

GENERIC: layout* ( gadget -- )
M: gadget layout* drop ;

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

: relayout ( gadget -- )
    #! Relayout a gadget before the next iteration of the event
    #! loop. Since relayout also implies the visual
    #! representation changed, we redraw the gadget too.
    t over set-gadget-redraw?
    t over set-gadget-relayout?
    gadget-parent [ relayout ] when* ;

: layout ( gadget -- )
    #! Set the gadget's width and height to its preferred width
    #! and height. The gadget's children are laid out first.
    #! Note that nothing is done if the gadget does not need to
    #! be laid out.
    dup gadget-relayout? [
        f over set-gadget-relayout?
        dup gadget-children [ layout ] each
        layout*
    ] [
        drop
    ] ifte ;
