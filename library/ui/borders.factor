! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-borders
USING: errors gadgets gadgets-layouts generic hashtables kernel
math namespaces vectors ;

TUPLE: border size ;

C: border ( delegate size -- border )
    [ set-border-size ] keep
    [ set-delegate ] keep ;

: make-border ( child delegate size -- boder )
    <border> [ add-gadget ] keep ;

: empty-border ( child -- border )
    <gadget> @{ 0 0 0 }@ make-border ;

: gap-border ( child -- border )
    <gadget> @{ 5 5 0 }@ make-border ;

: line-border ( child -- border )
    <etched-gadget> @{ 5 5 0 }@ make-border ;

: bevel-border ( child -- border )
    <bevel-gadget> @{ 5 5 0 }@ make-border ;

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
