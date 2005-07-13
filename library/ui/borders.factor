! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: errors generic hashtables kernel lists math matrices
namespaces sdl vectors ;

TUPLE: border size ;

C: border ( child delegate size -- border )
    [ set-border-size ] keep
    [ set-delegate ] keep
    [ over [ add-gadget ] [ 2drop ] ifte ] keep ;

: line-border ( child -- border )
    { 0 0 0 } dup <etched-rect> <gadget> { 5 5 0 } <border> ;

: layout-border-loc ( border -- )
    dup border-size swap gadget-child set-shape-loc ;

: layout-border-dim ( border -- )
    dup shape-dim over border-size 2 v*n v-
    swap gadget-child set-gadget-dim ;

M: border pref-dim ( border -- dim )
    [ border-size 2 v*n ] keep
    gadget-child pref-dim v+ ;

M: border layout* ( border -- )
    dup layout-border-loc layout-border-dim ;
