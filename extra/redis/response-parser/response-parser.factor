! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: combinators io kernel math math.parser sequences ;
IN: redis.response-parser

DEFER: read-response

TUPLE: redis-response message ;
ERROR: redis-error message ;

: <redis-response> ( message -- redis-response )
    redis-response boa ;

<PRIVATE

: read-bulk ( n -- bytes )
    dup 0 < [ drop f ] [ read 2 read drop ] if ;
: read-multi-bulk ( n -- seq/f )
    dup 0 <
    [ drop f ]
    [ [ read-response ] replicate ] if ;

: handle-response ( string -- string )
    <redis-response> ;

: handle-error ( string -- * )
    redis-error ;

PRIVATE>

: read-response ( -- response )
    readln unclip {
        { char: \: [ string>number ] }
        { char: + [ handle-response ] }
        { char: $ [ string>number read-bulk ] }
        { char: * [ string>number read-multi-bulk ] }
        { char: - [ handle-error ] }
    } case ;

: check-response ( -- )
    read-response drop ;
