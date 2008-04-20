! Copyright (C) 2005, 2008 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assocs classes compiler db
hashtables io.files kernel math math.parser namespaces
prettyprint sequences strings classes.tuple alien.c-types
continuations db.sqlite.lib db.sqlite.ffi db.tuples
words combinators.lib db.types combinators math.intervals
io namespaces.lib accessors vectors math.ranges random
math.bitfields.lib ;
USE: tools.walker
IN: db.sqlite

TUPLE: sqlite-db < db path ;

M: sqlite-db make-db* ( path db -- db )
    swap >>path ;

M: sqlite-db db-open ( db -- db )
    [ path>> sqlite-open ] [ swap >>handle ] bi ;

M: sqlite-db db-close ( handle -- ) sqlite-close ;
M: sqlite-db dispose ( db -- ) dispose-db ;

TUPLE: sqlite-statement < statement ;

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

GENERIC: sqlite-bind-conversion ( tuple obj -- array )

M: sql-spec sqlite-bind-conversion ( tuple spec -- array )
    [ column-name>> ":" prepend ]
    [ slot-name>> rot get-slot-named ]
    [ type>> ] tri 3array ;

M: literal-bind sqlite-bind-conversion ( tuple literal-bind -- array )
    nip [ key>> ] [ value>> ] [ type>> ] tri 3array ;

M: generator-bind sqlite-bind-conversion ( tuple generate-bind -- array )
    nip [ key>> ] [ quot>> call ] [ type>> ] tri 3array ;

M: sqlite-statement bind-tuple ( tuple statement -- )
    [
        in-params>> [ sqlite-bind-conversion ] with map
    ] keep bind-statement ;

: last-insert-id ( -- id )
    db get db-handle sqlite3_last_insert_rowid
    dup zero? [ "last-id failed" throw ] when ;

M: sqlite-db insert-tuple* ( tuple statement -- )
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
    dup handle>> sqlite-result-set construct-result-set
    dup advance-row ;

M: sqlite-db begin-transaction ( -- ) "BEGIN" sql-command ;
M: sqlite-db commit-transaction ( -- ) "COMMIT" sql-command ;
M: sqlite-db rollback-transaction ( -- ) "ROLLBACK" sql-command ;

: sqlite-make ( class quot -- )
    >r sql-props r>
    [ 0 sql-counter rot with-variable ] { "" { } { } } nmake
    <simple-statement> ;

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
        [ ", " 0% ] [
            dup type>> +random-id+ = [
break
                dup modifiers>> find-random-generator
                [
                    [
                        column-name>> ":" prepend
                        dup 0% random-id-quot
                    ] with-random
                ] curry
                [ type>> ] bi 10 <generator-bind> 1,
            ] [
                bind%
            ] if
        ] interleave
        ");" 0%
    ] sqlite-make ;

M: sqlite-db <insert-nonnative-statement> ( tuple -- statement )
    <insert-native-statement> ;

M: sqlite-db bind# ( spec obj -- )
    >r
    [ column-name>> ":" swap next-sql-counter 3append dup 0% ]
    [ type>> ] bi
    r> <literal-bind> 1, ;

M: sqlite-db bind% ( spec -- )
    dup 1, column-name>> ":" prepend 0% ;

: where-primary-key% ( specs -- )
    " where " 0%
    find-primary-key dup column-name>> 0% " = " 0% bind% ;

GENERIC: where ( specs obj -- )

: interval-comparison ( ? str -- str )
    "from" = " >" " <" ? swap [ "= " append ] when ;

: where-interval ( spec obj from/to -- )
    pick column-name>> 0%
    >r first2 r> interval-comparison 0%
    bind# ;

: in-parens ( quot -- )
    "(" 0% call ")" 0% ; inline

M: interval where ( spec obj -- )
    [
        [ from>> "from" where-interval " and " 0% ]
        [ to>> "to" where-interval ] 2bi
    ] in-parens ;

M: sequence where ( spec obj -- )
    [
        [ " or " 0% ] [ dupd where ] interleave drop
    ] in-parens ;

: object-where ( spec obj -- )
    over column-name>> 0% " = " 0% bind# ;

M: object where ( spec obj -- ) object-where ;

M: integer where ( spec obj -- ) object-where ;

M: string where ( spec obj -- ) object-where ;

: where-clause ( tuple specs -- )
    " where " 0% [
        " and " 0%
    ] [
        2dup slot-name>> swap get-slot-named where
    ] interleave drop ;

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

M: sqlite-db <select-by-slots-statement> ( tuple class -- statement )
    [
        "select " 0%
        over [ ", " 0% ]
        [ dup column-name>> 0% 2, ] interleave

        " from " 0% 0%
        dupd
        [ slot-name>> swap get-slot-named ] with subset
        dup empty? [ 2drop ] [ where-clause ] if ";" 0%
    ] sqlite-make ;

M: sqlite-db random-id-quot ( -- quot )
    [ 64 [ 2^ random ] keep 1 - set-bit ] ;

M: sqlite-db modifier-table ( -- hashtable )
    H{
        { +native-id+ "primary key" }
        { +assigned-id+ "primary key" }
        { +random-id+ "primary key" }
        { +autoincrement+ "autoincrement" }
        { +unique+ "unique" }
        { +default+ "default" }
        { +null+ "null" }
        { +not-null+ "not null" }
        { system-random-generator "" }
        { secure-random-generator "" }
        { random-generator "" }
    } ;

M: sqlite-db compound-modifier ( str obj -- str' ) compound-type ;

M: sqlite-db compound-type ( str seq -- str' )
    over {
        { "default" [ first number>string join-space ] }
        [ 2drop ] 
    } case ;

M: sqlite-db type-table ( -- assoc )
    H{
        { +native-id+ "integer primary key" }
        { +random-id+ "integer primary key" }
        { INTEGER "integer" }
        { BIG-INTEGER "bigint" }
        { SIGNED-BIG-INTEGER "bigint" }
        { UNSIGNED-BIG-INTEGER "bigint" }
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
