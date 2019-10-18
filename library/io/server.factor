! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io
USING: errors io kernel math namespaces parser sequences strings
threads ;

! A simple logging framework.
SYMBOL: log-stream

: log-message ( msg -- )
    #! Log a message to the log stream, either stdio or a file.
    log-stream get [ stdio get ] unless*
    [ stream-print ] keep stream-flush ;

: log-error ( error -- ) "Error: " swap append log-message ;

: log-client ( client-stream -- )
    [
        "Accepted connection from " %
        dup client-stream-host %
        CHAR: : ,
        client-stream-port # 
    ] "" make log-message ;

: with-log-file ( file quot -- )
    #! Calls to log inside quot will output to a file.
    [ swap <file-writer> log-stream set call ] with-scope ;

: with-logging ( quot -- )
    #! Calls to log inside quot will output to stdio.
    [ stdio get log-stream set call ] with-scope ;

: with-client ( quot client -- )
    #! Spawn a new thread to handle a client connection.
    dup log-client [ swap with-stream ] in-thread 2drop ;
    inline

SYMBOL: server-stream

: server-loop ( quot -- )
    #! Keep waiting for connections.
    server-stream get accept over
    >r with-client r> server-loop ; inline

: with-server ( port ident quot -- )
    #! Start a TCP/IP server on the given port number. Store
    #! the port's server socket in the ident variable so that
    #! the server can be stopped by the user.
    >r >r <server> dup r> set r> swap [
        server-stream set
        [ server-loop ]
        [ server-stream get stream-close ] cleanup
    ] with-logging ; inline
