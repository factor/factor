! Copyright (C) 2005, 2008 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assocs classes compiler db
hashtables io.files kernel math math.parser namespaces
prettyprint sequences strings tuples alien.c-types
continuations db.sqlite.lib db.sqlite.ffi db.tuples
words combinators.lib db.types ;
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

TUPLE: sqlite-result-set ;
: <sqlite-result-set> ( query -- sqlite-result-set )
    dup statement-handle sqlite-result-set <result-set> ;

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

M: sqlite-statement bind-statement* ( assoc statement -- )
    statement-handle swap sqlite-bind-assoc ;

M: sqlite-statement rebind-statement ( assoc statement -- )
    dup statement-handle sqlite-reset
    statement-handle swap sqlite-bind-assoc ;

M: sqlite-statement execute-statement ( statement -- )
    statement-handle sqlite-next drop ;

M: sqlite-result-set #columns ( result-set -- n )
    result-set-handle sqlite-#columns ;

M: sqlite-result-set row-column ( result-set n -- obj )
    >r result-set-handle r> sqlite-column ;

M: sqlite-result-set advance-row ( result-set -- handle ? )
    result-set-handle sqlite-next ;

M: sqlite-statement query-results ( query -- result-set )
    dup statement-handle sqlite-result-set <result-set> ;

M: sqlite-db begin-transaction ( -- )
    "BEGIN" sql-command ;

M: sqlite-db commit-transaction ( -- )
    "COMMIT" sql-command ;

M: sqlite-db rollback-transaction ( -- )
    "ROLLBACK" sql-command ;

M: sqlite-db create-sql ( columns table -- sql )
    [
        "create table " % %
        " (" % [ ", " % ] [
            dup second % " " %
            dup third >sql-type % " " %
            sql-modifiers " " join %
        ] interleave ")" %
    ] "" make ;

M: sqlite-db insert-sql* ( columns table -- sql )
    [
        "insert into " %
        %
        "(" %
        dup [ ", " % ] [ second % ] interleave
        ") " %
        " values (" %
        [ ", " % ] [ ":" % second % ] interleave
        ")" %
    ] "" make ;

M: sqlite-db update-sql* ( columns table -- sql )
    [
        "update " %
        %
        " set " %
        dup remove-id
        [ ", " % ] [ second dup % " = :" % % ] interleave
        " where " %
        [ primary-key? ] find nip second dup % " = :" % %
    ] "" make ;

M: sqlite-db delete-sql* ( columns table -- sql )
    [
    break
        "delete from " %
        %
        " where " %
        first second dup % " = :" % %
    ] "" make dup . ;

M: sqlite-db select-sql* ( columns table -- sql )
    [
        "select ROWID, " %
        swap [ ", " % ] [ second % ] interleave
        " from " %
        %
        " where ROWID = :ID" %
    ] "" make ;

M: sqlite-db tuple>params ( columns tuple -- obj )
    [
        >r [ second ":" swap append ] keep first r> get-slot-named
        number>string*
    ] curry { } map>assoc  ;
    
M: sqlite-db last-id ( -- id )
    db get db-handle sqlite3_last_insert_rowid ;


: sqlite-db-modifiers ( -- hashtable )
    H{
        { +native-id+ "primary key" }
        { +assigned-id+ "primary key" }
        { +autoincrement+ "autoincrement" }
        { +unique+ "unique" }
        { +default+ "default" }
        { +null+ "null" }
        { +not-null+ "not null" }
    } ;

M: sqlite-db sql-modifiers* ( modifiers -- str )
    sqlite-db-modifiers swap [
        dup array? [
            first2
            >r swap at r> number>string*
            " " swap 3append
        ] [
            swap at
        ] if
    ] with map [ ] subset ;

: sqlite-type-hash ( -- assoc )
    H{
        { INTEGER "integer" }
        { TEXT "text" }
        { VARCHAR "text" }
    } ;

M: sqlite-db >sql-type ( obj -- str )
    dup pair? [
        first >sql-type
    ] [
        sqlite-type-hash at* [ T{ no-sql-type } throw ] unless
    ] if ;

! HOOK: get-column-value ( n result-set type -- )
! M: sqlite get-column-value { { "TEXT" get-text-column } { 
! "INTEGER" get-integer-column } ... } case ;

