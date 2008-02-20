! Copyright (C) 2005, 2008 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assocs classes compiler db
hashtables io.files kernel math math.parser namespaces
prettyprint sequences strings tuples alien.c-types
continuations db.sqlite.lib db.sqlite.ffi db.tuples
words combinators.lib db.types combinators ;
IN: db.sqlite

TUPLE: sqlite-db path ;
C: <sqlite-db> sqlite-db

M: sqlite-db db-open ( db -- )
    dup sqlite-db-path sqlite-open <db>
    swap set-delegate ;

M: sqlite-db db-close ( handle -- )
    sqlite-close ;

M: sqlite-db dispose ( db -- ) dispose-db ;

: with-sqlite ( path quot -- )
    >r <sqlite-db> r> with-db ; inline

TUPLE: sqlite-statement ;
C: <sqlite-statement> sqlite-statement

TUPLE: sqlite-result-set has-more? ;

M: sqlite-db <simple-statement> ( str -- obj )
    <prepared-statement> ;

M: sqlite-db <prepared-statement> ( str -- obj )
    db get db-handle over sqlite-prepare
    { set-statement-sql set-statement-handle } statement construct
    <sqlite-statement> [ set-delegate ] keep ;

M: sqlite-statement dispose ( statement -- )
    statement-handle sqlite-finalize ;

M: sqlite-result-set dispose ( result-set -- )
    f swap set-result-set-handle ;

: sqlite-bind ( triples handle -- )
    swap [ first3 sqlite-bind-type ] with each ;

M: sqlite-statement bind-statement* ( triples statement -- )
    statement-handle sqlite-bind ;

M: sqlite-statement reset-statement ( statement -- )
    statement-handle sqlite-reset ;

: last-insert-id ( -- id )
    db get db-handle sqlite3_last_insert_rowid
    dup zero? [ "last-id failed" throw ] when ;

M: sqlite-statement insert-statement ( statement -- id )
    execute-statement last-insert-id ;

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

M: sqlite-db create-sql ( specs table -- sql )
    [
        "create table " % %
        "(" % [ ", " % ] [
            dup sql-spec-column-name %
            " " %
            dup sql-spec-type t lookup-type %
            modifiers%
        ] interleave ");" %
    ] "" make ;

M: sqlite-db drop-sql ( specs table -- sql )
    [
        "drop table " % % ";" %
    ] "" make ;

M: sqlite-db insert-sql* ( specs table -- sql )
    [
        "insert into " % %
        "(" %
        maybe-remove-id
        dup [ ", " % ] [ sql-spec-column-name % ] interleave
        ") values(" %
        [ ", " % ] [ ":" % sql-spec-column-name % ] interleave
        ");" %
    ] "" make ;

: where-primary-key% ( specs -- )
    " where " %
    find-primary-key sql-spec-column-name dup % " = :" % % ;

M: sqlite-db update-sql* ( specs table -- sql )
    [
        "update " %
        %
        " set " %
        dup remove-id
        [ ", " % ] [ sql-spec-column-name dup % " = :" % % ] interleave
        where-primary-key%
    ] "" make ;

M: sqlite-db delete-sql* ( specs table -- sql )
    [
        "delete from " % %
        " where " %
        find-primary-key
        sql-spec-column-name dup % " = :" % %
    ] "" make ;

: select-interval ( interval name -- )
    ;

: select-sequence ( seq name -- )
    ;

: select-by-slots-sql ( tuple -- sql out-specs )
    [
        "select from " 0% dup class db-table 0%
        " " 0%
        dup class db-columns [ ", " 0% ]
        [ dup sql-spec-column-name 0% 1, ] interleave

        dup class db-columns
        [ sql-spec-slot-name swap get-slot-named ] with subset
        " where " 0%
        [ ", " 0% ]
        [ sql-spec-column-name dup 0% " = :" 0% 0% ] interleave
        ";" 0%
    ] { "" { } } nmake ;

M: sqlite-db select-sql ( tuple -- sql )
    select-by-slots-sql ;

M: sqlite-db tuple>params ( specs tuple -- obj )
    [
        >r [ second ":" swap append ] keep r>
        dupd >r first r> get-slot-named swap
        third 3array
    ] curry map ;

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

M: sqlite-db compound-type ( str seq -- )
    over {
        { "varchar" [ first number>string join-space ] }
        [ 2drop "" ] !  "no sqlite compound data type" 3array throw ]
    } case ;

M: sqlite-db type-table ( -- assoc )
    H{
        { +native-id+ "integer primary key" }
        { INTEGER "integer" }
        { TEXT "text" }
        { VARCHAR "varchar" }
        { TIMESTAMP "timestamp" }
        { DOUBLE "real" }
    } ;

M: sqlite-db create-type-table
    type-table ;

! HOOK: get-column-value ( n result-set type -- )
! M: sqlite get-column-value { { "TEXT" get-text-column } { 
! "INTEGER" get-integer-column } ... } case ;
