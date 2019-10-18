! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets-controls
USING: gadgets kernel models ;

TUPLE: control self model quot old ;

: control-retain ( control -- )
    dup control-model model-value swap set-control-old ;

: control-changed? ( control -- ? )
    dup control-model model-value swap control-old eq? not ;

C: control ( model gadget quot -- gadget )
    dup dup set-control-self
    [ set-control-quot ] keep
    [ set-gadget-delegate ] keep
    [ set-control-model ] keep ;

M: control graft*
    dup control-self over control-model add-connection
    model-changed ;

M: control ungraft*
    dup control-self swap control-model remove-connection ;

M: control model-changed
    dup control-changed? [
        dup control-retain
        [ control-model model-value ] keep
        [ dup control-self swap control-quot call ] keep
        control-self relayout
    ] [
        drop
    ] if ;

: delegate>control ( gadget model -- )
    <gadget> [ 2drop ] <control> swap set-gadget-delegate ;
