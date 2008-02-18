! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.sockets io.files logging continuations kernel
math math.parser namespaces parser sequences strings
prettyprint debugger quotations calendar
threads concurrency.futures ;

IN: io.server

LOG: accepted-connection NOTICE

: with-client ( client quot -- )
    [
        over client-stream-addr accepted-connection
        with-stream*
    ] curry with-disposal ; inline

\ with-client NOTICE add-error-logging

: accept-loop ( server quot -- )
    [
        >r accept r> [ with-client ] 2curry
        "Client" spawn drop
    ] 2keep accept-loop ; inline

: server-loop ( server quot -- )
    [ accept-loop ] curry with-disposal ; inline

SYMBOL: servers

: spawn-server ( addrspec quot -- )
    >r <server> dup servers get push r> server-loop ; inline

\ spawn-server NOTICE add-error-logging

: local-server ( port -- seq )
    "localhost" swap t resolve-host ;

: internet-server ( port -- seq )
    f swap t resolve-host ;

: with-server ( seq service quot -- )
    [
        V{ } clone servers set
        [ spawn-server ] curry parallel-each
    ] curry with-logging ; inline

: stop-server ( -- )
    servers get [ dispose ] each ;

: received-datagram ( addrspec -- ) drop ;

\ received-datagram NOTICE add-input-logging

: datagram-loop ( quot datagram -- )
    [
        [ receive dup received-datagram >r swap call r> ] keep
        pick [ send ] [ 3drop ] keep
    ] 2keep datagram-loop ; inline

: spawn-datagrams ( quot addrspec -- )
    <datagram> [ datagram-loop ] with-disposal ; inline

\ spawn-datagrams NOTICE add-input-logging

: with-datagrams ( seq service quot -- )
    [
        [ swap spawn-datagrams ] curry parallel-each
    ] curry with-logging ; inline
