! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: errors generic hashtables kernel lists math matrices
namespaces sdl vectors ;

TUPLE: border size ;

C: border ( child delegate size -- border )
    [ set-border-size ] keep
    [ set-delegate ] keep
    [ add-gadget ] keep ;

: empty-border ( child -- border )
    <gadget> { 5 5 0 } <border> ;

: line-border ( child -- border )
    <etched-gadget> { 5 5 0 } <border> ;

: bevel-border ( child -- border )
    <bevel-gadget> { 5 5 0 } <border> ;

: layout-border-loc ( border -- )
    dup border-size swap gadget-child set-rect-loc ;

: layout-border-dim ( border -- )
    dup rect-dim over border-size 2 v*n v-
    swap gadget-child set-gadget-dim ;

M: border pref-dim ( border -- dim )
    [ border-size 2 v*n ] keep
    gadget-child pref-dim v+ ;

M: border layout* ( border -- )
    dup layout-border-loc layout-border-dim ;
