! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: models
USING: generic kernel math sequences timers ;

TUPLE: model value connections dependencies ref ;

C: model ( value -- model )
    [ set-model-value ] keep
    V{ } clone over set-model-connections
    V{ } clone over set-model-dependencies
    0 over set-model-ref ;

M: model equal? eq? ;

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
        [ dup deactivate-model remove-connection ] each-with
    ] [
        drop
    ] if ;

GENERIC: model-changed ( observer -- )

: add-connection ( observer model -- )
    dup model-connections empty? [ dup activate-model ] when
    model-connections push ;

: remove-connection ( observer model -- )
    [ model-connections delete ] keep
    dup model-connections empty? [ dup deactivate-model ] when
    drop ;

GENERIC: set-model ( value model -- )

M: model set-model
    [ set-model-value ] keep
    model-connections [ model-changed ] each ;

: ((change-model)) ( model quot -- newvalue model )
    over >r >r model-value r> call r> ; inline

: change-model ( model quot -- )
    ((change-model)) set-model ; inline

: (change-model) ( model quot -- )
    ((change-model)) set-model-value ; inline

: delegate>model ( tuple -- )
    f <model> swap set-delegate ;

TUPLE: filter model quot ;

C: filter ( model quot -- filter )
    dup delegate>model
    [ set-filter-quot ] keep
    [ set-filter-model ] 2keep
    [ add-dependency ] keep ;

M: filter model-changed
    dup filter-model model-value over filter-quot call
    swap set-model ;

M: filter model-activated model-changed ;

TUPLE: compose ;

C: compose ( models -- compose )
    dup delegate>model
    swap clone over set-model-dependencies ;

M: compose model-changed
    dup model-dependencies [ model-value ] map
    swap delegate set-model ;

M: compose model-activated model-changed ;

M: compose set-model
    model-dependencies [ set-model ] 2each ;

TUPLE: history back forward ;

C: history ( value -- history )
    [ >r <model> r> set-delegate ] keep
    V{ } clone over set-history-back
    V{ } clone over set-history-forward ;

: (add-history)
    swap model-value dup [ swap push ] [ 2drop ] if ;

: go-back/forward ( history to from -- )
    dup empty?
    [ 3drop ]
    [ >r dupd (add-history) r> pop swap set-model ] if ;

: go-back ( history -- )
    dup history-forward over history-back go-back/forward ;

: go-forward ( history -- )
    dup history-back over history-forward go-back/forward ;

: add-history ( history -- )
    dup history-forward delete-all
    dup history-back (add-history) ;

TUPLE: delay model timeout ;

: update-delay-model ( delay -- )
    dup delay-model model-value swap set-model ;

C: delay ( model timeout -- filter )
    dup delegate>model
    [ set-delay-timeout ] keep
    [ set-delay-model ] 2keep
    [ add-dependency ] keep
    dup update-delay-model ;

M: delay model-changed 0 over delay-timeout add-timer ;

M: delay model-activated update-delay-model ;

M: delay tick dup remove-timer update-delay-model ;
