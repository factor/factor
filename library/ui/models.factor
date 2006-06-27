! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: models
USING: generic kernel sequences ;

TUPLE: model connections value dependencies ;

M: model = eq? ;

C: model ( value -- model )
    [ set-model-value ] keep
    V{ } clone over set-model-connections
    V{ } clone over set-model-dependencies ;

: add-dependency ( model model -- )
    model-dependencies push ;

: remove-dependency ( model model -- )
    model-dependencies delete ;

DEFER: add-connection

: activate-model ( model -- )
    dup model-dependencies [ add-connection ] each-with ;

DEFER: remove-connection

: deactivate-model ( model -- )
    dup model-dependencies [ remove-connection ] each-with ;

GENERIC: model-changed ( model -- )

: add-connection ( obj model -- )
    dup model-connections empty? [ dup activate-model ] when
    model-connections push ;

: remove-connection ( obj model -- )
    [ model-connections delete ] keep
    dup model-connections empty? [ dup deactivate-model ] when
    drop ;

: set-model ( value model -- )
    2dup model-value = [
        2drop
    ] [
        [ set-model-value ] keep
        model-connections [ model-changed ] each
    ] if ;

: change-model ( model quot -- )
    over >r >r model-value r> call r> set-model ; inline

: delegate>model ( obj -- )
    f <model> swap set-delegate ;

TUPLE: filter model quot ;

C: filter ( model quot -- filter )
    dup delegate>model
    [ set-filter-quot ] keep
    [ set-filter-model ] 2keep
    [ add-dependency ] keep
    dup model-changed ;

M: filter model-changed ( filter -- )
    dup filter-model model-value over filter-quot call
    swap set-model ;

TUPLE: compose ;

C: compose ( models -- compose )
    dup delegate>model
    [ set-model-dependencies ] keep
    dup model-changed ;

M: compose model-changed ( compose -- )
    dup model-dependencies [ model-value ] map
    swap set-model ;
