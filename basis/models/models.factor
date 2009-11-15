! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors generic kernel math sequences arrays assocs
alarms calendar math.order continuations fry ;
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

: add-dependency ( dep model -- )
    dependencies>> push ;

: remove-dependency ( dep model -- )
    dependencies>> remove! drop ;

DEFER: add-connection

GENERIC: model-activated ( model -- )

M: model model-activated drop ;

: ref-model ( model -- n )
    [ 1 + ] change-ref ref>> ;

: unref-model ( model -- n )
    [ 1 - ] change-ref ref>> ;

: activate-model ( model -- )
    dup ref-model 1 = [
        dup dependencies>>
        [ dup activate-model dupd add-connection ] each
        model-activated
    ] [
        drop
    ] if ;

DEFER: remove-connection

: deactivate-model ( model -- )
    dup unref-model zero? [
        dup dependencies>>
        [ dup deactivate-model remove-connection ] with each
    ] [
        drop
    ] if ;

GENERIC: model-changed ( model observer -- )

: add-connection ( observer model -- )
    dup connections>> empty? [ dup activate-model ] when
    connections>> push ;

: remove-connection ( observer model -- )
    [ connections>> remove! drop ] keep
    dup connections>> empty? [ dup deactivate-model ] when
    drop ;

: with-locked-model ( model quot -- )
    [ '[ _ t >>locked? @ ] ]
    [ drop '[ _ f >>locked? drop ] ]
    2bi [ ] cleanup ; inline

GENERIC: update-model ( model -- )

M: model update-model drop ;

: notify-connections ( model -- )
    dup connections>> [ model-changed ] with each ;

: set-model ( value model -- )
    dup locked?>> [
        2drop
    ] [
        [
            swap >>value
            [ update-model ] [ notify-connections ] bi
        ] with-locked-model
    ] if ;

: ((change-model)) ( model quot -- newvalue model )
    over [ [ value>> ] dip call ] dip ; inline

: change-model ( model quot -- )
    ((change-model)) set-model ; inline

: (change-model) ( model quot -- )
    ((change-model)) (>>value) ; inline

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
    [ range-min-value ] [ range-max-value* ] bi clamp ;
