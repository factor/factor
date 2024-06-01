! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings arrays ascii
calendar.format calendar.parser combinators db db.postgresql.ffi
db.types destructors io.encodings.utf8 kernel libc math math.parser
namespaces present sequences serialize specialized-arrays splitting
strings summary urls ;
SPECIALIZED-ARRAY: uint
SPECIALIZED-ARRAY: void*
IN: db.postgresql.lib

: postgresql-result-error-message ( res -- str/f )
    dup zero? [
        drop f
    ] [
        PQresultErrorMessage [ ascii:blank? ] trim
    ] if ;

: postgres-result-error ( res -- )
    postgresql-result-error-message [ throw ] when* ;

: (postgresql-error-message) ( handle -- str )
    PQerrorMessage
    split-lines [ [ ascii:blank? ] trim ] map join-lines ;

: postgresql-error-message ( -- str )
    db-connection get handle>> (postgresql-error-message) ;

: postgresql-error ( res -- res )
    dup [ postgresql-error-message throw ] unless ;

ERROR: postgresql-result-null ;

M: postgresql-result-null summary
    drop "PQexec returned f." ;

: postgresql-result-ok? ( res -- ? )
    [ postgresql-result-null ] unless*
    PQresultStatus
    PGRES_COMMAND_OK PGRES_TUPLES_OK 2array member? ;

: connect-postgres ( host port pgopts pgtty db user pass -- conn )
    PQsetdbLogin dup PQstatus zero? [
        [ (postgresql-error-message) ] [ PQfinish ] bi throw
    ] unless ;

: do-postgresql-statement ( statement -- res )
    db-connection get handle>> swap sql>> PQexec dup postgresql-result-ok? [
        [ postgresql-result-error-message ] [ PQclear ] bi throw
    ] unless ;

: type>oid ( symbol -- n )
    dup array? [ first ] when
    {
        { BLOB [ BYTEA-OID ] }
        { FACTOR-BLOB [ BYTEA-OID ] }
        [ drop 0 ]
    } case ;

: type>param-format ( symbol -- n )
    dup array? [ first ] when
    {
        { BLOB [ 1 ] }
        { FACTOR-BLOB [ 1 ] }
        [ drop 0 ]
    } case ;

: param-types ( statement -- seq )
    in-params>> [ type>> type>oid ] uint-array{ } map-as ;

: malloc-byte-array/length ( byte-array -- alien length )
    [ malloc-byte-array &free ] [ length ] bi ;

: default-param-value ( obj -- alien n )
    number>string* dup [ utf8 malloc-string &free ] when 0 ;

: param-values ( statement -- seq seq2 )
    [ bind-params>> ] [ in-params>> ] bi
    [
        [ value>> ] [ type>> ] bi* {
            { FACTOR-BLOB [
                dup [ object>bytes malloc-byte-array/length ] [ 0 ] if
            ] }
            { BLOB [ dup [ malloc-byte-array/length ] [ 0 ] if ] }
            { DATE [ dup [ timestamp>ymd ] when default-param-value ] }
            { TIME [ dup [ duration>hms ] when default-param-value ] }
            { DATETIME [ dup [ timestamp>ymdhms ] when default-param-value ] }
            { TIMESTAMP [ dup [ timestamp>ymdhms ] when default-param-value ] }
            { URL [ dup [ present ] when default-param-value ] }
            [ drop default-param-value ]
        } case 2array
    ] 2map flip [
        f f
    ] [
        first2 [ void* >c-array ] [ uint >c-array ] bi*
    ] if-empty ;

: param-formats ( statement -- seq )
    in-params>> [ type>> type>param-format ] uint-array{ } map-as ;

: do-postgresql-bound-statement ( statement -- res )
    [
        [ db-connection get handle>> ] dip
        {
            [ sql>> ]
            [ bind-params>> length ]
            [ param-types ]
            [ param-values ]
            [ param-formats ]
        } cleave
        0 PQexecParams dup postgresql-result-ok? [
            [ postgresql-result-error-message ] [ PQclear ] bi throw
        ] unless
    ] with-destructors ;

: pq-get-is-null ( handle row column -- ? )
    PQgetisnull 1 = ;

: pq-get-string ( handle row column -- obj )
    3dup PQgetvalue utf8 alien>string
    dup empty? [ [ pq-get-is-null f ] dip ? ] [ 3nip ] if ;

: pq-get-number ( handle row column -- obj )
    pq-get-string dup [ string>number ] when ;

: pq-get-blob ( handle row column -- obj/f )
    [ PQgetvalue ] 3keep 3dup PQgetlength
    dup 0 > [
        3nip
        [
            memory>byte-array >string
            { uint }
            [
                PQunescapeBytea dup zero? [
                    postgresql-result-error-message throw
                ] [
                    &PQfreemem
                ] if
            ] with-out-parameters memory>byte-array
        ] with-destructors
    ] [
        drop pq-get-is-null nip f B{ } ?
    ] if ;

: postgresql-column-typed ( handle row column type -- obj )
    dup array? [ first ] when
    {
        { +db-assigned-id+ [ pq-get-number ] }
        { +random-id+ [ pq-get-number ] }
        { INTEGER [ pq-get-number ] }
        { BIG-INTEGER [ pq-get-number ] }
        { DOUBLE [ pq-get-number ] }
        { TEXT [ pq-get-string ] }
        { VARCHAR [ pq-get-string ] }
        { DATE [ pq-get-string dup [ ymd>timestamp ] when ] }
        { TIME [ pq-get-string dup [ hms>duration ] when ] }
        { TIMESTAMP [ pq-get-string dup [ ymdhms>timestamp ] when ] }
        { DATETIME [ pq-get-string dup [ ymdhms>timestamp ] when ] }
        { BLOB [ pq-get-blob ] }
        { URL [ pq-get-string dup [ >url ] when ] }
        { FACTOR-BLOB [
            pq-get-blob
            dup [ bytes>object ] when ] }
        [ no-sql-type ]
    } case ;
