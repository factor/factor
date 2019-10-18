! Copyright (C) 2007, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes.tuple combinators db
db.postgresql.errors db.postgresql.ffi db.postgresql.lib
db.private db.queries db.tuples db.tuples.private db.types
destructors kernel make math math.parser namespaces nmake random
sequences splitting ;
IN: db.postgresql

TUPLE: postgresql-db host port pgopts pgtty database username password ;

: <postgresql-db> ( -- postgresql-db )
    postgresql-db new ;

<PRIVATE

TUPLE: postgresql-db-connection < db-connection ;
: <postgresql-db-connection> ( handle -- db-connection )
    postgresql-db-connection new-db-connection
        swap >>handle ;

PRIVATE>

TUPLE: postgresql-statement < statement ;

TUPLE: postgresql-result-set < result-set ;

M: postgresql-db db-open ( db -- db-connection )
    {
        [ host>> ]
        [ port>> ]
        [ pgopts>> ]
        [ pgtty>> ]
        [ database>> ]
        [ username>> ]
        [ password>> ]
    } cleave connect-postgres <postgresql-db-connection> ;

M: postgresql-db-connection db-close ( handle -- ) PQfinish ;

M: postgresql-statement bind-statement* ( statement -- ) drop ;

GENERIC: postgresql-bind-conversion ( tuple object -- low-level-binding )

M: sql-spec postgresql-bind-conversion ( tuple spec -- object )
    slot-name>> swap get-slot-named <low-level-binding> ;

M: literal-bind postgresql-bind-conversion ( tuple literal-bind -- object )
    nip value>> <low-level-binding> ;

M: generator-bind postgresql-bind-conversion ( tuple generate-bind -- object )
    dup generator-singleton>> eval-generator
    [ swap slot-name>> rot set-slot-named ] [ <low-level-binding> ] bi ;

M: postgresql-statement bind-tuple ( tuple statement -- )
    [ nip ] [
        in-params>>
        [ postgresql-bind-conversion ] with map
    ] 2bi
    >>bind-params drop ;

M: postgresql-result-set #rows ( result-set -- n )
    handle>> PQntuples ;

M: postgresql-result-set #columns ( result-set -- n )
    handle>> PQnfields ;

: result-handle-n ( result-set -- handle n )
    [ handle>> ] [ n>> ] bi ;

M: postgresql-result-set row-column ( result-set column -- object )
    [ result-handle-n ] dip pq-get-string ;

M: postgresql-result-set row-column-typed ( result-set column -- object )
    dup pick out-params>> nth type>>
    [ result-handle-n ] 2dip postgresql-column-typed ;

M: postgresql-statement query-results ( query -- result-set )
    dup bind-params>> [
        over [ bind-statement ] keep
        do-postgresql-bound-statement
    ] [
        dup do-postgresql-statement
    ] if*
    postgresql-result-set new-result-set
    dup init-result-set ;

M: postgresql-result-set advance-row ( result-set -- )
    [ 1 + ] change-n drop ;

M: postgresql-result-set more-rows? ( result-set -- ? )
    [ n>> ] [ max>> ] bi < ;

M: postgresql-statement dispose ( query -- )
    dup handle>> PQclear
    f >>handle drop ;

M: postgresql-result-set dispose ( result-set -- )
    [ handle>> PQclear ]
    [
        0 >>n
        0 >>max
        f >>handle drop
    ] bi ;

M: postgresql-statement prepare-statement ( statement -- )
    dup
    [ db-connection get handle>> f ] dip
    [ sql>> ] [ in-params>> ] bi
    length f PQprepare postgresql-error
    >>handle drop ;

M: postgresql-db-connection <simple-statement> ( sql in out -- statement )
    postgresql-statement new-statement ;

M: postgresql-db-connection <prepared-statement> ( sql in out -- statement )
    <simple-statement> dup prepare-statement ;

