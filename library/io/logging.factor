! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: logging
USING: kernel namespaces stdio streams strings ;

! A simple logging framework.

: log ( msg -- )
    #! Log a message to the log stream, either stdio or a file.
    "log" get dup [
        tuck stream-print stream-flush
    ] [
        2drop
    ] ifte ;

: with-logging ( quot -- )
    #! Calls to log inside quot will output to stdio.
    [ stdio get "log" set call ] with-scope ;

: with-log-file ( file quot -- )
    #! Calls to log inside quot will output to a file.
    [ swap <file-reader> "log" set call ] with-scope ;

! Helpful words.

: log-error ( error -- ) "Error: " swap cat2 log ;

: log-client ( client-stream -- )
    client-stream-host [
        "Accepted connection from " swap cat2 log
    ] when* ;
