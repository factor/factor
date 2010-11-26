! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar calendar.format io io.encodings.ascii
io.servers kernel threads ;
IN: time-server

: handle-time-client ( -- )
    now timestamp>rfc822 print ;

: <time-server> ( -- threaded-server )
    ascii <threaded-server>
        "time-server" >>name
        1234 >>insecure
        [ handle-time-client ] >>handler ;

: start-time-server ( -- )
    <time-server> start-server drop ;

MAIN: start-time-server
