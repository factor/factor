! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar calendar.format io io.encodings.ascii
io.servers.connection threads ;
IN: time-server

: handle-time-client ( -- )
    now timestamp>rfc822 print ;

: <time-server> ( -- threaded-server )
    ascii <threaded-server>
        "time-server" >>name
        1234 >>insecure
        [ handle-time-client ] >>handler ;

: start-time-server ( -- threaded-server )
    <time-server> [ start-server ] in-thread ;

MAIN: start-time-server
