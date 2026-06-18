! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: arrays combinators continuations io io.encodings.string
io.encodings.utf8 kernel math math.parser sequences splitting ;
IN: redis.response-parser

DEFER: read-response

TUPLE: redis-response message ;
ERROR: redis-error message ;

: <redis-response> ( message -- redis-response )
    redis-response boa ;

<PRIVATE

! The connection is a binary stream, so readln returns a byte-array with
! the \n stripped but a trailing \r left on; remove it.
: read-line ( -- bytes )
    readln B{ 13 } ?tail drop ;

: line>number ( bytes -- n )
    utf8 decode string>number ;

: read-bulk ( n -- string/f )
    ! read n *bytes* then the trailing \r\n, decoding the payload as UTF-8
    dup 0 < [ drop f ] [ read utf8 decode 2 read drop ] if ;

: read-verbatim ( n -- string )
    ! RESP3 verbatim string: a 3-byte type ("txt", "mkd") and ':' prefix
    read-bulk dup [ 4 tail ] when ;

! Read one reply, but capture a server error reply as a value instead of
! throwing, so an error nested in an aggregate (e.g. EXEC results) does
! not abort the parse and desync the connection.
: read-element ( -- response )
    [ read-response ] [ dup redis-error? [ ] [ rethrow ] if ] recover ;

: read-aggregate ( n -- seq/f )
    dup 0 < [ drop f ] [ [ read-element ] replicate ] if ;

: read-map ( n -- alist )
    [ read-element read-element 2array ] replicate ;

: read-attribute ( n -- response )
    ! attribute reply precedes the actual reply; read and discard it
    read-map drop read-response ;

: read-blob-error ( n -- * )
    read-bulk redis-error ;

: parse-double ( string -- float )
    {
        { "inf" [ 1/0. ] }
        { "-inf" [ -1/0. ] }
        { "nan" [ 0/0. ] }
        [ string>number >float ]
    } case ;

PRIVATE>

: read-response ( -- response )
    read-line unclip {
        ! RESP2
        { CHAR: + [ utf8 decode <redis-response> ] } ! simple string
        { CHAR: - [ utf8 decode redis-error ] }      ! simple error
        { CHAR: : [ line>number ] }                  ! integer
        { CHAR: $ [ line>number read-bulk ] }        ! bulk string
        { CHAR: * [ line>number read-aggregate ] }   ! array
        ! RESP3
        { CHAR: _ [ drop f ] }                       ! null
        { CHAR: # [ utf8 decode "t" = ] }            ! boolean
        { CHAR: , [ utf8 decode parse-double ] }     ! double
        { CHAR: ( [ line>number ] }                  ! big number
        { CHAR: = [ line>number read-verbatim ] }    ! verbatim string
        { CHAR: ! [ line>number read-blob-error ] }  ! blob error
        { CHAR: % [ line>number read-map ] }         ! map
        { CHAR: ~ [ line>number read-aggregate ] }   ! set
        { CHAR: > [ line>number read-aggregate ] }   ! push
        { CHAR: | [ line>number read-attribute ] }   ! attribute
    } case ;

: check-response ( -- )
    read-response drop ;
