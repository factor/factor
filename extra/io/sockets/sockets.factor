! Copyright (C) 2007, 2008 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: generic kernel io.backend namespaces continuations
sequences arrays io.encodings io.nonblocking io.streams.duplex
accessors ;
IN: io.sockets

TUPLE: local path ;

: <local> ( path -- addrspec )
    normalize-path local boa ;

TUPLE: inet4 host port ;

C: <inet4> inet4

TUPLE: inet6 host port ;

C: <inet6> inet6

TUPLE: inet host port ;

C: <inet> inet

HOOK: ((client)) io-backend ( addrspec -- client-in client-out )

GENERIC: (client) ( addrspec -- client-in client-out )
M: array (client) [ ((client)) 2array ] attempt-all first2 ;
M: object (client) ((client)) ;

: <client> ( addrspec encoding -- stream )
    >r (client) r> <encoder-duplex> ;

: with-client ( addrspec encoding quot -- )
    >r <client> r> with-stream ; inline

HOOK: (server) io-backend ( addrspec -- handle )

: <server> ( addrspec encoding -- server )
    >r [ (server) ] keep r> <server-port> ;

HOOK: (accept) io-backend ( server -- addrspec handle )

: accept ( server -- client addrspec )
    [ (accept) dup <reader&writer> ] [ encoding>> ] bi
    <encoder-duplex> swap ;

HOOK: <datagram> io-backend ( addrspec -- datagram )

HOOK: receive io-backend ( datagram -- packet addrspec )

HOOK: send io-backend ( packet addrspec datagram -- )

HOOK: resolve-host io-backend ( host serv passive? -- seq )

HOOK: host-name io-backend ( -- string )

M: inet (client)
    [ host>> ] [ port>> ] bi f resolve-host
    [ empty? [ "Host name lookup failed" throw ] when ]
    [ (client) ]
    bi ;
