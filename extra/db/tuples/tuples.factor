! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes db kernel namespaces
tuples words sequences slots math
math.parser io prettyprint db.types continuations
mirrors sequences.lib tools.walker combinators.lib ;
IN: db.tuples

: define-persistent ( class table columns -- )
    >r dupd "db-table" set-word-prop dup r>
    [ relation? ] partition swapd
    dupd [ spec>tuple ] with map
    "db-columns" set-word-prop
    "db-relations" set-word-prop ;

: db-table ( class -- obj ) "db-table" word-prop ;
: db-columns ( class -- obj ) "db-columns" word-prop ;
: db-relations ( class -- obj ) "db-relations" word-prop ;

: set-primary-key ( key tuple -- )
    [
        class db-columns find-primary-key sql-spec-slot-name
    ] keep set-slot-named ;

! returns a sequence of prepared-statements
HOOK: create-sql-statement db ( class -- obj )
HOOK: drop-sql-statement db ( class -- obj )

HOOK: <insert-native-statement> db ( tuple -- obj )
HOOK: <insert-assigned-statement> db ( tuple -- obj )

HOOK: <update-tuple-statement> db ( tuple -- obj )
HOOK: <update-tuples-statement> db ( tuple -- obj )

HOOK: <delete-tuple-statement> db ( tuple -- obj )
HOOK: <delete-tuples-statement> db ( tuple -- obj )

HOOK: <select-by-slots-statement> db ( tuple -- tuple )

HOOK: row-column-typed db ( result-set n type -- sql )
HOOK: insert-tuple* db ( tuple statement -- )

: resulting-tuple ( row out-params -- tuple )
    dup first sql-spec-class construct-empty [
        [
            >r [ sql-spec-type sql-type>factor-type ] keep
            sql-spec-slot-name r> set-slot-named
        ] curry 2each
    ] keep ;

: query-tuples ( statement -- seq )
    [ statement-out-params ] keep query-results [
        ! out-parms result-set
        [
            sql-row swap resulting-tuple
        ] with query-map
    ] with-disposal ;
 
: query-modify-tuple ( tuple statement -- )
    [ query-results [ sql-row ] with-disposal ] keep
    statement-out-params rot [
        >r [ sql-spec-type sql-type>factor-type ] keep
        sql-spec-slot-name r> set-slot-named
    ] curry 2each ;

: sql-props ( class -- columns table )
    dup db-columns swap db-table ;

: create-table ( class -- ) create-sql-statement execute-statement ;
: drop-table ( class -- ) drop-sql-statement execute-statement ;

: insert-native ( tuple -- )
    dup class <insert-native-statement>
    [ bind-tuple ] 2keep insert-tuple* ;

: insert-assigned ( tuple -- )
    dup class <insert-assigned-statement>
    [ bind-tuple ] keep execute-statement ;

: insert-tuple ( tuple -- )
    dup class db-columns find-primary-key assigned-id? [
        insert-assigned
    ] [
        insert-native
    ] if ;

: update-tuple ( tuple -- )
    dup class <update-tuple-statement>
    [ bind-tuple ] keep execute-statement ;

: update-tuples ( seq -- )
    <update-tuples-statement> execute-statement ;

: persist ( tuple -- )
    dup class db-columns find-primary-key
    sql-spec-slot-name over get-slot-named
    [ update-tuple ] [ insert-tuple ] if ;

: delete-tuple ( tuple -- )
    dup class <delete-tuple-statement>
    [ bind-tuple ] keep execute-statement ;


: setup-select ( tuple -- statement )
    dup dup class <select-by-slots-statement>
    [ bind-tuple ] keep ;

: select-tuples ( tuple -- tuple ) setup-select query-tuples ;
: select-tuple ( tuple -- tuple/f ) select-tuples ?first ;
