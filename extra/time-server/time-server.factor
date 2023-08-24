! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar calendar.format command-line io
io.encodings.ascii io.servers kernel math.parser namespaces
sequences ;
IN: time-server

: handle-time-client ( -- )
    now timestamp>rfc822 print ;

: <time-server> ( port -- threaded-server )
    ascii <threaded-server>
        "time-server" >>name
        swap >>insecure
        [ handle-time-client ] >>handler ;

: time-server-main ( -- )
    command-line get [ 1234 ] [ first string>number ] if-empty
    <time-server> start-server wait-for-server ;

MAIN: time-server-main
