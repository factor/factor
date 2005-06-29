! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: errors generic hashtables kernel lists math namespaces
sdl vectors ;

! A border lays out its children on top of each other, all with
! a 5-pixel padding.
TUPLE: border size ;

C: border ( child delegate size -- border )
    [ set-border-size ] keep
    [ set-delegate ] keep
    [ over [ add-gadget ] [ 2drop ] ifte ] keep ;

: empty-border ( child -- border )
    <empty-gadget> 5 <border> ;

: line-border ( child -- border )
    0 0 0 0 <etched-rect> <gadget> 5 <border> ;

: filled-border ( child -- border )
    <plain-gadget> 5 <border> ;

: gadget-child gadget-children car ;

: layout-border-x/y ( border -- )
    dup border-size dup rot gadget-child move-gadget ;

: layout-border-w/h ( border -- )
    [ border-size 2 * ] keep
    [ shape-w over - ] keep
    [ shape-h rot - ] keep
    gadget-child resize-gadget ;

M: border pref-dim ( border -- dim )
    [ border-size 2 * ] keep
    gadget-child pref-size >r over + r> rot + 0 3vector ;

M: border layout* ( border -- )
    dup layout-border-x/y layout-border-w/h ;
