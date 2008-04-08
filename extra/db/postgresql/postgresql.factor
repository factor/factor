! Copyright (C) 2007, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs alien alien.syntax continuations io
kernel math math.parser namespaces prettyprint quotations
sequences debugger db db.postgresql.lib db.postgresql.ffi
db.tuples db.types tools.annotations math.ranges
combinators sequences.lib classes locals words tools.walker
namespaces.lib accessors ;
IN: db.postgresql

TUPLE: postgresql-db < db
    host port pgopts pgtty db user pass ;

TUPLE: postgresql-statement < throwable-statement ;

TUPLE: postgresql-result-set < result-set ;

: <postgresql-statement> ( statement in out -- postgresql-statement )
    postgresql-statement construct-statement ;

M: postgresql-db make-db* ( seq tuple -- db )
    >r first4 r>
        swap >>db
        swap >>pass
        swap >>user
        swap >>host ;

M: postgresql-db db-open ( db -- db )
    dup {
        [ host>> ]
        [ port>> ]
        [ pgopts>> ]
        [ pgtty>> ]
        [ db>> ]
        [ user>> ]
        [ pass>> ]
    } cleave connect-postgres >>handle ;

M: postgresql-db dispose ( db -- )
    handle>> PQfinish ;

M: postgresql-statement bind-statement* ( statement -- )
    drop ;

M: postgresql-statement bind-tuple ( tuple statement -- )
    [
        statement-in-params
        [ sql-spec-slot-name swap get-slot-named ] with map
    ] keep set-statement-bind-params ;

M: postgresql-result-set #rows ( result-set -- n )
    handle>> PQntuples ;

M: postgresql-result-set #columns ( result-set -- n )
    handle>> PQnfields ;

M: postgresql-result-set row-column ( result-set column -- obj )
    >r dup result-set-handle swap result-set-n r> pq-get-string ;

M: postgresql-result-set row-column-typed ( result-set column -- obj )
    dup pick result-set-out-params nth sql-spec-type
    >r >r [ result-set-handle ] [ result-set-n ] bi r> r> postgresql-column-typed ;

M: postgresql-statement query-results ( query -- result-set )
    dup statement-bind-params [
        over [ bind-statement ] keep
        do-postgresql-bound-statement
    ] [
        dup do-postgresql-statement
    ] if*
    postgresql-result-set construct-result-set
    dup init-result-set ;

M: postgresql-result-set advance-row ( result-set -- )
    dup result-set-n 1+ swap set-result-set-n ;

M: postgresql-result-set more-rows? ( result-set -- ? )
    dup result-set-n swap result-set-max < ;

M: postgresql-statement dispose ( query -- )
    dup statement-handle PQclear
    f swap set-statement-handle ;

M: postgresql-result-set dispose ( result-set -- )
    dup result-set-handle PQclear
    0 0 f roll {
        set-result-set-n set-result-set-max set-result-set-handle
    } set-slots ;

M: postgresql-statement prepare-statement ( statement -- )
    [
        >r db get handle>> "" r>
        dup statement-sql swap statement-in-params
        length f PQprepare postgresql-error
    ] keep set-statement-handle ;

M: postgresql-db <simple-statement> ( sql in out -- statement )
    <postgresql-statement> ;

M: postgresql-db <prepared-statement> ( sql in out -- statement )
    <postgresql-statement> dup prepare-statement ;

M: postgresql-db begin-transaction ( -- )
    "BEGIN" sql-command ;

M: postgresql-db commit-transaction ( -- )
    "COMMIT" sql-command ;

M: postgresql-db rollback-transaction ( -- )
    "ROLLBACK" sql-command ;

SYMBOL: postgresql-counter
: bind-name% ( -- )
    CHAR: $ 0,
    postgresql-counter [ inc ] keep get 0# ;

M: postgresql-db bind% ( spec -- )
    1, bind-name% ;

: postgresql-make ( class quot -- )
    >r sql-props r>
    [ postgresql-counter off call ] { "" { } { } } nmake
    <postgresql-statement> ; inline

: create-table-sql ( class -- statement )
    [
        "create table " 0% 0%
        "(" 0%
        [ ", " 0% ] [
            dup sql-spec-column-name 0%
            " " 0%
            dup sql-spec-type t lookup-type 0%
            modifiers 0%
        ] interleave ");" 0%
    ] postgresql-make ;

