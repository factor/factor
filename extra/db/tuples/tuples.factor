! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes db kernel namespaces
tuples words sequences slots slots.private math
math.parser io prettyprint db.types continuations ;
IN: db.tuples

: db-columns ( class -- obj ) "db-columns" word-prop ;
: db-table ( class -- obj ) "db-table" word-prop ;

TUPLE: no-slot-named ;
: no-slot-named ( -- * ) T{ no-slot-named } throw ;

: slot-spec-named ( str class -- slot-spec )
    "slots" word-prop [ slot-spec-name = ] with find nip ;

: offset-of-slot ( str obj -- n )
    class slot-spec-named dup [ slot-spec-offset ] when ;

DEFER: get-slot-named
: get-delegate-slot-named ( str obj -- value )
    delegate [ get-slot-named ] [ drop no-slot-named ] if* ;

: get-slot-named ( str obj -- value )
    2dup offset-of-slot [
        rot drop slot
    ] [
        get-delegate-slot-named
    ] if* ;

DEFER: set-slot-named
: set-delegate-slot-named ( value str obj -- )
    delegate [ set-slot-named ] [ 2drop no-slot-named ] if* ;

: set-slot-named ( value str obj -- )
    2dup offset-of-slot [
        rot drop set-slot
    ] [
        set-delegate-slot-named
    ] if* ;

: primary-key-spec ( class -- spec )
    db-columns [ primary-key? ] find nip ;
    
: primary-key ( tuple -- obj )
    dup class primary-key-spec first swap get-slot-named ;

: set-primary-key ( obj tuple -- )
    [ class primary-key-spec first ] keep
    set-slot-named ;

: cache-statement ( columns class assoc quot -- statement )
    [ db-table dupd ] swap
    [ <prepared-statement> ] 3compose cache nip ; inline

HOOK: create-sql db ( columns table -- seq )
HOOK: drop-sql db ( columns table -- seq )

HOOK: insert-sql* db ( columns table -- sql )
HOOK: update-sql* db ( columns table -- sql )
HOOK: delete-sql* db ( columns table -- sql )
HOOK: select-sql db ( tuple -- statement )

HOOK: row-column-typed db ( result-set n type -- sql )
HOOK: sql-type>factor-type db ( obj type -- obj )
HOOK: tuple>params db ( columns tuple -- obj )


HOOK: make-slot-names* db ( quot -- seq )
HOOK: column-slot-name% db ( spec -- )
HOOK: column-bind-name% db ( spec -- )

: make-slots-names ( quot -- seq str )
    [ make-slot-names* ] "" make ; inline
: slot-name% ( seq -- ) first % ;
: column-name% ( seq -- ) second % ;
: column-type% ( seq -- ) third % ;

: insert-sql ( columns class -- statement )
    db get db-insert-statements [ insert-sql* ] cache-statement ;

: update-sql ( columns class -- statement )
    db get db-update-statements [ update-sql* ] cache-statement ;

: delete-sql ( columns class -- statement )
    db get db-delete-statements [ delete-sql* ] cache-statement ;


: tuple-statement ( columns tuple quot -- statement )
    >r [ tuple>params ] 2keep class r> call
    2dup . .
    [ bind-statement ] keep ;

: make-tuple-statement ( tuple columns-quot statement-quot -- statement )
    >r [ class db-columns ] swap compose keep
    r> tuple-statement ;

: do-tuple-statement ( tuple columns-quot statement-quot -- )
    make-tuple-statement execute-statement ;

: create-table ( class -- )
    dup db-columns swap db-table create-sql sql-command ;
    
: drop-table ( class -- )
    dup db-columns swap db-table drop-sql sql-command ;

: insert-tuple ( tuple -- )
    [
        [ maybe-remove-id ] [ insert-sql ]
        make-tuple-statement insert-statement
    ] keep set-primary-key ;

: update-tuple ( tuple -- )
    [ ] [ update-sql ] do-tuple-statement ;

: delete-tuple ( tuple -- )
    [ [ primary-key? ] subset ] [ delete-sql ] do-tuple-statement ;

: select-tuple ( tuple -- )
    [ select-sql ] keep do-query ;

: persist ( tuple -- )
    dup primary-key [ update-tuple ] [ insert-tuple ] if ;

: define-persistent ( class table columns -- )
    >r dupd "db-table" set-word-prop r>
    "db-columns" set-word-prop ;

: define-relation ( spec -- )
    drop ;
