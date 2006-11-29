! See http://factor.sf.net/license.txt for BSD license.

! adapted from libpq-fe.h version 7.4.7
! tested on debian linux with postgresql 7.4.7

IN: postgresql
USING: kernel alien errors io prettyprint sequences namespaces arrays math ;

SYMBOL: db
SYMBOL: query-res

: connect-postgres ( host port pgopts pgtty db user pass -- conn )
    PQsetdbLogin
    dup PQstatus zero? [ "couldn't connect to database" throw ] unless ;

: with-postgres ( host port pgopts pgtty db user pass quot -- )
    [ >r connect-postgres db set r>
    [ db get PQfinish ] cleanup ] with-scope ; inline

: with-postgres-catch ( host port pgopts pgtty db user pass quot -- )
    [ with-postgres ] catch [ "caught: " write print ] when* ;

: postgres-error ( ret -- ret )
    dup zero? [ PQresultErrorMessage throw ] when ;

: (do-query) ( PGconn query -- PGresult* )
    ! For queries that do not return rows, PQexec() returns PGRES_COMMAND_OK
    ! For queries that return rows, PQexec() returns PGRES_TUPLES_OK
    PQexec
    dup PQresultStatus PGRES_COMMAND_OK =
    over PQresultStatus PGRES_TUPLES_OK =
    or [
        [ PQresultErrorMessage CHAR: \n swap remove ] keep PQclear throw
    ] unless ;

: (do-command) ( PGconn query -- PGresult* )
    [ (do-query) ] catch
    [
        swap
        "non-fatal error: " print
        "\tQuery: " write "'" write write "'" print
        "\t" write print
    ] when* drop ;

: do-command ( str -- )
    unit \ (do-command) add db get swap call ;

: prepare ( str quot word -- conn quot )
    rot unit swap append swap append db get swap ;

: do-query ( str quot -- )
    [ (do-query) query-res set ] prepare catch
    [ rethrow ] [ query-res get PQclear ] if* ;

: result>seq ( -- seq )
    query-res get [ PQnfields ] keep PQntuples
    [ swap [ query-res get -rot PQgetvalue ] map-with ] map-with ;

: print-table ( seq -- )
    [ [ write bl ] each "\n" write ] each ;

