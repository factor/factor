! Copyright (C) 2005, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel ui.baseline-alignment ui.gadgets ;
IN: ui.gadgets.wrappers

TUPLE: wrapper < gadget ;

: new-wrapper ( child class -- wrapper )
    new swap add-gadget ; inline

: <wrapper> ( child -- wrapper ) wrapper new-wrapper ;

M: wrapper pref-dim* gadget-child pref-dim ;

M: wrapper baseline gadget-child baseline ;

M: wrapper cap-height gadget-child cap-height ;

M: wrapper layout* [ gadget-child ] [ dim>> ] bi >>dim drop ;

M: wrapper focusable-child* gadget-child ;
