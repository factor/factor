! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel models ;
IN: gadgets

TUPLE: control self model quot ;

: (delegate>control) ( tuple gadget -- )
    over set-gadget-delegate dup set-control-self ;

C: control ( model gadget quot -- gadget )
    [ set-control-quot ] keep
    [ swap (delegate>control) ] keep
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

: delegate>control ( tuple model underlying -- )
    [ 2drop ] <control> (delegate>control) ;
