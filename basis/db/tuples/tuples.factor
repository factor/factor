! Copyright (C) 2008 Doug Coleman.
! Copyright (C) 2018 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes classes.tuple
combinators.short-circuit continuations db db.errors db.types
destructors kernel math.parser namespaces sequences sets words ;
IN: db.tuples

HOOK: create-sql-statement db-connection ( class -- object )
HOOK: drop-sql-statement db-connection ( class -- object )

HOOK: <insert-db-assigned-statement> db-connection ( class -- object )
HOOK: <insert-user-assigned-statement> db-connection ( class -- object )
HOOK: <update-tuple-statement> db-connection ( class -- object )
HOOK: <delete-tuples-statement> db-connection ( tuple class -- object )
HOOK: <select-by-slots-statement> db-connection ( tuple class -- statement )
HOOK: <count-statement> db-connection ( query -- statement )
HOOK: query>statement db-connection ( query -- statement )
HOOK: insert-tuple-set-key db-connection ( tuple statement -- )

<PRIVATE

SYMBOL: sql-counter

: next-sql-counter ( -- str )
    sql-counter [ inc ] [ get ] bi number>string ;

GENERIC: eval-generator ( singleton -- object )

: resulting-tuple ( exemplar-tuple row out-params -- tuple )
    rot class-of new [
        '[ slot-name>> _ set-slot-named ] 2each
    ] keep ;

: query-tuples-each ( exemplar-tuple statement quot: ( tuple -- ) -- )
    [ [ out-params>> ] keep query-results ] dip '[
        [ sql-row-typed swap resulting-tuple @ ] 2with query-each
    ] with-disposal ; inline

: query-tuples ( exemplar-tuple statement -- seq )
    [ ] collector [ query-tuples-each ] dip { } like ;

: query-modify-tuple ( tuple statement -- )
    [ query-results [ sql-row-typed ] with-disposal ] keep
    out-params>> rot '[ slot-name>> _ set-slot-named ] 2each ;

: with-disposals ( object quotation -- )
    over sequence? [
        over '[ _ dispose-each ] finally
    ] [
        with-disposal
    ] if ; inline

: insert-db-assigned-statement ( tuple -- )
    dup class-of
    db-connection get insert-statements>>
    [ <insert-db-assigned-statement> ] cache
    [ bind-tuple ] 2keep insert-tuple-set-key ;

: insert-user-assigned-statement ( tuple -- )
    dup class-of
    db-connection get insert-statements>>
    [ <insert-user-assigned-statement> ] cache
    [ bind-tuple ] keep execute-statement ;

: do-each-tuple ( exemplar-tuple statement quot: ( tuple -- ) -- tuples )
    '[ [ bind-tuple ] [ _ query-tuples-each ] 2bi ] with-disposal
    ; inline

: do-select ( exemplar-tuple statement -- tuples )
    [ [ bind-tuple ] [ query-tuples ] 2bi ] with-disposal ;

: do-count ( exemplar-tuple statement -- tuples )
    [ [ bind-tuple ] [ nip default-query ] 2bi ] with-disposal ;

PRIVATE>

! High level
ERROR: no-slots-named class seq ;

: check-columns ( columns class -- )
    [ nip ] [
        [ keys ]
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
    [ '[ [ _ drop-table ] ignore-table-missing ] ignore-function-missing ]
    [ create-table ] bi ;

: ensure-table ( class -- )
    '[ [ _ create-table ] ignore-table-exists ] ignore-function-exists ;

: ensure-tables ( classes -- ) [ ensure-table ] each ;

: insert-tuple ( tuple -- )
    dup class-of ensure-defined-persistent db-assigned?
    [ insert-db-assigned-statement ] [ insert-user-assigned-statement ] if ;

: update-tuple ( tuple -- )
    dup class-of ensure-defined-persistent
    db-connection get update-statements>> [ <update-tuple-statement> ] cache
    [ bind-tuple ] keep execute-statement ;

: delete-tuples ( tuple -- )
    dup
    dup class-of ensure-defined-persistent
    <delete-tuples-statement> [
        [ bind-tuple ] keep execute-statement
    ] with-disposal ;

: select-tuples ( query/tuple -- tuples )
    >query [ tuple>> ] [ query>statement ] bi do-select ;

: select-tuple ( query/tuple -- tuple/f )
    >query 1 >>limit [ tuple>> ] [ query>statement ] bi
    do-select ?first ;

: count-tuples ( query/tuple -- n )
    >query [ tuple>> ] [ <count-statement> ] bi do-count
    [ first string>number ] map dup length 1 = [ first ] when ;

: each-tuple ( query/tuple quot: ( tuple -- ) -- )
    [ >query [ tuple>> ] [ query>statement ] bi ] dip do-each-tuple
    ; inline

: update-tuples ( query/tuple quot: ( tuple -- tuple'/f ) -- )
    '[ @ [ update-tuple ] when* ] each-tuple ; inline

: reject-tuples ( query/tuple quot: ( tuple -- ? ) -- )
    '[ dup @ [ delete-tuples ] [ drop ] if ] each-tuple ; inline
