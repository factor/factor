! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io
USING: io kernel namespaces parser sequences strings ;

! A simple logging framework.
SYMBOL: log-stream

: log ( msg -- )
    #! Log a message to the log stream, either stdio or a file.
    log-stream get [
        [ stream-print ] keep stream-flush
    ] [
        print flush
    ] ifte* ;

: log-error ( error -- ) "Error: " swap append log ;

: log-client ( client-stream -- )
    [
        "Accepted connection from " %
        dup client-stream-host %
        CHAR: : ,
        client-stream-port number>string % 
    ] make-string log ;

: with-log-file ( file quot -- )
    #! Calls to log inside quot will output to a file.
    [ swap <file-writer> log-stream set call ] with-scope ;

: with-logging ( quot -- )
    #! Calls to log inside quot will output to stdio.
    [ stdio get log-stream set call ] with-scope ;
