! Copyright (C) 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-borders
USING: arrays errors gadgets gadgets-theme generic hashtables
kernel math namespaces vectors sequences ;

TUPLE: border size ;

C: border ( child gap -- border )
    dup delegate>gadget
    [ >r dup 2array r> set-border-size ] keep
    [ add-gadget ] keep ;

: <default-border> ( child -- border ) 5 <border> ;

: layout-border-loc ( border -- )
    dup rect-dim swap gadget-child
    [ pref-dim v- 2 v/n [ >fixnum ] map ] keep set-rect-loc ;

M: border pref-dim*
    [ border-size 2 v*n ] keep
    gadget-child pref-dim v+ ;

M: border layout*
    dup layout-border-loc gadget-child prefer ;

: <spacing> ( -- gadget )
    <gadget> { 10 10 } over set-layout-dim ;
