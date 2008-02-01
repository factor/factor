USING: arrays continuations db io kernel math namespaces
quotations sequences db.postgresql.ffi ;
IN: db.postgresql.lib

SYMBOL: query-res

: connect-postgres ( host port pgopts pgtty db user pass -- conn )
    PQsetdbLogin
    dup PQstatus zero? [ "couldn't connect to database" throw ] unless ;

: postgresql-result-error-message ( res -- str/f )
    dup zero? [
        drop f
    ] [
        PQresultErrorMessage [ CHAR: \n = ] right-trim
    ] if ;

: postgres-result-error ( res -- )
    postgresql-result-error-message [ throw ] when* ;

: postgresql-error-message ( -- str )
    db get db-handle PQerrorMessage [ CHAR: \n = ] right-trim ;

: postgresql-error ( res -- res )
    dup [ postgresql-error-message throw ] unless ;

: postgresql-result-ok? ( n -- ? )
    PQresultStatus
    PGRES_COMMAND_OK PGRES_TUPLES_OK 2array member? ;

: do-postgresql-statement ( statement -- res )
    db get db-handle swap statement-sql PQexec dup postgresql-result-ok? [
        dup postgresql-result-error-message swap PQclear throw
    ] unless ;

! : do-command ( str -- )
    ! 1quotation \ (do-command) add db get swap call ;

! : prepare ( str quot word -- conn quot )
    ! rot 1quotation swap append swap append db get swap ;

! : do-query ( str quot -- )
    ! [ (do-query) query-res set ] prepare catch
    ! [ rethrow ] [ query-res get PQclear ] if* ;

! : result>seq ( -- seq )
    ! query-res get [ PQnfields ] keep PQntuples
    ! [ swap [ query-res get -rot PQgetvalue ] with map ] with map ;
! 
! : print-table ( seq -- )
    ! [ [ write bl ] each "\n" write ] each ;



! select * from animal where name = 'Simba'
! select * from animal where name = $1

! : (do-query) ( PGconn query -- PGresult* )
    ! ! For queries that do not return rows, PQexec() returns PGRES_COMMAND_OK
    ! ! For queries that return rows, PQexec() returns PGRES_TUPLES_OK
    ! PQexec dup postgresql-result-ok? [
        ! dup postgresql-error-message swap PQclear throw
    ! ] unless ;

! : (do-command) ( PGconn query -- PGresult* )
    ! [ (do-query) ] catch
    ! [
        ! swap
        ! "non-fatal error: " print
        ! "\tQuery: " write "'" write write "'" print
        ! "\t" write print
    ! ] when* drop ;
