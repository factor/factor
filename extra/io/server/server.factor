! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.sockets io.files io.streams.duplex logging
continuations destructors kernel math math.parser namespaces
parser sequences strings prettyprint debugger quotations
calendar threads concurrency.combinators assocs fry ;
IN: io.server

SYMBOL: servers

SYMBOL: remote-address

<PRIVATE

LOG: accepted-connection NOTICE

: with-connection ( client remote quot -- )
    '[
        , [ remote-address set ] [ accepted-connection ] bi
        @
    ] with-stream ; inline

\ with-connection DEBUG add-error-logging

: accept-loop ( server quot -- )
    [
        >r accept r> '[ , , , with-connection ] "Client" spawn drop
    ] 2keep accept-loop ; inline

: server-loop ( addrspec encoding quot -- )
    >r <server> dup servers get push r>
    '[ , accept-loop ] with-disposal ; inline

\ server-loop NOTICE add-error-logging

PRIVATE>

: local-server ( port -- seq )
    "localhost" swap t resolve-host ;

: internet-server ( port -- seq )
    f swap t resolve-host ;

: with-server ( seq service encoding quot -- )
    V{ } clone servers [
        '[ , [ , , server-loop ] with-logging ] parallel-each
    ] with-variable ; inline

: stop-server ( -- )
    servers get dispose-each ;

<PRIVATE

LOG: received-datagram NOTICE

: datagram-loop ( quot datagram -- )
    [
        [ receive dup received-datagram >r swap call r> ] keep
        pick [ send ] [ 3drop ] if
    ] 2keep datagram-loop ; inline

: spawn-datagrams ( quot addrspec -- )
    <datagram> [ datagram-loop ] with-disposal ; inline

\ spawn-datagrams NOTICE add-input-logging

PRIVATE>

: with-datagrams ( seq service quot -- )
    '[ [ , _ spawn-datagrams ] parallel-each ] with-logging ; inline
