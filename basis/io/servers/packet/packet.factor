USING: concurrency.combinators destructors fry
io.servers.datagram.private io.sockets kernel logging ;
IN: io.servers.datagram

<PRIVATE

LOG: received-datagram NOTICE

: datagram-loop ( quot datagram -- )
    [
        [ receive dup received-datagram [ swap call ] dip ] keep
        pick [ send ] [ 3drop ] if
    ] 2keep datagram-loop ; inline

: spawn-datagrams ( quot addrspec -- )
    <datagram> [ datagram-loop ] with-disposal ; inline

\ spawn-datagrams NOTICE add-input-logging

PRIVATE>

: with-datagrams ( seq service quot -- )
    '[ [ [ _ ] dip spawn-datagrams ] parallel-each ] with-logging ; inline
