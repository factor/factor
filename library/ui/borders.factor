! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-borders
USING: arrays errors gadgets gadgets-layouts gadgets-theme
generic hashtables kernel math namespaces vectors ;

TUPLE: border size ;

C: border ( child gap -- border )
    dup delegate>gadget
    [ >r dup 0 3array r> set-border-size ] keep
    [ add-gadget ] keep ;

: <default-border> ( child -- border )
    3 <border> ;

: layout-border-loc ( border -- )
    dup border-size swap gadget-child set-rect-loc ;

: layout-border-dim ( border -- )
    dup rect-dim over border-size 2 v*n v-
    swap gadget-child set-gadget-dim ;

M: border pref-dim* ( border -- dim )
    [ border-size 2 v*n ] keep
    gadget-child pref-dim v+ ;

M: border layout* ( border -- )
    dup layout-border-loc layout-border-dim ;
