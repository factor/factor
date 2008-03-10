! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays continuations db io kernel math namespaces
quotations sequences db.postgresql.ffi alien alien.c-types
db.types tools.walker ascii splitting math.parser
combinators combinators.cleave libc shuffle calendar.format ;
IN: db.postgresql.lib

: postgresql-result-error-message ( res -- str/f )
    dup zero? [
        drop f
    ] [
        PQresultErrorMessage [ blank? ] trim
    ] if ;

: postgres-result-error ( res -- )
    postgresql-result-error-message [ throw ] when* ;

: (postgresql-error-message) ( handle -- str )
    PQerrorMessage
    "\n" split [ [ blank? ] trim ] map "\n" join ;

: postgresql-error-message ( -- str )
    db get db-handle (postgresql-error-message) ;

: postgresql-error ( res -- res )
    dup [ postgresql-error-message throw ] unless ;

: postgresql-result-ok? ( n -- ? )
    PQresultStatus
    PGRES_COMMAND_OK PGRES_TUPLES_OK 2array member? ;

: connect-postgres ( host port pgopts pgtty db user pass -- conn )
    PQsetdbLogin
    dup PQstatus zero? [ (postgresql-error-message) throw ] unless ;

: do-postgresql-statement ( statement -- res )
    db get db-handle swap statement-sql PQexec dup postgresql-result-ok? [
        dup postgresql-result-error-message swap PQclear throw
    ] unless ;

: do-postgresql-bound-statement ( statement -- res )
    >r db get db-handle r>
    [ statement-sql ] keep
    [ statement-bind-params length f ] keep
    statement-bind-params
    [ number>string* dup [ malloc-char-string ] when ] map
    [
        [
            >c-void*-array f f 0 PQexecParams
            dup postgresql-result-ok? [
                dup postgresql-result-error-message swap PQclear throw
            ] unless
        ] keep
    ] [ [ free ] each ] [ ] cleanup ;

: pq-get-string ( handle row column -- obj )
    3dup PQgetvalue alien>char-string
    dup "" = [ >r PQgetisnull 1 = f r> ? ] [ 3nip ] if ;

: pq-get-number ( handle row column -- obj )
    pq-get-string dup [ string>number ] when ;

: pq-get-blob ( handle row column -- obj/f )
    [ PQgetvalue ] 3keep PQgetlength
    dup 0 > [
        memory>byte-array
    ] [
        2drop f
    ] if ;

: postgresql-column-typed ( handle row column type -- obj )
    dup array? [ first ] when
    {
        { +native-id+ [ pq-get-number ] }
        { INTEGER [ pq-get-number ] }
        { BIG-INTEGER [ pq-get-number ] }
        { DOUBLE [ pq-get-number ] }
        { TEXT [ pq-get-string ] }
        { VARCHAR [ pq-get-string ] }
        { DATE [ pq-get-string dup [ ymd>timestamp ] when ] }
        { TIME [ pq-get-string dup [ hms>timestamp ] when ] }
        { TIMESTAMP [ pq-get-string dup [ ymdhms>timestamp ] when ] }
        { DATETIME [ pq-get-string dup [ ymdhms>timestamp ] when ] }
        { BLOB [ pq-get-blob ] }
        { FACTOR-BLOB [ pq-get-blob ] }
        [ no-sql-type ]
    } case ;
    ! PQgetlength PQgetisnull