: create-function-sql ( class -- statement )
    [
        >r remove-id r>
        "create function add_" 0% dup 0%
        "(" 0%
        over [ "," 0% ]
        [
            sql-spec-type f lookup-type 0%
        ] interleave
        ")" 0%
        " returns bigint as '" 0%

        "insert into " 0%
        dup 0%
        "(" 0%
        over [ ", " 0% ] [ sql-spec-column-name 0% ] interleave
        ") values(" 0%
        swap [ ", " 0% ] [ drop bind-name% ] interleave
        "); " 0%
        "select currval(''" 0% 0% "_id_seq'');' language sql;" 0%
    ] postgresql-make ;

M: postgresql-db create-sql-statement ( class -- seq )
    [
        [ create-table-sql , ] keep
        dup db-columns find-primary-key native-id?
        [ create-function-sql , ] [ drop ] if
    ] { } make ;

: drop-function-sql ( class -- statement )
    [
        "drop function add_" 0% 0%
        "(" 0%
        remove-id
        [ ", " 0% ] [ sql-spec-type f lookup-type 0% ] interleave
        ");" 0%
    ] postgresql-make ;

: drop-table-sql ( table -- statement )
    [
        "drop table " 0% 0% ";" 0% drop
    ] postgresql-make ;

M: postgresql-db drop-sql-statement ( class -- seq )
    [
        [ drop-table-sql , ] keep
        dup db-columns find-primary-key native-id?
        [ drop-function-sql , ] [ drop ] if
    ] { } make ;

M: postgresql-db <insert-native-statement> ( class -- statement )
    [
        "select add_" 0% 0%
        "(" 0%
        dup find-primary-key 2,
        remove-id
        [ ", " 0% ] [ bind% ] interleave
        ");" 0%
    ] postgresql-make ;

M: postgresql-db <insert-nonnative-statement> ( class -- statement )
    [
        "insert into " 0% 0%
        "(" 0%
        dup [ ", " 0% ] [ sql-spec-column-name 0% ] interleave
        ")" 0%

        " values(" 0%
        [ ", " 0% ] [ bind% ] interleave
        ");" 0%
    ] postgresql-make ;

M: postgresql-db insert-tuple* ( tuple statement -- )
    query-modify-tuple ;

M: postgresql-db <update-tuple-statement> ( class -- statement )
    [
        "update " 0% 0%
        " set " 0%
        dup remove-id
        [ ", " 0% ]
        [ dup sql-spec-column-name 0% " = " 0% bind% ] interleave
        " where " 0%
        find-primary-key
        dup sql-spec-column-name 0% " = " 0% bind%
    ] postgresql-make ;

M: postgresql-db <delete-tuple-statement> ( class -- statement )
    [
        "delete from " 0% 0%
        " where " 0%
        find-primary-key
        dup sql-spec-column-name 0% " = " 0% bind%
    ] postgresql-make ;

M: postgresql-db <select-by-slots-statement> ( tuple class -- statement )
    [
    ! tuple columns table
        "select " 0%
        over [ ", " 0% ]
        [ dup sql-spec-column-name 0% 2, ] interleave

        " from " 0% 0%
        [ sql-spec-slot-name swap get-slot-named ] with subset
        dup empty? [
            drop
        ] [
            " where " 0%
            [ " and " 0% ]
            [ dup sql-spec-column-name 0% " = " 0% bind% ] interleave
        ] if ";" 0%
    ] postgresql-make ;

M: postgresql-db type-table ( -- hash )
    H{
        { +native-id+ "integer" }
        { TEXT "text" }
        { VARCHAR "varchar" }
        { INTEGER "integer" }
        { DOUBLE "real" }
        { DATE "date" }
        { TIME "time" }
        { DATETIME "timestamp" }
        { TIMESTAMP "timestamp" }
        { BLOB "bytea" }
        { FACTOR-BLOB "bytea" }
    } ;

M: postgresql-db create-type-table ( -- hash )
    H{
        { +native-id+ "serial primary key" }
    } ;

: postgresql-compound ( str n -- newstr )
    over {
        { "default" [ first number>string join-space ] }
        { "varchar" [ first number>string paren append ] }
        { "references" [
                first2 >r [ unparse join-space ] keep db-columns r>
                swap [ sql-spec-slot-name = ] with find nip
                sql-spec-column-name paren append
            ] }
        [ "no compound found" 3array throw ]
    } case ;

M: postgresql-db compound-modifier ( str seq -- newstr )
    postgresql-compound ;
    
M: postgresql-db modifier-table ( -- hashtable )
    H{
        { +native-id+ "primary key" }
        { +assigned-id+ "primary key" }
        { +foreign-id+ "references" }
        { +autoincrement+ "autoincrement" }
        { +unique+ "unique" }
        { +default+ "default" }
        { +null+ "null" }
        { +not-null+ "not null" }
    } ;

M: postgresql-db compound-type ( str n -- newstr )
    postgresql-compound ;
