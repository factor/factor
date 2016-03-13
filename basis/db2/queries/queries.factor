! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii classes.tuple
combinators.short-circuit db2 db2.connections db2.statements
db2.types db2.utils fry kernel sequences strings ;
IN: db2.queries

TUPLE: sql-object ;
TUPLE: sql-column ;

HOOK: current-db-name db-connection ( -- string )
HOOK: sanitize-string db-connection ( string -- string )

HOOK: databases-statement db-connection ( -- statement )
HOOK: database-tables-statement db-connection ( database -- statement )
HOOK: database-table-columns-statement db-connection ( database table -- sequence )

HOOK: sql-object-class db-connection ( -- tuple-class )
HOOK: sql-column-class db-connection ( -- tuple-class )

ERROR: unsafe-sql-string string ;

M: object sanitize-string
    dup [ { [ Letter? ] [ digit? ] [ "_" member? ] } 1|| ] all?
    [ unsafe-sql-string ] unless ;

<PRIVATE
GENERIC: >sql-name* ( object -- string )
M: tuple-class >sql-name* name>> sql-name-replace ;
M: string >sql-name* sql-name-replace ;
PRIVATE>

: >sql-name ( object -- string ) >sql-name* sanitize-string ;

: information-schema-select-sql ( string -- string' )
    "SELECT * FROM information_schema." " " surround ;

: database-table-schema-select-sql ( string -- string )
    information-schema-select-sql
    "WHERE
            table_catalog=$1 AND
            table_name=$2 AND
            table_schema='public'" append ;

: database-schema-select-sql ( string -- string )
    information-schema-select-sql
    "WHERE
            table_catalog=$1 AND
            table_schema='public'" append ;

M: object database-tables-statement
    [ <statement> ] dip
        1array >>in
        "tables" database-schema-select-sql >>sql ;

M: object databases-statement
    <statement>
        "SELECT DISTINCT table_catalog
        FROM information_schema.tables
        WHERE
            table_schema='public'" >>sql ;

M: object database-table-columns-statement ( database table -- sequence )
    [ <statement> ] 2dip
        2array >>in
        "columns" database-table-schema-select-sql >>sql ;

: >sql-objects ( statement -- sequence' )
    sql-query
    sql-object-class '[ _ slots>tuple ] map ;

: >sql-columns ( statement -- sequence' )
    sql-query
    sql-column-class '[ _ slots>tuple ] map ;

: database-tables ( database -- sequence )
    database-tables-statement >sql-objects ;

: current-tables ( -- sequence )
    current-db-name database-tables ;

: table-names ( sequence -- strings )
    [ table-name>> ] map ;

: database-table-names ( database -- sequence )
    database-tables table-names ;

: current-table-names ( -- sequence )
    current-db-name database-table-names ;

: table-exists? ( table -- ? ) current-table-names member? ;

: database-table-columns ( database table -- sequence )
    database-table-columns-statement >sql-columns ;

: table-columns ( table -- sequence )
    [ current-db-name ] dip database-table-columns ;

: databases ( -- sequence )
    databases-statement sql-query concat ;

! [ "select nspname from pg_catalog.pg_namespace" sql-query ] with-dummy-postgresql
! [ "select schema_name from information_schema.schemata" sql-query ] with-dummy-postgresql
