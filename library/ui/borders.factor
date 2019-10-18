! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-borders
USING: errors gadgets gadgets-layouts gadgets-theme generic
hashtables kernel math namespaces vectors ;

TUPLE: border size ;

C: border ( child -- border )
    dup delegate>gadget
    { 5 5 0 } over set-border-size
    [ add-gadget ] keep ;

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
