! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel io io.encodings.binary io.servers ;

IN: echo-server

: echo-loop ( -- )
    1024 read-partial [ write flush echo-loop ] when* ;

: <echo-server> ( port -- server )
    binary <threaded-server>
        swap >>insecure
        "echo.server" >>name
        [ echo-loop ] >>handler ;

: echod ( port -- server )
    <echo-server> start-server ;

: echod-main ( -- ) 1234 echod drop ;

MAIN: echod-main