: bind-name% ( -- )
    CHAR: $ 0,
    sql-counter [ inc ] [ get 0# ] bi ;

M: postgresql-db-connection bind% ( spec -- )
    bind-name% 1, ;

M: postgresql-db-connection bind# ( spec object -- )
    [ bind-name% f swap type>> ] dip
    <literal-bind> 1, ;

: create-table-sql ( class -- statement )
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

: create-function-sql ( class -- statement )
    [
        [ dup remove-id ] dip
        "create function add_" 0% dup 0%
        "(" 0%
        over [ "," 0% ]
        [
            type>> lookup-type 0%
        ] interleave
        ")" 0%
        " returns bigint as '" 0%

        "insert into " 0%
        dup 0%
        "(" 0%
        over [ ", " 0% ] [ column-name>> 0% ] interleave
        ") values(" 0%
        swap [ ", " 0% ] [ drop bind-name% ] interleave
        "); " 0%
        "select currval(''" 0% 0% "_" 0%
        find-primary-key first column-name>> 0%
        "_seq'');' language sql;" 0%
    ] query-make ;

M: postgresql-db-connection create-sql-statement ( class -- seq )
    [
        [ create-table-sql , ] keep
        dup db-assigned? [ create-function-sql , ] [ drop ] if
    ] { } make ;

: drop-function-sql ( class -- statement )
    [
        "drop function add_" 0% 0%
        "(" 0%
        remove-id
        [ ", " 0% ] [ type>> lookup-type 0% ] interleave
        ");" 0%
    ] query-make ;

: drop-table-sql ( table -- statement )
    [
        "drop table " 0% 0% drop
    ] query-make ;

M: postgresql-db-connection drop-sql-statement ( class -- seq )
    [
        [ drop-table-sql , ] keep
        dup db-assigned? [ drop-function-sql , ] [ drop ] if
    ] { } make ;

M: postgresql-db-connection <insert-db-assigned-statement> ( class -- statement )
    [
        "select add_" 0% 0%
        "(" 0%
        dup find-primary-key first 2,
        remove-id
        [ ", " 0% ] [ bind% ] interleave
        ");" 0%
    ] query-make ;

M: postgresql-db-connection <insert-user-assigned-statement> ( class -- statement )
    [
        "insert into " 0% 0%
        "(" 0%
        dup [ ", " 0% ] [ column-name>> 0% ] interleave
        ")" 0%

        " values(" 0%
        [ ", " 0% ] [
            dup type>> +random-id+ = [
                [
                    bind-name%
                    slot-name>>
                    f
                    random-id-generator
                ] [ type>> ] bi <generator-bind> 1,
            ] [
                bind%
            ] if
        ] interleave
        ");" 0%
    ] query-make ;

M: postgresql-db-connection insert-tuple-set-key ( tuple statement -- )
    query-modify-tuple ;

M: postgresql-db-connection persistent-table ( -- hashtable )
    H{
        { +db-assigned-id+ { "integer" "serial" f } }
        { +user-assigned-id+ { f f f } }
        { +random-id+ { "bigint" "bigint" f } }

        { +foreign-id+ { f f "references" } }

        { +on-update+ { f f "on update" } }
        { +on-delete+ { f f "on delete" } }
        { +restrict+ { f f "restrict" } }
        { +cascade+ { f f "cascade" } }
        { +set-null+ { f f "set null" } }
        { +set-default+ { f f "set default" } }

        { TEXT { "text" "text" f } }
        { VARCHAR { "varchar" "varchar" f } }
        { INTEGER { "integer" "integer" f } }
        { BIG-INTEGER { "bigint" "bigint" f } }
        { UNSIGNED-BIG-INTEGER { "bigint" "bigint" f } }
        { SIGNED-BIG-INTEGER { "bigint" "bigint" f } }
        { DOUBLE { "real" "real" f } }
        { DATE { "date" "date" f } }
        { TIME { "time" "time" f } }
        { DATETIME { "timestamp" "timestamp" f } }
        { TIMESTAMP { "timestamp" "timestamp" f } }
        { BLOB { "bytea" "bytea" f } }
        { FACTOR-BLOB { "bytea" "bytea" f } }
        { URL { "varchar" "varchar" f } }
        { +autoincrement+ { f f "autoincrement" } }
        { +unique+ { f f "unique" } }
        { +default+ { f f "default" } }
        { +null+ { f f "null" } }
        { +not-null+ { f f "not null" } }
        { system-random-generator { f f f } }
        { secure-random-generator { f f f } }
        { random-generator { f f f } }
    } ;

ERROR: no-compound-found string object ;
M: postgresql-db-connection compound ( string object -- string' )
    over {
        { "default" [ first number>string " " glue ] }
        { "varchar" [ first number>string "(" ")" surround append ] }
        { "references" [ >reference-string ] }
        [ drop no-compound-found ]
    } case ;

M: postgresql-db-connection parse-db-error
    "\n" split dup length {
        { 1 [ first parse-postgresql-sql-error ] }
        { 2 [ concat parse-postgresql-sql-error ] }
        { 3 [
                first3
                [ parse-postgresql-sql-error ] 2dip
                postgresql-location >>location
        ] }
    } case ;
