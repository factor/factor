! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: errors generic hashtables kernel lists math namespaces
sdl ;

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
    0 0 0 0 <hollow-rect> <gadget> 5 <border> ;

: filled-border ( child -- border )
    0 0 0 0 <plain-rect> <gadget> 5 <border> ;

: gadget-child gadget-children car ;

: layout-border-x/y ( border -- )
    dup border-size dup rot gadget-child move-gadget ;

: layout-border-w/h ( border -- )
    [ border-size 2 * ] keep
    [ shape-w over - ] keep
    [ shape-h rot - ] keep
    gadget-child resize-gadget ;

M: border pref-size ( border -- w h )
    [ border-size 2 * ] keep
    gadget-child pref-size >r over + r> rot + ;

M: border layout* ( border -- )
    dup layout-border-x/y layout-border-w/h ;
