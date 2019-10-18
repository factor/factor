! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: errors io kernel math namespaces parser sequences strings
threads ;

SYMBOL: log-stream

: log-message ( str -- )
    log-stream get [ stream-print ] keep stream-flush ;

: log-error ( str -- ) "Error: " swap append log-message ;

: log-client ( client -- )
    [
        "Accepted connection from " %
        dup client-stream-host %
        CHAR: : ,
        client-stream-port # 
    ] "" make log-message ;

: with-log-file ( path quot -- )
    [ swap <file-writer> log-stream set call ] with-scope ;

: with-logging ( quot -- )
    [ stdio get log-stream set call ] with-scope ;

: with-client ( quot client -- )
    dup log-client [ swap with-stream ] in-thread 2drop ;
    inline

SYMBOL: server-stream

: server-loop ( quot -- )
    server-stream get accept over
    >r with-client r> server-loop ; inline

: with-server ( port ident quot -- )
    >r >r <server> dup r> set r> swap [
        server-stream set
        [ server-loop ]
        [ server-stream get stream-close ] cleanup
    ] with-logging ; inline
