! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel models ui.gadgets ;
IN: ui.gadgets.controls

TUPLE: control self model quot ;

: (construct-control)
    construct dup dup set-control-self ; inline

: <control> ( model gadget quot -- gadget )
    {
        set-control-model set-gadget-delegate set-control-quot
    } control (construct-control) ;

: control-value ( control -- value )
    control-model model-value ;

: set-control-value ( value control -- )
    control-model set-model ;

M: control graft*
    control-self dup dup control-model add-connection
    model-changed ;

M: control ungraft*
    control-self dup control-model remove-connection ;

M: control model-changed
    control-self
    [ control-value ] keep
    [ dup control-quot call ] keep
    relayout ;

: construct-control ( model underlying class -- tuple )
    >r [ 2drop ] <control> { set-gadget-delegate } r>
    (construct-control) ; inline
