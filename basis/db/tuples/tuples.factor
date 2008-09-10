! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes db kernel namespaces
classes.tuple words sequences slots math accessors
math.parser io prettyprint db.types continuations
destructors mirrors ;
IN: db.tuples

: define-persistent ( class table columns -- )
    >r dupd "db-table" set-word-prop dup r>
    [ relation? ] partition swapd
    dupd [ spec>tuple ] with map
    "db-columns" set-word-prop
    "db-relations" set-word-prop ;

ERROR: not-persistent class ;

: db-table ( class -- object )
    dup "db-table" word-prop [ ] [ not-persistent ] ?if ;

: db-columns ( class -- object )
    superclasses [ "db-columns" word-prop ] map concat ;

: db-relations ( class -- object )
    "db-relations" word-prop ;

: set-primary-key ( key tuple -- )
    [
        class db-columns find-primary-key slot-name>>
    ] keep set-slot-named ;

SYMBOL: sql-counter
: next-sql-counter ( -- str )
    sql-counter [ inc ] [ get ] bi number>string ;

! returns a sequence of prepared-statements
HOOK: create-sql-statement db ( class -- object )
HOOK: drop-sql-statement db ( class -- object )

HOOK: <insert-db-assigned-statement> db ( class -- object )
HOOK: <insert-user-assigned-statement> db ( class -- object )
HOOK: <update-tuple-statement> db ( class -- object )
HOOK: <delete-tuples-statement> db ( tuple class -- object )
HOOK: <select-by-slots-statement> db ( tuple class -- tuple )
TUPLE: query group order offset limit ;
HOOK: <query> db ( tuple class query -- statement' )
HOOK: <count-statement> db ( tuple class groups -- n )

HOOK: insert-tuple* db ( tuple statement -- )

GENERIC: eval-generator ( singleton -- object )

: resulting-tuple ( exemplar-tuple row out-params -- tuple )
    rot class new [
        [
            [ slot-name>> ] dip set-slot-named
        ] curry 2each
    ] keep ;

: query-tuples ( exemplar-tuple statement -- seq )
    [ out-params>> ] keep query-results [
        [ sql-row-typed swap resulting-tuple ] with with query-map
    ] with-disposal ;
 
: query-modify-tuple ( tuple statement -- )
    [ query-results [ sql-row-typed ] with-disposal ] keep
    out-params>> rot [
        [ slot-name>> ] dip set-slot-named
    ] curry 2each ;

: with-disposals ( object quotation -- )
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

: ensure-tables ( classes -- )
    [ ensure-table ] each ;

: insert-db-assigned-statement ( tuple -- )
    dup class
    db get insert-statements>> [ <insert-db-assigned-statement> ] cache
    [ bind-tuple ] 2keep insert-tuple* ;

: insert-user-assigned-statement ( tuple -- )
    dup class
    db get insert-statements>> [ <insert-user-assigned-statement> ] cache
    [ bind-tuple ] keep execute-statement ;

: insert-tuple ( tuple -- )
    dup class db-columns find-primary-key db-assigned-id-spec?
    [ insert-db-assigned-statement ] [ insert-user-assigned-statement ] if ;

: update-tuple ( tuple -- )
    dup class
    db get update-statements>> [ <update-tuple-statement> ] cache
    [ bind-tuple ] keep execute-statement ;

: delete-tuples ( tuple -- )
    dup dup class <delete-tuples-statement> [
        [ bind-tuple ] keep execute-statement
    ] with-disposal ;

: do-select ( exemplar-tuple statement -- tuples )
    [ [ bind-tuple ] [ query-tuples ] 2bi ] with-disposal ;

: query ( tuple query -- tuples )
    [ dup dup class ] dip <query> do-select ;

: select-tuples ( tuple -- tuples )
    dup dup class <select-by-slots-statement> do-select ;

: select-tuple ( tuple -- tuple/f )
    dup dup class \ query new 1 >>limit <query> do-select
    [ f ] [ first ] if-empty ;

: do-count ( exemplar-tuple statement -- tuples )
    [
        [ bind-tuple ] [ nip default-query ] 2bi
    ] with-disposal ;

: count-tuples ( tuple groups -- n )
    >r dup dup class r> <count-statement> do-count
    dup length 1 =
    [ first first string>number ] [ [ first string>number ] map ] if ;
