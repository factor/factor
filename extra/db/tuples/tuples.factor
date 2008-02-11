USING: arrays assocs classes db kernel namespaces
tuples words sequences slots slots.private math
math.parser io prettyprint db.types ;
USE: continuations
IN: db.tuples

! only take a tuple if you have to extract things from it
! otherwise take a class
! primary-key vs primary-key-spec
! define-persistent should enforce a primary key
! in sqlite, defining a new primary key makes it an alias for rowid, _rowid_, and oid
! -sql outputs sql code
! table - string
! columns - seq of column specifiers

: db-columns ( class -- obj )
    "db-columns" word-prop ;

: db-table ( class -- obj )
    "db-table" word-prop ;


: slot-spec-named ( str class -- slot-spec )
    "slots" word-prop [ slot-spec-name = ] with find nip ;

: offset-of-slot ( str obj -- n )
    class slot-spec-named slot-spec-offset ;

: get-slot-named ( str obj -- value )
    tuck offset-of-slot slot ;

: set-slot-named ( value str obj -- )
    tuck offset-of-slot set-slot ;
    

: primary-key-spec ( class -- spec )
    db-columns [ primary-key? ] find nip ;
    
: primary-key ( tuple -- obj )
    dup class primary-key-spec get-slot-named ;

: set-primary-key ( obj tuple -- )
    [ class primary-key-spec first ] keep
    set-slot-named ;


: cache-statement ( columns class assoc quot -- statement )
    [ db-table dupd ] swap
    [ <prepared-statement> ] 3compose cache nip ; inline

HOOK: create-sql db ( columns table -- sql )
HOOK: drop-sql db ( columns table -- sql )
HOOK: insert-sql* db ( columns table -- sql )
HOOK: update-sql* db ( columns table -- sql )
HOOK: delete-sql* db ( columns table -- sql )
HOOK: select-sql* db ( columns table -- sql )

: insert-sql ( columns class -- statement )
    db get db-insert-statements [ insert-sql* ] cache-statement ;

: update-sql ( columns class -- statement )
    db get db-update-statements [ update-sql* ] cache-statement ;

: delete-sql ( columns class -- statement )
    db get db-delete-statements [ delete-sql* ] cache-statement ;

: select-sql ( columns class -- statement )
    db get db-select-statements [ select-sql* ] cache-statement ;

HOOK: tuple>params db ( columns tuple -- obj )

: tuple-statement ( columns tuple quot -- statement )
    >r [ tuple>params ] 2keep class r> call
    [ bind-statement ] keep ;

: do-tuple-statement ( tuple columns-quot statement-quot -- )
    >r [ class db-columns ] swap compose keep
    r> tuple-statement dup . execute-statement ;

: create-table ( class -- )
    dup db-columns swap db-table create-sql sql-command ;
    
: insert-tuple ( tuple -- )
    [
        [ maybe-remove-id ] [ insert-sql ] do-tuple-statement
        last-id
    ] keep set-primary-key ;

: update-tuple ( tuple -- )
    [ ] [ update-sql ] do-tuple-statement ;

: delete-tuple ( tuple -- )
    [ [ primary-key? ] subset ] [ delete-sql ] do-tuple-statement ;

! : select-tuple ( tuple -- )
  !  [ select-sql ] bind-tuple do-query ;

: persist ( tuple -- )
    dup primary-key [ update-tuple ] [ insert-tuple ] if ;

! PERSISTENT:

: define-persistent ( class table columns -- )
    >r dupd "db-table" set-word-prop r>
    "db-columns" set-word-prop ;

: define-relation ( spec -- )
    drop ;








