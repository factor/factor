! See http://factor.sf.net/license.txt for BSD license.

! adapted from libpq-fe.h version 7.4.7
! tested on debian linux with postgresql 7.4.7

IN: postgresql
USING: kernel alien errors io prettyprint sequences lists namespaces arrays math ;
SYMBOL: postgres-conn
SYMBOL: query-res

: connect-postgres ( host port pgopts pgtty db user pass -- conn )
    PQsetdbLogin
    dup PQstatus 0 = [ "couldn't connect to database" throw ] unless ;

: with-postgres ( host port pgopts pgtty db user pass quot -- )
    [ >r connect-postgres postgres-conn set r>
    [ postgres-conn get PQfinish ] cleanup ] with-scope ; inline

: with-postgres-catch ( host port pgopts pgtty db user pass quot -- )
    [ with-postgres ] catch [ "caught: " write print ] when* ;

: test-connection ( host port pgopts pgtty db user pass -- bool )
    [ [ ] with-postgres ] catch "Error connecting!" "Connected!" ? print ;

: postgres-error ( ret -- ret )
    dup 0 = [ PQresultErrorMessage throw ] when ;

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
    unit \ (do-command) add postgres-conn get swap call ;

: prepare ( str quot word -- quot )
    rot unit swap append swap append postgres-conn get swap ;

: do-query ( str quot -- )
    [ (do-query) query-res set ] prepare catch [ rethrow ] [ query-res get PQclear ] if* ;

: result>seq ( -- )
    query-res get [ PQnfields ] keep PQntuples
    [ [ over [ [ 2dup query-res get -rot PQgetvalue , ] repeat ] { } make , ] repeat ] { } make nip ;

: print-table ( seq -- )
    [ [ "\t" append write ] each "\n" write ] each ;


