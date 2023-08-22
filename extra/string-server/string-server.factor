! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays command-line io io.encodings.binary
io.servers kernel math.parser namespaces sequences strings ;
IN: string-server

: serve-fixed-string ( -- )
    300,000,000 CHAR: a <string> >byte-array write flush ;

: <string-server> ( port -- server )
    binary <threaded-server>
        swap >>insecure
        "string.server" >>name
        [ serve-fixed-string ] >>handler ;

: string-server-main ( -- )
    command-line get [ 1239 ] [ first string>number ] if-empty
    <string-server> start-server wait-for-server ;

MAIN: string-server-main

