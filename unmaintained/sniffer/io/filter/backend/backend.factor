USING: byte-arrays combinators io io.backend
io.sockets.headers io.sniffer.backend kernel
prettyprint sequences ;
IN: io.sniffer.filter.backend

HOOK: sniffer-loop io-backend ( stream -- )
HOOK: packet. io-backend ( string -- )

: (packet.) ( string -- )
    dup 14 head >byte-array
    "--Ethernet Header--" print
        dup etherneth.
    dup etherneth-type {
        ! 0x800 [ ] ! IP
        ! 0x806 [ ] ! ARP
        [ "Unknown type: " write .h ]
    } case 2drop ;
