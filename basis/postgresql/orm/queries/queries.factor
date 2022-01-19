! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators combinators.smart db2
db2.binders db2.statements db2.types db2.utils kernel make math
math.intervals math.parser multiline namespaces orm.persistent
orm.queries postgresql.db2.connections.private ranges sequences ;
IN: postgresql.orm.queries

! TODOOOOOO
SYMBOL: postgresql-counter

: next-bind ( -- string )
    postgresql-counter [ inc ] [ get ] bi
    number>string "$" prepend ;

M: postgresql-db-connection n>bind-sequence ( n -- sequence )
    [1..b] [ number>string "$" prepend ] map ;

M:: postgresql-db-connection continue-bind-sequence ( previous n -- sequence )
    previous 1 +
    dup n +
    [a..b] [ number>string "$" prepend ] map ;

ERROR: db-assigned-keys-not-empty assoc ;
: check-db-assigned-assoc ( assoc -- assoc )
    dup [ first column-primary-key? ] filter
    [ db-assigned-keys-not-empty ] unless-empty ;

M: postgresql-db-connection insert-db-assigned-key-sql
    [ <statement> ] dip
    [ >persistent ] [ ] bi {
        [ drop [ "select " "add_" ] dip table-name>> trim-double-quotes 3append quote-sql-name add-sql "(" add-sql ]
        [

            filter-tuple-values check-db-assigned-assoc
            [ length n>bind-string add-sql ");" add-sql ]
            [ [ [ second ] [ first type>> ] bi <in-binder-low> ] map >>in ] bi
            { INTEGER } >>out
        ]
    } 2cleave ;

M: postgresql-db-connection insert-tuple-set-key ( tuple statement -- )
    sql-query first first set-primary-key drop ;

M: postgresql-db-connection insert-user-assigned-key-sql
    [ <statement> ] dip
    [ >persistent ] [ ] bi {
        [ drop table-name>> quote-sql-name "INSERT INTO " "(" surround add-sql ]
        [
            filter-tuple-values
            [
                keys
                [ [ column-name>> quote-sql-name ] map ", " join ]
                [
                    length n>bind-string
                    ") values(" ");" surround
                ] bi append add-sql
            ]
            [ [ [ second ] [ first type>> ] bi <in-binder-low> ] map >>in ] bi
        ]
    } 2cleave ;

/*
M: postgresql-db-connection insert-user-assigned-key-sql
    [ <statement> ] dip >persistent {
        [ table-name>> quote-sql-name "INSERT INTO " prepend add-sql "(" add-sql ]
        [
            [
                columns>>
                [
                    [
                        [ ", " % ] [ column-name>> quote-sql-name % ] interleave 
                        ")" %
                    ] "" make add-sql
                ] [
                    " values(" %
                    [ ", " % ] [
                        dup type>> +random-key+ = [
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
                ] bi
            ]
    } cleave ;
*/


: postgresql-create-table ( tuple-class -- string )
    >persistent dup table-name>> quote-sql-name
    [
        [
            [ columns>> ] dip
            "CREATE TABLE " % %
            "(" % [ ", " % ] [
                [ column-name>> quote-sql-name % " " % ]
                [ type>> sql-create-type>string % ]
                [ drop ] tri
                ! [ modifiers % ] bi
            ] interleave
        ] [
            drop
            find-primary-key [
                ", " %
                "PRIMARY KEY(" %
                [ "," % ] [ column-name>> quote-sql-name % ] interleave
                ")" %
            ] unless-empty
            ");" %
        ] 2bi
    ] "" make ;

:: postgresql-create-function ( tuple-class -- string )
    tuple-class >persistent :> persistent
    persistent table-name>> :> table-name
    table-name trim-double-quotes :> table-name-unquoted
    persistent columns>> :> columns
    columns remove-primary-key :> columns-minus-key

    [
        "CREATE FUNCTION " "add_" table-name-unquoted append quote-sql-name "("

        columns-minus-key [ type>> sql-type>string ] map ", " join

        ") returns bigint as 'insert into "

        table-name quote-sql-name "(" columns-minus-key [ column-name>> quote-sql-name ] map ", " join
        ") values("
        1 columns-minus-key length [a,b]
        [ number>string "$" prepend ] map ", " join

        "); select currval(''" table-name-unquoted "_"
        persistent find-primary-key first column-name>>
        "_seq'');' language sql;"
    ] "" append-outputs-as ;

M: postgresql-db-connection create-table-sql ( tuple-class -- seq )
    [ postgresql-create-table ]
    [ dup db-assigned-key? [ postgresql-create-function 2array ] [ drop ] if ] bi ;

:: postgresql-drop-table ( tuple-class -- string )
    tuple-class >persistent table-name>> :> table-name
    [
        "drop table " table-name quote-sql-name ";"
    ] "" append-outputs-as ;

:: postgresql-drop-function ( tuple-class -- string )
    tuple-class >persistent :> persistent
    persistent table-name>> :> table-name
    table-name trim-double-quotes :> table-name-unquoted
    persistent columns>> :> columns
    columns remove-primary-key :> columns-minus-key
    [
        "drop function " "add_" table-name-unquoted append quote-sql-name
        "("
        columns-minus-key [ type>> sql-type>string ] map ", " join
        ");"
    ] "" append-outputs-as ;

M: postgresql-db-connection drop-table-sql ( tuple-class -- seq )
    [ postgresql-drop-table ]
    [ dup db-assigned-key? [ postgresql-drop-function 2array ] [ drop ] if ] bi ;
