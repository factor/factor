! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays ui.gadgets generic hashtables kernel math
namespaces vectors sequences math.vectors ;
IN: ui.gadgets.borders

TUPLE: border size ;

: <border> ( child gap -- border )
    border construct-gadget
    [ >r dup 2array r> set-border-size ] keep
    [ add-gadget ] keep ;

: layout-border-loc ( border -- )
    dup rect-dim swap gadget-child
    [ pref-dim v- 2 v/n [ >fixnum ] map ] keep set-rect-loc ;

M: border pref-dim*
    [ border-size 2 v*n ] keep
    gadget-child pref-dim v+ ;

M: border layout*
    dup layout-border-loc gadget-child prefer ;

M: border focusable-child*
    gadget-child ;
