! Copyright (C) 2007, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs alien alien.syntax continuations io
kernel math math.parser namespaces prettyprint quotations
sequences debugger db db.postgresql.lib db.postgresql.ffi
db.tuples db.types tools.annotations math.ranges
combinators sequences.lib classes locals words tools.walker ;
IN: db.postgresql

TUPLE: postgresql-db host port pgopts pgtty db user pass ;
TUPLE: postgresql-statement ;
TUPLE: postgresql-result-set ;
: <postgresql-statement> ( statement -- postgresql-statement )
    postgresql-statement construct-delegate ;

: <postgresql-db> ( host user pass db -- obj )
    {
        set-postgresql-db-host
        set-postgresql-db-user
        set-postgresql-db-pass
        set-postgresql-db-db
    } postgresql-db construct ;

M: postgresql-db db-open ( db -- )
    dup {
        postgresql-db-host
        postgresql-db-port
        postgresql-db-pgopts
        postgresql-db-pgtty
        postgresql-db-db
        postgresql-db-user
        postgresql-db-pass
    } get-slots connect-postgres <db> swap set-delegate ;

M: postgresql-db dispose ( db -- )
    db-handle PQfinish ;

: with-postgresql ( host ust pass db quot -- )
    >r <postgresql-db> r> with-disposal ;

M: postgresql-statement bind-statement* ( seq statement -- )
    set-statement-in-params ;

M: postgresql-statement reset-statement ( statement -- )
    drop ;

M: postgresql-result-set #rows ( result-set -- n )
    result-set-handle PQntuples ;

M: postgresql-result-set #columns ( result-set -- n )
    result-set-handle PQnfields ;

M: postgresql-result-set row-column ( result-set n -- obj )
    >r dup result-set-handle swap result-set-n r> PQgetvalue ;

M: postgresql-result-set row-column-typed ( result-set n type -- obj )
    >r row-column r> sql-type>factor-type ;

M: postgresql-result-set sql-type>factor-type ( obj type -- newobj )
    {
        { INTEGER [ string>number ] }
        { BIG_INTEGER [ string>number ] }
        { DOUBLE [ string>number ] }
        [ drop ]
    } case ;

M: postgresql-statement insert-statement ( statement -- id )
break
    query-results [ 0 row-column ] with-disposal string>number ;

M: postgresql-statement query-results ( query -- result-set )
    dup statement-in-params [
        over [ bind-statement ] keep
        do-postgresql-bound-statement
    ] [
        dup do-postgresql-statement
    ] if*
    postgresql-result-set <result-set>
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
        >r db get db-handle "" r>
        dup statement-sql swap statement-in-params
        length f PQprepare postgresql-error
    ] keep set-statement-handle ;

M: postgresql-db <simple-statement> ( sql -- statement )
    { set-statement-sql } statement construct
    <postgresql-statement> ;

M: postgresql-db <prepared-statement> ( triple -- statement )
    ?first3
    {
        set-statement-sql
        set-statement-in-params
        set-statement-out-params
    } statement construct <postgresql-statement> ;

M: postgresql-db begin-transaction ( -- )
    "BEGIN" sql-command ;

M: postgresql-db commit-transaction ( -- )
    "COMMIT" sql-command ;

M: postgresql-db rollback-transaction ( -- )
    "ROLLBACK" sql-command ;

SYMBOL: postgresql-counter
: bind% ( spec -- )
    1,
    CHAR: $ 0,
    postgresql-counter [ inc ] keep get 0# ;

: postgresql-make ( quot -- )
    [ postgresql-counter off ] swap compose
    { "" { } { } } nmake ;

:: create-table-sql | specs table |
    [
        "create table " % table %
        "(" %
        specs [ ", " % ] [
            dup sql-spec-column-name %
            " " %
            dup sql-spec-type t lookup-type %
            modifiers%
        ] interleave ");" %
    ] "" make ;

