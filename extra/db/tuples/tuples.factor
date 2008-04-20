! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes db kernel namespaces
classes.tuple words sequences slots math
math.parser io prettyprint db.types continuations
mirrors sequences.lib tools.walker combinators.lib ;
IN: db.tuples

: define-persistent ( class table columns -- )
    >r dupd "db-table" set-word-prop dup r>
    [ relation? ] partition swapd
    dupd [ spec>tuple ] with map
    "db-columns" set-word-prop
    "db-relations" set-word-prop ;

ERROR: not-persistent ;

: db-table ( class -- obj )
    "db-table" word-prop [ not-persistent ] unless* ;

: db-columns ( class -- obj )
    "db-columns" word-prop ;

: db-relations ( class -- obj )
    "db-relations" word-prop ;

: set-primary-key ( key tuple -- )
    [
        class db-columns find-primary-key sql-spec-slot-name
    ] keep set-slot-named ;

SYMBOL: sql-counter
: next-sql-counter sql-counter [ inc ] [ get ] bi number>string ;

! returns a sequence of prepared-statements
HOOK: create-sql-statement db ( class -- obj )
HOOK: drop-sql-statement db ( class -- obj )

HOOK: <insert-native-statement> db ( class -- obj )
HOOK: <insert-nonnative-statement> db ( class -- obj )

HOOK: <update-tuple-statement> db ( class -- obj )
HOOK: <update-tuples-statement> db ( class -- obj )

HOOK: <delete-tuple-statement> db ( class -- obj )
HOOK: <delete-tuples-statement> db ( class -- obj )

HOOK: <select-by-slots-statement> db ( tuple class -- tuple )

HOOK: insert-tuple* db ( tuple statement -- )

: resulting-tuple ( row out-params -- tuple )
    dup first sql-spec-class new [
        [
            >r sql-spec-slot-name r> set-slot-named
        ] curry 2each
    ] keep ;

: query-tuples ( statement -- seq )
    [ statement-out-params ] keep query-results [
        [ sql-row-typed swap resulting-tuple ] with query-map
    ] with-disposal ;
 
: query-modify-tuple ( tuple statement -- )
    [ query-results [ sql-row-typed ] with-disposal ] keep
    statement-out-params rot [
        >r sql-spec-slot-name r> set-slot-named
    ] curry 2each ;

: sql-props ( class -- columns table )
    [ db-columns ] [ db-table ] bi ;

: with-disposals ( seq quot -- )
    over sequence? [
        [ with-disposal ] curry each
    ] [
        with-disposal
    ] if ;

: create-table ( class -- )
    create-sql-statement [ execute-statement ] with-disposals ;

: drop-table ( class -- )
    drop-sql-statement [ execute-statement ] with-disposals ;

: ensure-table ( class -- )
    [
        drop-sql-statement make-nonthrowable
        [ execute-statement ] with-disposals
    ] [ create-table ] bi ;

: insert-native ( tuple -- )
    dup class
    db get db-insert-statements [ <insert-native-statement> ] cache
    [ bind-tuple ] 2keep insert-tuple* ;

: insert-nonnative ( tuple -- )
    dup class
    db get db-insert-statements [ <insert-nonnative-statement> ] cache
    [ bind-tuple ] keep execute-statement ;

: insert-tuple ( tuple -- )
    dup class db-columns find-primary-key nonnative-id?
    [ insert-nonnative ] [ insert-native ] if ;

: update-tuple ( tuple -- )
    dup class
    db get db-update-statements [ <update-tuple-statement> ] cache
    [ bind-tuple ] keep execute-statement ;

: delete-tuple ( tuple -- )
    dup class
    db get db-delete-statements [ <delete-tuple-statement> ] cache
    [ bind-tuple ] keep execute-statement ;

: select-tuples ( tuple -- tuples )
    dup dup class <select-by-slots-statement> [
        [ bind-tuple ] keep query-tuples
    ] with-disposal ;

: select-tuple ( tuple -- tuple/f ) select-tuples ?first ;
