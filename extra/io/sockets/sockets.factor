! Copyright (C) 2007, 2008 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: generic kernel io.backend namespaces continuations
sequences arrays io.encodings io.nonblocking ;
IN: io.sockets

TUPLE: local path ;

: <local> ( path -- addrspec )
    normalize-path local construct-boa ;

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

HOOK: (client) io-backend ( addrspec -- client-in client-out )

GENERIC: client* ( addrspec -- client-in client-out )
M: array client* [ (client) 2array ] attempt-all first2 ;
M: object client* (client) ;

: <client> ( addrspec encoding -- stream )
    >r client* r> <encoder-duplex> ;

HOOK: (server) io-backend ( addrspec -- handle )

: <server> ( addrspec encoding -- server )
    >r [ (server) ] keep r> <server-port> ;

HOOK: (accept) io-backend ( server -- addrspec handle )

: accept ( server -- client )
    [ (accept) dup <reader&writer> ] keep
    server-port-encoding <encoder-duplex>
    <client-stream> ;

HOOK: <datagram> io-backend ( addrspec -- datagram )

HOOK: receive io-backend ( datagram -- packet addrspec )

HOOK: send io-backend ( packet addrspec datagram -- )

HOOK: resolve-host io-backend ( host serv passive? -- seq )

HOOK: host-name io-backend ( -- string )

M: inet client*
    dup inet-host swap inet-port f resolve-host
    dup empty? [ "Host name lookup failed" throw ] when
    client* ;
