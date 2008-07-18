! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors ui.gadgets kernel ;

IN: ui.gadgets.wrappers

TUPLE: wrapper < gadget ;

: new-wrapper ( child class -- wrapper ) new-gadget swap add-gadget ;

: <wrapper> ( child -- border ) wrapper new-wrapper ;

M: wrapper pref-dim* ( wrapper -- dim ) gadget-child pref-dim ;

M: wrapper layout* ( wrapper -- )
    [ dim>> ] [ gadget-child ] bi set-layout-dim ;

M: wrapper focusable-child* ( wrapper -- child/t ) gadget-child ;
