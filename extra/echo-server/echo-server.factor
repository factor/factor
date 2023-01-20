! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.

USING: accessors command-line io io.encodings.binary io.servers
kernel math.parser namespaces sequences ;

IN: echo-server

: echo-loop ( -- )
    1024 read-partial [ write flush echo-loop ] when* ;

: <echo-server> ( port -- server )
    binary <threaded-server>
        swap >>insecure
        "echo.server" >>name
        [ echo-loop ] >>handler ;

: echo-server-main ( -- )
    command-line get [ 1234 ] [ first string>number ] if-empty
    <echo-server> start-server wait-for-server ;

MAIN: echo-server-main
