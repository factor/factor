! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays continuations db2 io kernel math namespaces
quotations sequences postgresql.db2.ffi alien alien.c-types
alien.data db2.types tools.walker ascii splitting math.parser
combinators libc calendar.format byte-arrays destructors
prettyprint accessors strings serialize io.encodings.binary
io.encodings.utf8 alien.strings io.streams.byte-array summary
present urls specialized-arrays db2.utils db2.connections ;
SPECIALIZED-ARRAY: uint
SPECIALIZED-ARRAY: void*
IN: postgresql.db2.lib

: pq-get-is-null ( handle row column -- ? ) PQgetisnull 1 = ;

: pq-get-string ( handle row column -- obj )
    3dup PQgetvalue utf8 alien>string
    dup empty? [ [ pq-get-is-null f ] dip ? ] [ [ 3drop ] dip ] if ;

: pq-get-number ( handle row column -- obj )
    pq-get-string dup [ string>number ] when ;

: pq-get-boolean ( handle row column -- ? )
    pq-get-string dup [ "t" = ] when ;

: postgresql-result-error-message ( res -- str/f )
    dup 0 = [ drop f ] [ PQresultErrorMessage [ blank? ] trim ] if ;

: postgres-result-error ( res -- )
    postgresql-result-error-message [ throw ] when* ;

: (postgresql-error-message) ( handle -- str )
    PQerrorMessage
    "\n" split [ [ blank? ] trim ] map "\n" join ;

: postgresql-error-message ( -- str )
    db-connection get handle>> (postgresql-error-message) ;

: postgresql-error ( res -- res )
    dup [ postgresql-error-message throw ] unless ;

ERROR: postgresql-result-null ;

M: postgresql-result-null summary ( obj -- str )
    drop "PQexec returned f." ;

: postgresql-result-ok? ( res -- ? )
    [ postgresql-result-null ] unless*
    PQresultStatus
    PGRES_COMMAND_OK PGRES_TUPLES_OK 2array member? ;

: connect-postgres ( host port pgopts pgtty db user pass -- conn )
    PQsetdbLogin
    dup PQstatus zero? [ (postgresql-error-message) throw ] unless ;

: do-postgresql-statement ( statement -- res )
    db-connection get handle>> swap sql>> PQexec dup postgresql-result-ok? [
        [ postgresql-result-error-message ] [ PQclear ] bi throw
    ] unless ;

: default-param-value ( obj -- alien n )
    ?number>string dup [ utf8 malloc-string &free ] when 0 ;


TUPLE: postgresql-malloc-destructor alien ;
C: <postgresql-malloc-destructor> postgresql-malloc-destructor

M: postgresql-malloc-destructor dispose ( obj -- )
    alien>> PQfreemem ;

: &postgresql-free ( alien -- alien )
    dup <postgresql-malloc-destructor> &dispose drop ; inline

: pq-get-blob ( handle row column -- obj/f )
    [ PQgetvalue ] 3keep 3dup PQgetlength
    dup 0 > [
        [ 3drop ] dip
        [
            memory>byte-array >string
            { uint }
            [
                PQunescapeBytea dup zero? [
                    postgresql-result-error-message throw
                ] [
                    &postgresql-free
                ] if
            ] with-out-parameters memory>byte-array
        ] with-destructors 
    ] [
        drop pq-get-is-null nip [ f ] [ B{ } clone ] if
    ] if ;
