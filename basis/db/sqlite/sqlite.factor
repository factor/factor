! Copyright (C) 2005, 2008 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assocs classes compiler db hashtables
io.files kernel math math.parser namespaces prettyprint
sequences strings classes.tuple alien.c-types continuations
db.sqlite.lib db.sqlite.ffi db.tuples words db.types combinators
math.intervals io nmake accessors vectors math.ranges random
math.bitwise db.queries destructors db.tuples.private ;
IN: db.sqlite

TUPLE: sqlite-db < db path ;

M: sqlite-db make-db* ( path db -- db )
    swap >>path ;

M: sqlite-db db-open ( db -- db )
    dup path>> sqlite-open >>handle ;

M: sqlite-db db-close ( handle -- ) sqlite-close ;
M: sqlite-db dispose ( db -- ) db-dispose ;

TUPLE: sqlite-statement < statement ;

TUPLE: sqlite-result-set < result-set has-more? ;

M: sqlite-db <simple-statement> ( str in out -- obj )
    <prepared-statement> ;

M: sqlite-db <prepared-statement> ( str in out -- obj )
    sqlite-statement new-statement ;

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

: reset-bindings ( statement -- )
    sqlite-maybe-prepare
    handle>> [ sqlite3_reset drop ] [ sqlite3_clear_bindings drop ] bi ;

M: sqlite-statement low-level-bind ( statement -- )
    [ bind-params>> ] [ handle>> ] bi
    [ swap [ key>> ] [ value>> ] [ type>> ] tri sqlite-bind-type ] curry each ;

M: sqlite-statement bind-statement* ( statement -- )
    sqlite-maybe-prepare
    dup bound?>> [ dup reset-bindings ] when
    low-level-bind ;

GENERIC: sqlite-bind-conversion ( tuple obj -- array )

TUPLE: sqlite-low-level-binding < low-level-binding key type ;
: <sqlite-low-level-binding> ( key value type -- obj )
    sqlite-low-level-binding new
        swap >>type
        swap >>value
        swap >>key ;

M: sql-spec sqlite-bind-conversion ( tuple spec -- array )
    [ column-name>> ":" prepend ]
    [ slot-name>> rot get-slot-named ]
    [ type>> ] tri <sqlite-low-level-binding> ;

M: literal-bind sqlite-bind-conversion ( tuple literal-bind -- array )
    nip [ key>> ] [ value>> ] [ type>> ] tri
    <sqlite-low-level-binding> ;

M: generator-bind sqlite-bind-conversion ( tuple generate-bind -- array )
    tuck
    [ generator-singleton>> eval-generator tuck ] [ slot-name>> ] bi
    rot set-slot-named
    >r [ key>> ] [ type>> ] bi r> swap <sqlite-low-level-binding> ;

M: sqlite-statement bind-tuple ( tuple statement -- )
    [
        in-params>> [ sqlite-bind-conversion ] with map
    ] keep bind-statement ;

: last-insert-id ( -- id )
    db get handle>> sqlite3_last_insert_rowid
    dup zero? [ "last-id failed" throw ] when ;

M: sqlite-db insert-tuple-set-key ( tuple statement -- )
    execute-statement last-insert-id swap set-primary-key ;

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
    dup handle>> sqlite-result-set new-result-set
    dup advance-row ;

M: sqlite-db create-sql-statement ( class -- statement )
    [
        dupd
        "create table " 0% 0%
        "(" 0% [ ", " 0% ] [
            dup column-name>> 0%
            " " 0%
            dup type>> lookup-create-type 0%
            modifiers 0%
        ] interleave

        ", " 0%
        find-primary-key
        "primary key(" 0%
        [ "," 0% ] [ column-name>> 0% ] interleave
        "));" 0%
    ] query-make ;

M: sqlite-db drop-sql-statement ( class -- statement )
    [ "drop table " 0% 0% ";" 0% drop ] query-make ;

M: sqlite-db <insert-db-assigned-statement> ( tuple -- statement )
    [
        "insert into " 0% 0%
        "(" 0%
        remove-db-assigned-id
        dup [ ", " 0% ] [ column-name>> 0% ] interleave
        ") values(" 0%
        [ ", " 0% ] [
            dup type>> +random-id+ = [
                [ slot-name>> ]
                [
                    column-name>> ":" prepend dup 0%
                    random-id-generator
                ] [ type>> ] tri <generator-bind> 1,
            ] [
                bind%
            ] if
        ] interleave
        ");" 0%
    ] query-make ;

M: sqlite-db <insert-user-assigned-statement> ( tuple -- statement )
    <insert-db-assigned-statement> ;

M: sqlite-db bind# ( spec obj -- )
    >r
    [ column-name>> ":" swap next-sql-counter 3append dup 0% ]
    [ type>> ] bi
    r> <literal-bind> 1, ;

M: sqlite-db bind% ( spec -- )
    dup 1, column-name>> ":" prepend 0% ;

M: sqlite-db persistent-table ( -- assoc )
    H{
        { +db-assigned-id+ { "integer" "integer" f } }
        { +user-assigned-id+ { f f f } }
        { +random-id+ { "integer" "integer" f } }
        { +foreign-id+ { "integer" "integer" "references" } }

        { +on-delete+ { f f "on delete" } }
        { +restrict+ { f f "restrict" } }
        { +cascade+ { f f "cascade" } }
        { +set-null+ { f f "set null" } }
        { +set-default+ { f f "set default" } }

        { INTEGER { "integer" "integer" f } }
        { BIG-INTEGER { "bigint" "bigint" f } }
        { SIGNED-BIG-INTEGER { "bigint" "bigint" f } }
        { UNSIGNED-BIG-INTEGER { "bigint" "bigint" f } }
        { TEXT { "text" "text" f } }
        { VARCHAR { "text" "text" f } }
        { DATE { "date" "date" f } }
        { TIME { "time" "time" f } }
        { DATETIME { "datetime" "datetime" f } }
        { TIMESTAMP { "timestamp" "timestamp" f } }
        { DOUBLE { "real" "real" f } }
        { BLOB { "blob" "blob" f } }
        { FACTOR-BLOB { "blob" "blob" f } }
        { URL { "text" "text" f } }
        { +autoincrement+ { f f "autoincrement" } }
        { +unique+ { f f "unique" } }
        { +default+ { f f "default" } }
        { +null+ { f f "null" } }
        { +not-null+ { f f "not null" } }
        { system-random-generator { f f f } }
        { secure-random-generator { f f f } }
        { random-generator { f f f } }
    } ;

M: sqlite-db compound ( string seq -- new-string )
    over {
        { "default" [ first number>string join-space ] }
        { "references" [ >reference-string ] }
        [ 2drop ]
    } case ;
