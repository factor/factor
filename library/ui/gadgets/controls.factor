! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-controls
USING: gadgets kernel models ;

TUPLE: control model quot ;

C: control ( model gadget quot -- gadget )
    [ set-control-quot ] keep
    [ set-gadget-delegate ] keep
    [ set-control-model ] keep
    dup model-changed ;

M: control add-notify*
    dup control-model add-connection ;

M: control remove-notify*
    dup control-model remove-connection ;

M: control model-changed ( gadget -- )
    [ control-model model-value ] keep
    [ dup control-quot call ] keep relayout ;
