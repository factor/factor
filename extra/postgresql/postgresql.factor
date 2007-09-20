! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.

! adapted from libpq-fe.h version 7.4.7
! tested on debian linux with postgresql 7.4.7

USING: arrays alien alien.syntax continuations io
kernel math namespaces postgresql.libpq prettyprint
quotations sequences debugger ;
IN: postgresql

SYMBOL: db
SYMBOL: query-res

: connect-postgres ( host port pgopts pgtty db user pass -- conn )
    PQsetdbLogin
    dup PQstatus zero? [ "couldn't connect to database" throw ] unless ;

: with-postgres ( host port pgopts pgtty db user pass quot -- )
    [ >r connect-postgres db set r>
    [ db get PQfinish ] [ ] cleanup ] with-scope ; inline

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
    1quotation \ (do-command) add db get swap call ;

: prepare ( str quot word -- conn quot )
    rot 1quotation swap append swap append db get swap ;

: do-query ( str quot -- )
    [ (do-query) query-res set ] prepare catch
    [ rethrow ] [ query-res get PQclear ] if* ;

: result>seq ( -- seq )
    query-res get [ PQnfields ] keep PQntuples
    [ swap [ query-res get -rot PQgetvalue ] curry* map ] curry* map ;

: print-table ( seq -- )
    [ [ write bl ] each "\n" write ] each ;

