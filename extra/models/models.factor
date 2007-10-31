! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: generic kernel math sequences timers arrays assocs ;
IN: models

TUPLE: model value connections dependencies ref ;

: <model> ( value -- model )
    V{ } clone V{ } clone 0 model construct-boa ;

M: model equal? 2drop f ;

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
        [ dup deactivate-model remove-connection ] curry* each
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

: construct-model ( value class -- instance )
    >r <model> { set-delegate } r> construct ; inline

TUPLE: filter model quot ;

: <filter> ( model quot -- filter )
    f filter construct-model
    [ set-filter-quot ] keep
    [ set-filter-model ] 2keep
    [ add-dependency ] keep ;

M: filter model-changed
    dup filter-model model-value over filter-quot call
    swap set-model ;

M: filter model-activated model-changed ;

TUPLE: compose ;

: <compose> ( models -- compose )
    f compose construct-model
    swap clone over set-model-dependencies ;

: composed-value >r model-dependencies r> map ; inline

: set-composed-value >r model-dependencies r> 2each ; inline

M: compose model-changed
    dup [ model-value ] composed-value swap delegate set-model ;

M: compose model-activated model-changed ;

M: compose set-model [ set-model ] set-composed-value ;

TUPLE: mapping assoc ;

: <mapping> ( models -- mapping )
    f mapping construct-model
    over values over set-model-dependencies
    tuck set-mapping-assoc ;

M: mapping model-changed
    dup mapping-assoc [ model-value ] assoc-map
    swap delegate set-model ;

M: mapping model-activated model-changed ;

M: mapping set-model
    mapping-assoc [ swapd at set-model ] curry assoc-each ;

TUPLE: history back forward ;

: reset-history ( history -- )
    V{ } clone over set-history-back
    V{ } clone swap set-history-forward ;

: <history> ( value -- history )
    history construct-model dup reset-history ;

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

: <delay> ( model timeout -- delay )
    f delay construct-model
    [ set-delay-timeout ] keep
    [ set-delay-model ] 2keep
    [ add-dependency ] keep
    dup update-delay-model ;

M: delay model-changed 0 over delay-timeout add-timer ;

M: delay model-activated update-delay-model ;

M: delay tick dup remove-timer update-delay-model ;

GENERIC: range-value ( model -- value )
GENERIC: range-page-value ( model -- value )
GENERIC: range-min-value ( model -- value )
GENERIC: range-max-value ( model -- value )
GENERIC: range-max-value* ( model -- value )
GENERIC: set-range-value ( value model -- )
GENERIC: set-range-page-value ( value model -- )
GENERIC: set-range-min-value ( value model -- )
GENERIC: set-range-max-value ( value model -- )

TUPLE: range ;

: <range> ( value min max page -- range )
    4array [ <model> ] map <compose>
    { set-delegate } range construct ;

: range-model ( range -- model ) model-dependencies first ;
: range-page ( range -- model ) model-dependencies second ;
: range-min ( range -- model ) model-dependencies third ;
: range-max ( range -- model ) model-dependencies fourth ;

: clamp-value ( value range -- newvalue )
    [ range-min-value max ] keep
    range-max-value* min ;

M: range range-value
    [ range-model model-value ] keep clamp-value ;

M: range range-page-value range-page model-value ;

M: range range-min-value range-min model-value ;

M: range range-max-value range-max model-value ;

M: range range-max-value*
    dup range-max-value swap range-page-value [-] ;

M: range set-range-value range-model set-model ;

M: range set-range-page-value range-page set-model ;

M: range set-range-min-value range-min set-model ;

M: range set-range-max-value range-max set-model ;

M: compose range-value
    [ range-value ] composed-value ;

M: compose range-page-value
    [ range-page-value ] composed-value ;

M: compose range-min-value
    [ range-min-value ] composed-value ;

M: compose range-max-value
    [ range-max-value ] composed-value ;

M: compose range-max-value*
    [ range-max-value* ] composed-value ;

M: compose set-range-value
    [ clamp-value ] keep
    [ set-range-value ] set-composed-value ;

M: compose set-range-page-value
    [ set-range-page-value ] set-composed-value ;

M: compose set-range-min-value
    [ set-range-min-value ] set-composed-value ;

M: compose set-range-max-value
    [ set-range-max-value ] set-composed-value ;

: move-by ( amount range -- )
    [ range-value + ] keep set-range-value ;

: move-by-page ( amount range -- )
    [ range-page-value * ] keep move-by ;
