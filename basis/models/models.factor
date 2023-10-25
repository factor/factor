! Copyright (C) 2006, 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors continuations kernel math math.order sequences ;
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
    [ 1 + dup ] change-ref drop ;

: unref-model ( model -- n )
    [ 1 - dup ] change-ref drop ;

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

: compute-model ( model -- value )
    [ activate-model ] [ deactivate-model ] [ value>> ] tri ;

GENERIC: model-changed ( model observer -- )
M: object model-changed 2drop ;

: add-connection ( observer model -- )
    dup connections>>
    [ empty? [ activate-model ] [ drop ] if ]
    [ push ] bi ;

: remove-connection ( observer model -- )
    [ connections>> remove! ] keep swap
    empty? [ deactivate-model ] [ drop ] if ;

: with-locked-model ( model quot -- )
    [ '[ _ t >>locked? @ ] ]
    [ drop '[ f _ locked?<< ] ]
    2bi finally ; inline

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

: ?set-model ( value model -- )
    2dup value>> = [ 2drop ] [ set-model ] if ;

: call-change-model ( model quot -- newvalue model )
    over [ [ value>> ] dip call ] dip ; inline

: change-model ( ..a model quot: ( ..a obj -- ..b newobj ) -- ..b )
    call-change-model set-model ; inline

: (change-model) ( ..a model quot: ( ..a obj -- ..b newobj ) -- ..b )
    call-change-model value<< ; inline

: change-model* ( ..a model quot: ( ..a obj -- ..b ) -- ..b )
    '[ _ keep ] change-model ; inline

: push-model ( value model -- )
    [ push ] change-model* ;

: pop-model ( model -- value )
    [ pop ] change-model* ;
