USING: alien.c-types byte-arrays combinators hexdump io io.backend
io.streams.string io.sockets.headers kernel math prettyprint
io.sniffer sequences system ;
IN: io.sniffer.filter

HOOK: sniffer-loop io-backend ( stream -- )
HOOK: packet. io-backend ( string -- )

: (packet.) ( string -- )
    dup 14 head >byte-array
    "--Ethernet Header--" print
        dup etherneth.
    dup etherneth-type {
        ! HEX: 800 [ ] ! IP
        ! HEX: 806 [ ] ! ARP
        [ "Unknown type: " write .h ]
    } case
    
    drop drop ;

USE-IF: bsd? io.sniffer.filter.bsd

