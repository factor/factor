! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: streams
USING: io-internals errors hashtables kernel stdio strings
namespaces unparser generic ;

TUPLE: server port ;
GENERIC: accept

M: server fclose ( stream -- )
    server-port close-port ;

C: server ( port -- stream )
    #! Starts listening on localhost:port. Returns a stream that
    #! you can close with fclose, and accept connections from
    #! with accept. No other stream operations are supported.
    [ >r server-socket r> set-server-port ] keep ;

TUPLE: client-stream delegate host ;

C: client-stream ( host port in out -- stream )
    #! fflush yields until connection is established.
    [ >r <fd-stream> r> set-client-stream-delegate ] keep
    [ >r ":" swap unparse cat3 r> set-client-stream-host ] keep
    dup fflush ;

: <client> ( host port -- stream )
    2dup client-socket <client-stream> ;

M: server accept ( server -- client )
    #! Accept a connection from a server socket.
    server-port blocking-accept <client-stream> ;
