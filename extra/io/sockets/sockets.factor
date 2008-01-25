! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.sockets
USING: generic kernel io.backend namespaces continuations
sequences arrays ;

TUPLE: local path ;

C: <local> local

TUPLE: inet4 host port ;

C: <inet4> inet4

TUPLE: inet6 host port ;

C: <inet6> inet6

TUPLE: inet host port ;

C: <inet> inet

TUPLE: client-stream addr ;

: <client-stream> ( addrspec delegate -- stream )
    { set-client-stream-addr set-delegate }
    client-stream construct ;

HOOK: (client) io-backend ( addrspec -- stream )

GENERIC: <client> ( addrspec -- stream )

M: array <client> [ (client) ] attempt-all ;

M: object <client> (client) ;

HOOK: <server> io-backend ( addrspec -- server )

HOOK: accept io-backend ( server -- client )

HOOK: <datagram> io-backend ( addrspec -- datagram )

HOOK: receive io-backend ( datagram -- packet addrspec )

HOOK: send io-backend ( packet addrspec datagram -- )

HOOK: resolve-host io-backend ( host serv passive? -- seq )

HOOK: host-name io-backend ( -- string )

M: inet <client>
    dup inet-host swap inet-port f resolve-host
    dup empty? [ "Host name lookup failed" throw ] when
    <client> ;