:: create-function-sql | specs table |
    [
        [let | specs [ specs remove-id ] |
            "create function add_" 0% table 0%
            "(" 0%
            specs [ "," 0% ]
            [
                sql-spec-type f lookup-type 0%
            ] interleave
            ")" 0%
            " returns bigint as '" 0%

            "insert into " 0%
            table 0%
            "(" 0%
            specs [ ", " 0% ] [ sql-spec-column-name 0% ] interleave
            ") values(" 0%
            specs [ ", " 0% ] [ bind% ] interleave
            "); " 0%

            "select currval(''" 0% table 0% "_id_seq'');' language sql;" 0%
        ]
    ] postgresql-make 2drop ;

: drop-function-sql ( specs table -- sql )
    [
break
        "drop function add_" % %
        "(" %
        remove-id
        [ ", " % ] [ sql-spec-type f lookup-type % ] interleave
        ");" %
    ] "" make ;

: drop-table-sql ( table -- sql )
    [
        "drop table " % % ";" %
    ] "" make ;

M: postgresql-db create-sql ( specs table -- seq )
    [
        2dup create-table-sql ,
        over find-primary-key native-id?
        [ create-function-sql , ] [ 2drop ] if
    ] { } make ;

M: postgresql-db drop-sql ( specs table -- seq )
    [
        dup drop-table-sql ,
        over find-primary-key native-id?
        [ drop-function-sql , ] [ 2drop ] if
    ] { } make ;

: insert-table-sql ( specs table -- sql in-specs out-specs )
    [
        "insert into " 0% 0%
        "(" 0%
        dup [ ", " 0% ] [ sql-spec-column-name 0% ] interleave
        ")" 0%

        " values(" 0%
        [ ", " 0% ] [ bind% ] interleave
        ");" 0%
    ] postgresql-make ;

: insert-function-sql ( specs table -- sql in-specs out-specs )
    [
        "select add_" 0% 0%
        "(" 0%
        dup find-primary-key 2,
        remove-id
        [ ", " 0% ] [ bind% ] interleave
        ");" 0%
    ] postgresql-make ;

M: postgresql-db insert-sql* ( specs table -- sql in-specs out-specs )
    dup class db-columns find-primary-key native-id?
    [ insert-function-sql ] [ insert-table-sql ] if 3array ;

M: postgresql-db update-sql* ( specs table -- sql in-specs out-specs )
    [
        "update " 0% 0%
        " set " 0%
        dup remove-id
        [ ", " 0% ]
        [ dup sql-spec-column-name 0% " = " 0% bind% ] interleave
        " where " 0%
        find-primary-key
        dup sql-spec-column-name 0% " = " 0% bind%
    ] postgresql-make 3array ;

M: postgresql-db delete-sql* ( specs table -- sql in-specs out-specs )
    [
        "delete from " 0% 0%
        " where " 0%
        find-primary-key
        dup sql-spec-column-name 0% " = " 0% bind%
    ] postgresql-make 3array ;

: select-by-slots-sql ( tuple -- sql in-specs out-specs )
    [
        "select from " 0% dup class db-table 0%
        " " 0%
        dup class db-columns [ ", " 0% ]
        [ dup sql-spec-column-name 0% 2, ] interleave

        dup class db-columns
        [ sql-spec-slot-name swap get-slot-named ] with subset
        " where " 0%
        [ ", " 0% ]
        [ dup sql-spec-column-name 0% " = " 0% bind% ] interleave
        ";" 0%
    ] postgresql-make 3array ;

! : select-with-relations ( tuple -- sql in-specs out-specs )

M: postgresql-db select-sql ( tuple -- sql in-specs out-specs )
    select-by-slots-sql ;

M: postgresql-db tuple>params ( specs tuple -- obj )
    [ >r dup sql-spec-type swap sql-spec-slot-name r> get-slot-named swap ]
    curry { } map>assoc ;

M: postgresql-db type-table ( -- hash )
    H{
        { +native-id+ "integer" }
        { TEXT "text" }
        { VARCHAR "varchar" }
        { INTEGER "integer" }
        { DOUBLE "real" }
        { TIMESTAMP "timestamp" }
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
