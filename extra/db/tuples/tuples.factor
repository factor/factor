! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes db kernel namespaces
tuples words sequences slots slots.private math
math.parser io prettyprint db.types continuations
mirrors sequences.lib ;
IN: db.tuples

: db-table ( class -- obj ) "db-table" word-prop ;
: db-columns ( class -- obj ) "db-columns" word-prop ;
: db-relations ( class -- obj ) "db-relations" word-prop ;

TUPLE: no-slot-named ;
: no-slot-named ( -- * ) T{ no-slot-named } throw ;

: slot-spec-named ( str class -- slot-spec )
    "slots" word-prop [ slot-spec-name = ] with find nip
    [ no-slot-named ] unless* ;

: offset-of-slot ( str obj -- n )
    class slot-spec-named slot-spec-offset ;

: get-slot-named ( str obj -- value )
    tuck offset-of-slot [ no-slot-named ] unless* slot ;

: set-slot-named ( value str obj -- )
    tuck offset-of-slot [ no-slot-named ] unless* set-slot ;

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

HOOK: create-sql db ( columns table -- seq )
HOOK: drop-sql db ( columns table -- seq )

HOOK: insert-sql* db ( columns table -- sql slot-names )
HOOK: update-sql* db ( columns table -- sql slot-names )
HOOK: delete-sql* db ( columns table -- sql slot-names )
HOOK: select-sql db ( tuple -- seq/statement )
HOOK: select-relations-sql db ( tuple -- seq/statement )

HOOK: row-column-typed db ( result-set n type -- sql )
HOOK: sql-type>factor-type db ( obj type -- obj )
HOOK: tuple>params db ( columns tuple -- obj )

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
    >r dupd "db-table" set-word-prop dup r>
    [ relation? ] partition swapd
    [ spec>tuple ] map
    "db-columns" set-word-prop
    "db-relations" set-word-prop ;

: tuple>filled-slots ( tuple -- alist )
    dup <mirror> mirror-slots [ slot-spec-name ] map
    swap tuple-slots 2array flip [ nip ] assoc-subset ;

! [ tuple>filled-slots ] keep
! [ >r first r> get-slot-named ] curry each

SYMBOL: building-seq 
: get-building-seq ( n -- seq )
    building-seq get nth ;

: n, get-building-seq push ;
: n% get-building-seq push-all ;
: n# >r number>string r> n% ;

: 0, 0 n, ;
: 0% 0 n% ;
: 0# 0 n# ;
: 1, 1 n, ;
: 1% 1 n% ;
: 1# 1 n# ;
: 2, 2 n, ;
: 2% 2 n% ;
: 2# 2 n# ;

: nmake ( quot exemplars -- seqs )
    dup length dup zero? [ 1+ ] when
    [
        [
            [ drop 1024 swap new-resizable ] 2map
            [ building-seq set call ] keep
        ] 2keep >r [ like ] 2map r> firstn 
    ] with-scope ;
