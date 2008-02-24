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

! returns a sequence of prepared-statements
HOOK: create-sql-statement db ( class -- obj )
HOOK: drop-sql-statement db ( class -- obj )

HOOK: <insert-native-statement> db ( tuple -- obj )
HOOK: <insert-assigned-statement> db ( tuple -- obj )

HOOK: <update-tuple-statement> db ( tuple -- obj )
HOOK: <update-tuples-statement> db ( tuple -- obj )

HOOK: <delete-tuple-statement> db ( tuple -- obj )
HOOK: <delete-tuples-statement> db ( tuple -- obj )

HOOK: row-column-typed db ( result-set n type -- sql )

: resulting-tuple ( class out-params row -- tuple )
    >r >r construct-empty r> r> rot [
        >r [ sql-spec-type sql-type>factor-type ] keep
        sql-spec-slot-name r> set-slot-named
    ] curry 2each ;

: query-tuple ( tuple statement -- seq )
    dupd
    [ query-results [ sql-row ] with-disposal ] keep
    statement-out-params rot [
        >r [ sql-spec-type sql-type>factor-type ] keep
        sql-spec-slot-name r> set-slot-named
    ] curry 2each ;
 
: query-tuples ( tuple statement -- seq )
    dup query-results [
        statement-out-params [
break
            >r [ sql-spec-type sql-type>factor-type ] keep
            sql-spec-slot-name r> set-slot-named
        ] with with query-map
    ] with-disposal ; 

: sql-props ( class -- columns table )
    dup db-columns swap db-table ;

: create-table ( class -- ) create-sql-statement execute-statement ;
: drop-table ( class -- ) drop-sql-statement execute-statement ;

: insert-native ( tuple -- )
    dup class <insert-native-statement>
    [ bind-tuple ] 2keep query-tuple drop ;

: insert-assigned ( tuple -- )
    dup <insert-assigned-statement>
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

! : persist ( tuple -- )

HOOK: delete-by-id db ( tuple -- )
! : delete-tuple ( tuple -- ) -one-sql execute-statement ;
! : delete-tuples ( seq -- ) delete-many-sql execute-statement ;

HOOK: <select-by-slots-statement> db ( tuple -- tuple )

: setup-select ( tuple -- tuple statement )
    dup dup class <select-by-slots-statement>
    [ bind-tuple ] 2keep ;

: select-tuple ( tuple -- tuple )
    setup-select query-tuple ;

: select-tuples ( tuple -- tuple )
    setup-select query-tuples ;

! uniqueResult
