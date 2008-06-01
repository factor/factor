! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes db kernel namespaces
classes.tuple words sequences slots math accessors
math.parser io prettyprint db.types continuations
destructors mirrors sequences.lib combinators.lib ;
IN: db.tuples

: define-persistent ( class table columns -- )
    >r dupd "db-table" set-word-prop dup r>
    [ relation? ] partition swapd
    dupd [ spec>tuple ] with map
    "db-columns" set-word-prop
    "db-relations" set-word-prop ;

ERROR: not-persistent class ;

: db-table ( class -- obj )
    dup "db-table" word-prop [ ] [ not-persistent ] ?if ;

: db-columns ( class -- obj )
    superclasses [ "db-columns" word-prop ] map concat ;

: db-relations ( class -- obj )
    "db-relations" word-prop ;

: set-primary-key ( key tuple -- )
    [
        class db-columns find-primary-key slot-name>>
    ] keep set-slot-named ;

SYMBOL: sql-counter
: next-sql-counter ( -- str )
    sql-counter [ inc ] [ get ] bi number>string ;

! returns a sequence of prepared-statements
HOOK: create-sql-statement db ( class -- obj )
HOOK: drop-sql-statement db ( class -- obj )

HOOK: <insert-db-assigned-statement> db ( class -- obj )
HOOK: <insert-user-assigned-statement> db ( class -- obj )
HOOK: <update-tuple-statement> db ( class -- obj )
HOOK: <delete-tuples-statement> db ( tuple class -- obj )
HOOK: <select-by-slots-statement> db ( tuple class -- tuple )
TUPLE: advanced-statement group order offset limit ;
HOOK: <advanced-select-statement> db ( tuple class group order offset limit -- tuple )

HOOK: insert-tuple* db ( tuple statement -- )

GENERIC: eval-generator ( singleton -- obj )
SINGLETON: retryable

: make-retryable ( obj -- obj' )
    dup sequence? [
        [ make-retryable ] map
    ] [
        retryable >>type
        10 >>retries
    ] if ;

: regenerate-params ( statement -- statement )
    dup
    [ bind-params>> ] [ in-params>> ] bi
    [
        dup generator-bind? [
            generator-singleton>> eval-generator >>value
        ] [
            drop
        ] if
    ] 2map >>bind-params ;

M: retryable execute-statement* ( statement type -- )
    drop [
        [
            [ query-results dispose t ]
            [ ]
            [ regenerate-params bind-statement* f ] cleanup
        ] curry
    ] [ retries>> ] bi retry drop ;

: resulting-tuple ( class row out-params -- tuple )
    rot class new [
        [
            >r slot-name>> r> set-slot-named
        ] curry 2each
    ] keep ;

: query-tuples ( exemplar-tuple statement -- seq )
    [ out-params>> ] keep query-results [
        [ sql-row-typed swap resulting-tuple ] with with query-map
    ] with-disposal ;
 
: query-modify-tuple ( tuple statement -- )
    [ query-results [ sql-row-typed ] with-disposal ] keep
    out-params>> rot [
        >r slot-name>> r> set-slot-named
    ] curry 2each ;

: sql-props ( class -- columns table )
    [ db-columns ] [ db-table ] bi ;

: with-disposals ( seq quot -- )
    over sequence? [
        [ with-disposal ] curry each
    ] [
        with-disposal
    ] if ; inline

: create-table ( class -- )
    create-sql-statement [ execute-statement ] with-disposals ;

: drop-table ( class -- )
    drop-sql-statement [ execute-statement ] with-disposals ;

: recreate-table ( class -- )
    [
        [ drop-sql-statement [ execute-statement ] with-disposals
        ] curry ignore-errors
    ] [ create-table ] bi ;

: ensure-table ( class -- )
    [ create-table ] curry ignore-errors ;

: insert-db-assigned-statement ( tuple -- )
    dup class
    db get db-insert-statements [ <insert-db-assigned-statement> ] cache
    [ bind-tuple ] 2keep insert-tuple* ;

: insert-user-assigned-statement ( tuple -- )
    dup class
    db get db-insert-statements [ <insert-user-assigned-statement> ] cache
    [ bind-tuple ] keep execute-statement ;

: insert-tuple ( tuple -- )
    dup class db-columns find-primary-key db-assigned-id-spec?
    [ insert-db-assigned-statement ] [ insert-user-assigned-statement ] if ;

: update-tuple ( tuple -- )
    dup class
    db get db-update-statements [ <update-tuple-statement> ] cache
    [ bind-tuple ] keep execute-statement ;

: delete-tuples ( tuple -- )
    dup dup class <delete-tuples-statement> [
        [ bind-tuple ] keep execute-statement
    ] with-disposal ;

: do-select ( exemplar-tuple statement -- tuples )
    [ [ bind-tuple ] [ query-tuples ] 2bi ] with-disposal ;

: select-tuples ( tuple -- tuples )
    dup dup class <select-by-slots-statement> do-select ;

: select-tuple ( tuple -- tuple/f )
    dup dup class f f f 1 <advanced-select-statement>
    do-select ?first ;
