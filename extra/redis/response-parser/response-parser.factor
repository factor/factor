! Copyright (C) 2009 Bruno Deferrari
! See http://factorcode.org/license.txt for BSD license.
USING: combinators io kernel math math.parser sequences ;
IN: redis.response-parser

<PRIVATE

: read-bulk ( n -- bytes ) dup 0 < [ drop f ] [ read 2 read drop ] if ;
: (read-multi-bulk) ( -- bytes ) readln rest string>number read-bulk ;
: read-multi-bulk ( n -- seq/f )
    dup 0 < [ drop f ] [
        iota [ drop (read-multi-bulk) ] map
    ] if ;

: handle-response ( string -- string ) ; ! TODO
: handle-error ( string -- string ) ; ! TODO

PRIVATE>

: read-response ( -- response )
    readln unclip {
        { CHAR: : [ string>number ] }
        { CHAR: + [ handle-response ] }
        { CHAR: $ [ string>number read-bulk ] }
        { CHAR: * [ string>number read-multi-bulk ] }
        { CHAR: - [ handle-error ] }
    } case ;
