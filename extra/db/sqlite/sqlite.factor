! Copyright (C) 2005, 2008 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assocs classes compiler db
hashtables io.files kernel math math.parser namespaces
prettyprint sequences strings classes.tuple alien.c-types
continuations db.sqlite.lib db.sqlite.ffi db.tuples
words combinators.lib db.types combinators
io namespaces.lib accessors ;
IN: db.sqlite

TUPLE: sqlite-db < db path ;

M: sqlite-db make-db* ( path db -- db )
    swap >>path ;

M: sqlite-db db-open ( db -- db )
    [ path>> sqlite-open ] [ swap >>handle ] bi ;

M: sqlite-db db-close ( handle -- ) sqlite-close ;
M: sqlite-db dispose ( db -- ) dispose-db ;

TUPLE: sqlite-statement < throwable-statement ;

TUPLE: sqlite-result-set < result-set has-more? ;

M: sqlite-db <simple-statement> ( str in out -- obj )
    <prepared-statement> ;

M: sqlite-db <prepared-statement> ( str in out -- obj )
    sqlite-statement construct-statement ;

: sqlite-maybe-prepare ( statement -- statement )
    dup handle>> [
        db get handle>> over sql>> sqlite-prepare
        >>handle
    ] unless ;

M: sqlite-statement dispose ( statement -- )
    handle>>
    [ [ sqlite3_reset drop ] keep sqlite-finalize ] when* ;

M: sqlite-result-set dispose ( result-set -- )
    f >>handle drop ;

: sqlite-bind ( triples handle -- )
    swap [ first3 sqlite-bind-type ] with each ;

: reset-statement ( statement -- )
    sqlite-maybe-prepare handle>> sqlite-reset ;

M: sqlite-statement bind-statement* ( statement -- )
    sqlite-maybe-prepare
    dup statement-bound? [ dup reset-statement ] when
    [ statement-bind-params ] [ statement-handle ] bi
    sqlite-bind ;

M: sqlite-statement bind-tuple ( tuple statement -- )
    [
        in-params>>
        [
            [ column-name>> ":" prepend ]
            [ slot-name>> rot get-slot-named ]
            [ type>> ] tri 3array
        ] with map
    ] keep
    bind-statement ;

: last-insert-id ( -- id )
    db get db-handle sqlite3_last_insert_rowid
    dup zero? [ "last-id failed" throw ] when ;

M: sqlite-db insert-tuple* ( tuple statement -- )
    execute-statement last-insert-id >>primary-key drop ;

M: sqlite-result-set #columns ( result-set -- n )
    handle>> sqlite-#columns ;

M: sqlite-result-set row-column ( result-set n -- obj )
    [ handle>> ] [ sqlite-column ] bi* ;

M: sqlite-result-set row-column-typed ( result-set n -- obj )
    dup pick out-params>> nth type>>
    >r >r handle>> r> r> sqlite-column-typed ;

M: sqlite-result-set advance-row ( result-set -- )
    dup handle>> sqlite-next >>has-more? drop ;

M: sqlite-result-set more-rows? ( result-set -- ? )
    has-more?>> ;

M: sqlite-statement query-results ( query -- result-set )
    sqlite-maybe-prepare
    dup handle>> sqlite-result-set construct-result-set
    dup advance-row ;

M: sqlite-db begin-transaction ( -- ) "BEGIN" sql-command ;
M: sqlite-db commit-transaction ( -- ) "COMMIT" sql-command ;
M: sqlite-db rollback-transaction ( -- ) "ROLLBACK" sql-command ;

: sqlite-make ( class quot -- )
    >r sql-props r>
    { "" { } { } } nmake <simple-statement> ; inline

M: sqlite-db create-sql-statement ( class -- statement )
    [
        "create table " 0% 0%
        "(" 0% [ ", " 0% ] [
            dup column-name>> 0%
            " " 0%
            dup type>> t lookup-type 0%
            modifiers 0%
        ] interleave ");" 0%
    ] sqlite-make ;

M: sqlite-db drop-sql-statement ( class -- statement )
    [ "drop table " 0% 0% ";" 0% drop ] sqlite-make ;

M: sqlite-db <insert-native-statement> ( tuple -- statement )
    [
        "insert into " 0% 0%
        "(" 0%
        maybe-remove-id
        dup [ ", " 0% ] [ column-name>> 0% ] interleave
        ") values(" 0%
        [ ", " 0% ] [ bind% ] interleave
        ");" 0%
    ] sqlite-make ;

M: sqlite-db <insert-nonnative-statement> ( tuple -- statement )
    <insert-native-statement> ;

: where-primary-key% ( specs -- )
    " where " 0%
    find-primary-key dup column-name>> 0% " = " 0% bind% ;

: where-clause ( specs -- )
    " where " 0%
    [ " and " 0% ] [ dup column-name>> 0% " = " 0% bind% ] interleave ;

M: sqlite-db <update-tuple-statement> ( class -- statement )
    [
        "update " 0%
        0%
        " set " 0%
        dup remove-id
        [ ", " 0% ] [ dup column-name>> 0% " = " 0% bind% ] interleave
        where-primary-key%
    ] sqlite-make ;

M: sqlite-db <delete-tuple-statement> ( specs table -- sql )
    [
        "delete from " 0% 0%
        " where " 0%
        find-primary-key
        dup column-name>> 0% " = " 0% bind%
    ] sqlite-make ;

! : select-interval ( interval name -- ) ;
! : select-sequence ( seq name -- ) ;

M: sqlite-db bind% ( spec -- )
    dup 1, column-name>> ":" prepend 0% ;

M: sqlite-db <select-by-slots-statement> ( tuple class -- statement )
    [
        "select " 0%
        over [ ", " 0% ]
        [ dup column-name>> 0% 2, ] interleave

        " from " 0% 0%
        [ column-name>> swap get-slot-named ] with subset
        dup empty? [ drop ] [ where-clause ] if ";" 0%
    ] sqlite-make ;

M: sqlite-db modifier-table ( -- hashtable )
    H{
        { +native-id+ "primary key" }
        { +assigned-id+ "primary key" }
        { +random-id+ "primary key" }
        ! { +nonnative-id+ "primary key" }
        { +autoincrement+ "autoincrement" }
        { +unique+ "unique" }
        { +default+ "default" }
        { +null+ "null" }
        { +not-null+ "not null" }
    } ;

M: sqlite-db compound-modifier ( str obj -- str' ) compound-type ;

M: sqlite-db compound-type ( str seq -- str' )
    over {
        { "default" [ first number>string join-space ] }
        [ 2drop ] !  "no sqlite compound data type" 3array throw ]
    } case ;

M: sqlite-db type-table ( -- assoc )
    H{
        { +native-id+ "integer primary key" }
        { +random-id+ "integer primary key" }
        { INTEGER "integer" }
        { TEXT "text" }
        { VARCHAR "text" }
        { DATE "date" }
        { TIME "time" }
        { DATETIME "datetime" }
        { TIMESTAMP "timestamp" }
        { DOUBLE "real" }
        { BLOB "blob" }
        { FACTOR-BLOB "blob" }
    } ;

M: sqlite-db create-type-table ( symbol -- str ) type-table ;
