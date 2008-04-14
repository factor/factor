! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.sockets io.files logging continuations kernel
math math.parser namespaces parser sequences strings
prettyprint debugger quotations calendar
threads concurrency.combinators assocs ;
IN: io.server

SYMBOL: servers

<PRIVATE

LOG: accepted-connection NOTICE

: with-client ( client addrspec quot -- )
    [
        swap accepted-connection
        with-stream*
    ] 2curry with-disposal ; inline

\ with-client DEBUG add-error-logging

: accept-loop ( server quot -- )
    [
        >r accept r> [ with-client ] 3curry "Client" spawn drop
    ] 2keep accept-loop ; inline

: server-loop ( addrspec encoding quot -- )
    >r <server> dup servers get push r>
    [ accept-loop ] curry with-disposal ; inline

\ server-loop NOTICE add-error-logging

PRIVATE>

: local-server ( port -- seq )
    "localhost" swap t resolve-host ;

: internet-server ( port -- seq )
    f swap t resolve-host ;

: with-server ( seq service encoding quot -- )
    V{ } clone servers [
        [
            [ server-loop ] 2curry with-logging
        ] 3curry parallel-each
    ] with-variable ; inline

: stop-server ( -- )
    servers get [ dispose ] each ;

<PRIVATE

LOG: received-datagram NOTICE

: datagram-loop ( quot datagram -- )
    [
        [ receive dup received-datagram >r swap call r> ] keep
        pick [ send ] [ 3drop ] keep
    ] 2keep datagram-loop ; inline

: spawn-datagrams ( quot addrspec -- )
    <datagram> [ datagram-loop ] with-disposal ; inline

\ spawn-datagrams NOTICE add-input-logging

PRIVATE>

: with-datagrams ( seq service quot -- )
    [
        [ swap spawn-datagrams ] curry parallel-each
    ] curry with-logging ; inline
