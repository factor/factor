! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables kernel lists math namespaces ;

! A pile is a box that lays out its contents vertically.
TUPLE: pile delegate ;

C: pile ( gadget -- pile )
    [ >r <box> r> set-pile-delegate ] keep ;

M: pile layout* ( pile -- )
    dup gadget-children run-heights >r >r
    dup gadget-children max-width r> pick resize-gadget
    gadget-children r> zip [
        uncons 0 swap rot move-gadget
    ] each ;

! A shelf is a box that lays out its contents horizontally.
TUPLE: shelf delegate ;

C: shelf ( gadget -- pile )
    [ >r <box> r> set-shelf-delegate ] keep ;

M: shelf layout* ( pile -- )
    dup gadget-children run-widths >r >r
    dup gadget-children max-height r> swap pick resize-gadget
    gadget-children r> zip [
        uncons 0 rot move-gadget
    ] each ;
