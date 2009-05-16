! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes db kernel namespaces
classes.tuple words sequences slots math accessors
math.parser io prettyprint continuations
destructors mirrors sets db.types db.private fry
combinators.short-circuit db.errors ;
IN: db.tuples

HOOK: create-sql-statement db-connection ( class -- object )
HOOK: drop-sql-statement db-connection ( class -- object )

HOOK: <insert-db-assigned-statement> db-connection ( class -- object )
HOOK: <insert-user-assigned-statement> db-connection ( class -- object )
HOOK: <update-tuple-statement> db-connection ( class -- object )
HOOK: <delete-tuples-statement> db-connection ( tuple class -- object )
HOOK: <select-by-slots-statement> db-connection ( tuple class -- tuple )
HOOK: <count-statement> db-connection ( query -- statement )
HOOK: query>statement db-connection ( query -- statement )
HOOK: insert-tuple-set-key db-connection ( tuple statement -- )

<PRIVATE

SYMBOL: sql-counter

: next-sql-counter ( -- str )
    sql-counter [ inc ] [ get ] bi number>string ;

GENERIC: eval-generator ( singleton -- object )

: resulting-tuple ( exemplar-tuple row out-params -- tuple )
    rot class new [
        '[ slot-name>> _ set-slot-named ] 2each
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

: insert-db-assigned-statement ( tuple -- )
    dup class
    db-connection get insert-statements>>
    [ <insert-db-assigned-statement> ] cache
    [ bind-tuple ] 2keep insert-tuple-set-key ;

: insert-user-assigned-statement ( tuple -- )
    dup class
    db-connection get insert-statements>>
    [ <insert-user-assigned-statement> ] cache
    [ bind-tuple ] keep execute-statement ;

: do-select ( exemplar-tuple statement -- tuples )
    [ [ bind-tuple ] [ query-tuples ] 2bi ] with-disposal ;

: do-count ( exemplar-tuple statement -- tuples )
    [ [ bind-tuple ] [ nip default-query ] 2bi ] with-disposal ;

PRIVATE>

! High level
ERROR: no-slots-named class seq ;
: check-columns ( class columns -- )
    [ nip ] [
        [ [ first ] map ]
        [ all-slots [ name>> ] map ] bi* diff
    ] 2bi
    [ drop ] [ no-slots-named ] if-empty ;

: define-persistent ( class table columns -- )
    pick dupd
    check-columns
    [ dupd "db-table" set-word-prop dup ] dip
    [ relation? ] partition swapd
    dupd [ spec>tuple ] with map
    "db-columns" set-word-prop
    "db-relations" set-word-prop ;

TUPLE: query tuple group order offset limit ;

: <query> ( -- query ) \ query new ;

GENERIC: >query ( object -- query )

M: query >query clone ;

M: tuple >query <query> swap >>tuple ;

ERROR: no-defined-persistent object ;

: ensure-defined-persistent ( object -- object )
    dup { [ class? ] [ "db-table" word-prop ] } 1&& [
        no-defined-persistent
    ] unless ;

: create-table ( class -- )
    ensure-defined-persistent
    create-sql-statement [ execute-statement ] with-disposals ;

: drop-table ( class -- )
    ensure-defined-persistent
    drop-sql-statement [ execute-statement ] with-disposals ;

: recreate-table ( class -- )
    ensure-defined-persistent
    [
        '[
            [
                _ drop-sql-statement [ execute-statement ] with-disposals
            ] ignore-table-missing
        ] ignore-function-missing
    ] [ create-table ] bi ;

: ensure-table ( class -- )
    ensure-defined-persistent
    '[ [ _ create-table ] ignore-table-exists ] ignore-function-exists ;

: ensure-tables ( classes -- ) [ ensure-table ] each ;

: insert-tuple ( tuple -- )
    dup class ensure-defined-persistent
    db-columns find-primary-key db-assigned-id-spec?
    [ insert-db-assigned-statement ] [ insert-user-assigned-statement ] if ;

: update-tuple ( tuple -- )
    dup class ensure-defined-persistent
    db-connection get update-statements>> [ <update-tuple-statement> ] cache
    [ bind-tuple ] keep execute-statement ;

: delete-tuples ( tuple -- )
    dup
    dup class ensure-defined-persistent
    <delete-tuples-statement> [
        [ bind-tuple ] keep execute-statement
    ] with-disposal ;

: select-tuples ( query/tuple -- tuples )
    >query [ tuple>> ] [ query>statement ] bi do-select ;

: select-tuple ( query/tuple -- tuple/f )
    >query 1 >>limit [ tuple>> ] [ query>statement ] bi
    do-select [ f ] [ first ] if-empty ;

: count-tuples ( query/tuple -- n )
    >query [ tuple>> ] [ <count-statement> ] bi do-count
    dup length 1 =
    [ first first string>number ] [ [ first string>number ] map ] if ;
