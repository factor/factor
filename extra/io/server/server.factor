! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.sockets io.files continuations
kernel math math.parser namespaces parser sequences strings
threads prettyprint debugger quotations ;

IN: io.server

SYMBOL: log-stream

: log-message ( str -- )
    log-stream get [ stream-print ] keep stream-flush ;

: log-error ( str -- ) "Error: " swap append log-message ;

: log-client ( client -- )
    "Accepted connection from "
    swap client-stream-addr unparse append log-message ;

: with-logging ( quot -- )
    stdio get log-stream rot with-variable ; inline

: with-client ( quot client -- )
    dup log-client [ swap with-stream ] in-thread 2drop ;
    inline

SYMBOL: server-stream

: accept-loop ( server quot -- )
    [ swap accept with-client ] 2keep accept-loop ; inline

: server-loop ( server quot -- )
    [ accept-loop ] [ drop stream-close ] cleanup ; inline

: spawn-server ( addrspec quot -- )
    "Waiting for connections on " pick unparse append log-message
    [
        >r <server> r> server-loop
    ] [
        "Cannot spawn server: " print
        print-error
    ] recover ; inline

: local-server ( port -- seq )
    "localhost" swap t resolve-host ;

: internet-server ( port -- seq )
    f swap t resolve-host ;

: with-server ( seq quot -- )
    [
        [ [ spawn-server ] in-thread 2drop ] curry each
    ] with-logging ; inline

: log-datagram ( addrspec -- )
    "Received datagram from " swap unparse append log-message ;

: datagram-loop ( quot datagram -- )
    [
        [ receive dup log-datagram >r swap call r> ] keep send
    ] 2keep datagram-loop ; inline

: spawn-datagrams ( quot addrspec -- )
    "Waiting for datagrams on " over unparse append log-message
    <datagram> [ datagram-loop ] [ stream-close ] cleanup ;
    inline

: with-datagrams ( seq quot -- )
    [
        [ [ swap spawn-datagrams ] in-thread 2drop ] curry each
    ] with-logging ; inline
