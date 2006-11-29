! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: gadgets
USING: kernel models ;

TUPLE: control self model quot ;

C: control ( model gadget quot -- gadget )
    dup dup set-control-self
    [ set-control-quot ] keep
    [ set-gadget-delegate ] keep
    [ set-control-model ] keep ;

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

: delegate>control ( gadget model underlying -- )
    [ 2drop ] <control> over set-gadget-delegate
    dup set-control-self ;
