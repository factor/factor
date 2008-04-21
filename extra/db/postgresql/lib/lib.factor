! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays continuations db io kernel math namespaces
quotations sequences db.postgresql.ffi alien alien.c-types
db.types tools.walker ascii splitting math.parser combinators
libc shuffle calendar.format byte-arrays destructors prettyprint
accessors strings serialize io.encodings.binary io.encodings.utf8
alien.strings io.streams.byte-array inspector ;
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
    db get handle>> (postgresql-error-message) ;

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
    db get handle>> swap sql>> PQexec dup postgresql-result-ok? [
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
    in-params>> [ type>> type>oid ] map >c-uint-array ;

: malloc-byte-array/length
    [ malloc-byte-array dup free-always ] [ length ] bi ;

: param-values ( statement -- seq seq2 )
    [ bind-params>> ] [ in-params>> ] bi
    [
        type>> {
            { FACTOR-BLOB [
                dup [ object>bytes malloc-byte-array/length ] [ 0 ] if
            ] }
            { BLOB [ dup [ malloc-byte-array/length ] [ 0 ] if ] }
            [
                drop number>string* dup [
                    utf8 malloc-string dup free-always
                ] when 0
            ]
        } case 2array
    ] 2map flip dup empty? [
        drop f f
    ] [
        first2 [ >c-void*-array ] [ >c-uint-array ] bi*
    ] if ;

: param-formats ( statement -- seq )
    in-params>> [ type>> type>param-format ] map >c-uint-array ;

: do-postgresql-bound-statement ( statement -- res )
    [
        >r db get handle>> r>
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
    dup empty? [ >r pq-get-is-null f r> ? ] [ 3nip ] if ;

: pq-get-number ( handle row column -- obj )
    pq-get-string dup [ string>number ] when ;

TUPLE: postgresql-malloc-destructor alien ;
C: <postgresql-malloc-destructor> postgresql-malloc-destructor

M: postgresql-malloc-destructor dispose ( obj -- )
    alien>> PQfreemem ;

: postgresql-free-always ( alien -- )
    <postgresql-malloc-destructor> add-always-destructor ;

: pq-get-blob ( handle row column -- obj/f )
    [ PQgetvalue ] 3keep 3dup PQgetlength
    dup 0 > [
        3nip
        [
            memory>byte-array >string
            0 <uint>
            [
                PQunescapeBytea dup zero? [
                    postgresql-result-error-message throw
                ] [
                    dup postgresql-free-always
                ] if
            ] keep
            *uint memory>byte-array
        ] with-destructors 
    ] [
        drop pq-get-is-null nip [ f ] [ B{ } clone ] if
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
        { FACTOR-BLOB [
            pq-get-blob
            dup [ bytes>object ] when ] }
        [ no-sql-type ]
    } case ;
