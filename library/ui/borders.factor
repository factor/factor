! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-borders
USING: errors gadgets gadgets-layouts gadgets-theme generic
hashtables kernel math namespaces vectors ;

TUPLE: border size ;

C: border ( size -- border )
    dup gadget-delegate [ set-border-size ] keep ;

: empty-border ( child -- border )
    @{ 5 5 0 }@ <border> [ add-gadget ] keep ;

: line-border ( child -- border )
    empty-border dup solid-boundary ;

: bevel-border ( child -- border )
    empty-border dup bevel-theme ;

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
