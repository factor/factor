! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors generic kernel math sequences arrays assocs
alarms calendar math.order ;
IN: models

TUPLE: model < identity-tuple
value connections dependencies ref locked? ;

: new-model ( value class -- model )
    new
        swap >>value
        V{ } clone >>connections
        V{ } clone >>dependencies
        0 >>ref ; inline

: <model> ( value -- model )
    model new-model ;

M: model hashcode* drop model hashcode* ;

: add-dependency ( dep model -- )
    model-dependencies push ;

: remove-dependency ( dep model -- )
    model-dependencies delete ;

DEFER: add-connection

GENERIC: model-activated ( model -- )

M: model model-activated drop ;

: ref-model ( model -- n )
    dup model-ref 1+ dup rot set-model-ref ;

: unref-model ( model -- n )
    dup model-ref 1- dup rot set-model-ref ;

: activate-model ( model -- )
    dup ref-model 1 = [
        dup model-dependencies
        [ dup activate-model dupd add-connection ] each
        model-activated
    ] [
        drop
    ] if ;

DEFER: remove-connection

: deactivate-model ( model -- )
    dup unref-model zero? [
        dup model-dependencies
        [ dup deactivate-model remove-connection ] with each
    ] [
        drop
    ] if ;

GENERIC: model-changed ( model observer -- )

: add-connection ( observer model -- )
    dup model-connections empty? [ dup activate-model ] when
    model-connections push ;

: remove-connection ( observer model -- )
    [ model-connections delete ] keep
    dup model-connections empty? [ dup deactivate-model ] when
    drop ;

: with-locked-model ( model quot -- )
    swap
    t over set-model-locked?
    slip
    f swap set-model-locked? ; inline

GENERIC: update-model ( model -- )

M: model update-model drop ;

: notify-connections ( model -- )
    dup model-connections [ model-changed ] with each ;

: set-model ( value model -- )
    dup model-locked? [
        2drop
    ] [
        dup [
            [ set-model-value ] keep
            [ update-model ] keep
            notify-connections
        ] with-locked-model
    ] if ;

: ((change-model)) ( model quot -- newvalue model )
    over >r >r model-value r> call r> ; inline

: change-model ( model quot -- )
    ((change-model)) set-model ; inline

: (change-model) ( model quot -- )
    ((change-model)) set-model-value ; inline

: construct-model ( value class -- instance )
    >r <model> { set-delegate } r> construct ; inline

GENERIC: range-value ( model -- value )
GENERIC: range-page-value ( model -- value )
GENERIC: range-min-value ( model -- value )
GENERIC: range-max-value ( model -- value )
GENERIC: range-max-value* ( model -- value )
GENERIC: set-range-value ( value model -- )
GENERIC: set-range-page-value ( value model -- )
GENERIC: set-range-min-value ( value model -- )
GENERIC: set-range-max-value ( value model -- )

: clamp-value ( value range -- newvalue )
    [ range-min-value max ] keep
    range-max-value* min ;
