! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: streams
USING: io-internals errors hashtables kernel stdio strings
namespaces unparser generic ;

! A TCP client socket stream.
TUPLE: client-stream host ;

C: client-stream ( host port in out -- stream )
    #! stream-flush yields until connection is established.
    [ >r <fd-stream> r> set-delegate ] keep
    [ >r ":" swap unparse cat3 r> set-client-stream-host ] keep
    dup stream-flush ;

: <client> ( host port -- stream )
    #! Connect to a port number on a TCP host.
    2dup client-socket <client-stream> ;

! A server socket that listens on a port for TCP connections.
TUPLE: server port ;
GENERIC: accept ( server -- socket )

C: server ( port -- stream )
    #! Starts listening for TCP connections on localhost:port.
    [ >r server-socket r> set-server-port ] keep ;

M: server stream-close ( stream -- )
    server-port close-port ;

M: server accept ( server -- client )
    #! Accept a TCP connection from a server socket.
    server-port blocking-accept <client-stream> ;
