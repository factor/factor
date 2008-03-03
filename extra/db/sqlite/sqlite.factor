! Copyright (C) 2005, 2008 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assocs classes compiler db
hashtables io.files kernel math math.parser namespaces
prettyprint sequences strings tuples alien.c-types
continuations db.sqlite.lib db.sqlite.ffi db.tuples
words combinators.lib db.types combinators tools.walker
combinators.cleave ;
IN: db.sqlite

TUPLE: sqlite-db path ;

M: sqlite-db make-db* ( path db -- db )
    [ set-sqlite-db-path ] keep ;

M: sqlite-db db-open ( db -- )
    dup sqlite-db-path sqlite-open <db>
    swap set-delegate ;

M: sqlite-db db-close ( handle -- )
    sqlite-close ;

M: sqlite-db dispose ( db -- ) dispose-db ;

TUPLE: sqlite-statement ;

TUPLE: sqlite-result-set has-more? ;

M: sqlite-db <simple-statement> ( str -- obj )
    <prepared-statement> ;

M: sqlite-db <prepared-statement> ( str -- obj )
    {
        set-statement-sql
        set-statement-in-params
        set-statement-out-params
    } statement construct
    db get db-handle over statement-sql sqlite-prepare
    over set-statement-handle
    sqlite-statement construct-delegate ;

M: sqlite-statement dispose ( statement -- )
    statement-handle sqlite-finalize ;

M: sqlite-result-set dispose ( result-set -- )
    f swap set-result-set-handle ;

: sqlite-bind ( triples handle -- )
    swap [ first3 sqlite-bind-type ] with each ;

: reset-statement ( statement -- )
    statement-handle sqlite-reset ;

M: sqlite-statement bind-statement* ( statement -- )
    dup statement-bound? [ dup reset-statement ] when
    [ statement-bind-params ] [ statement-handle ] bi
    sqlite-bind ;

M: sqlite-statement bind-tuple ( tuple statement -- )
    [
        statement-in-params
        [
            [ sql-spec-column-name ":" swap append ]
            [ sql-spec-slot-name rot get-slot-named ]
            [ sql-spec-type ] tri 3array
        ] with map
    ] keep
    bind-statement ;

: last-insert-id ( -- id )
    db get db-handle sqlite3_last_insert_rowid
    dup zero? [ "last-id failed" throw ] when ;

M: sqlite-db insert-tuple* ( tuple statement -- )
    execute-statement last-insert-id swap set-primary-key ;

M: sqlite-result-set #columns ( result-set -- n )
    result-set-handle sqlite-#columns ;

M: sqlite-result-set row-column ( result-set n -- obj )
    >r result-set-handle r> sqlite-column ;

M: sqlite-result-set row-column-typed ( result-set n type -- obj )
    >r result-set-handle r> sqlite-column-typed ;

M: sqlite-result-set advance-row ( result-set -- )
    [ result-set-handle sqlite-next ] keep
    set-sqlite-result-set-has-more? ;

M: sqlite-result-set more-rows? ( result-set -- ? )
    sqlite-result-set-has-more? ;

M: sqlite-statement query-results ( query -- result-set )
    dup statement-handle sqlite-result-set <result-set>
    dup advance-row ;

M: sqlite-db begin-transaction ( -- )
    "BEGIN" sql-command ;

M: sqlite-db commit-transaction ( -- )
    "COMMIT" sql-command ;

M: sqlite-db rollback-transaction ( -- )
    "ROLLBACK" sql-command ;

: sqlite-make ( class quot -- )
    >r sql-props r>
    { "" { } { } } nmake <simple-statement> ;

M: sqlite-db create-sql-statement ( class -- statement )
    [
        "create table " 0% 0%
        "(" 0% [ ", " 0% ] [
            dup sql-spec-column-name 0%
            " " 0%
            dup sql-spec-type t lookup-type 0%
            modifiers 0%
        ] interleave ");" 0%
    ] sqlite-make ;

M: sqlite-db drop-sql-statement ( class -- statement )
    [
        "drop table " 0% 0% ";" 0% drop
    ] sqlite-make ;

M: sqlite-db <insert-native-statement> ( tuple -- statement )
    [
        "insert into " 0% 0%
        "(" 0%
        maybe-remove-id
        dup [ ", " 0% ] [ sql-spec-column-name 0% ] interleave
        ") values(" 0%
        [ ", " 0% ] [ bind% ] interleave
        ");" 0%
    ] sqlite-make ;

M: sqlite-db <insert-assigned-statement> ( tuple -- statement )
    <insert-native-statement> ;

: where-primary-key% ( specs -- )
    " where " 0%
    find-primary-key dup sql-spec-column-name 0% " = " 0% bind% ;

M: sqlite-db <update-tuple-statement> ( class -- statement )
    [
        "update " 0%
        0%
        " set " 0%
        dup remove-id
        [ ", " 0% ] [ dup sql-spec-column-name 0% " = " 0% bind% ] interleave
        where-primary-key%
    ] sqlite-make ;

M: sqlite-db <delete-tuple-statement> ( specs table -- sql )
    [
        "delete from " 0% 0%
        " where " 0%
        find-primary-key
        dup sql-spec-column-name 0% " = " 0% bind%
    ] sqlite-make ;

! : select-interval ( interval name -- ) ;
! : select-sequence ( seq name -- ) ;

M: sqlite-db bind% ( spec -- )
    dup 1, sql-spec-column-name ":" swap append 0% ;

M: sqlite-db <select-by-slots-statement> ( tuple class -- statement )
    [
        "select " 0%
        over [ ", " 0% ]
        [ dup sql-spec-column-name 0% 2, ] interleave

        " from " 0% 0%
        [ sql-spec-slot-name swap get-slot-named ] with subset
        dup empty? [ drop ] [
            " where " 0%
            [ ", " 0% ]
            [ dup sql-spec-column-name 0% " = " 0% bind% ] interleave
        ] if
        ";" 0%
    ] sqlite-make ;

M: sqlite-db modifier-table ( -- hashtable )
    H{
        { +native-id+ "primary key" }
        { +assigned-id+ "primary key" }
        { +autoincrement+ "autoincrement" }
        { +unique+ "unique" }
        { +default+ "default" }
        { +null+ "null" }
        { +not-null+ "not null" }
    } ;

M: sqlite-db compound-modifier ( str obj -- newstr )
    compound-type ;

M: sqlite-db compound-type ( str seq -- newstr )
    over {
        { "default" [ first number>string join-space ] }
        [ 2drop ] !  "no sqlite compound data type" 3array throw ]
    } case ;

M: sqlite-db type-table ( -- assoc )
    H{
        { +native-id+ "integer primary key" }
        { INTEGER "integer" }
        { TEXT "text" }
        { VARCHAR "text" }
        { TIMESTAMP "timestamp" }
        { DOUBLE "real" }
    } ;

M: sqlite-db create-type-table
    type-table ;
