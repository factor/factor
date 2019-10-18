! Copyright (C) 2004, 2007 Mackenzie Straight, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.

IN: io-internals
USING: alien buffers errors generic kernel kernel-internals
math namespaces network parser nonblocking-io prettyprint
sequences io strings threads win32-api io-internals ;

: (handle-socket-error) ( -- )
    WSAGetLastError dup ERROR_IO_PENDING = over ERROR_SUCCESS = or
    [ drop ] [ error_message alien>u16-string throw ] if ;

: handle-socket-error!=0/f ( int -- )
    [ 0 f ] member? [ (handle-socket-error) ] unless ;

: handle-socket-error=0/f ( int -- )
    [ 0 f ] member? [ (handle-socket-error) ] when ;

: init-winsock ( -- )
    HEX: 0202 <wsadata> WSAStartup handle-socket-error!=0/f ;

: new-socket ( -- socket )
    AF_INET SOCK_STREAM 0 f f WSA_FLAG_OVERLAPPED
    WSASocket dup INVALID_SOCKET = [ (handle-socket-error) ] when ;

: init-sockaddr ( port -- sockaddr )
    "sockaddr-in" <c-object>
    [ AF_INET swap set-sockaddr-in-family ] keep
    [ >r htons r> set-sockaddr-in-port ] keep
    [ INADDR_ANY swap set-sockaddr-in-addr ] keep ;

: bind-socket ( port socket -- )
    swap init-sockaddr "sockaddr-in" heap-size wsa-bind handle-socket-error!=0/f ;

: listen-backlog ( -- n ) 20 ; inline

: listen-socket ( socket -- )
    listen-backlog wsa-listen handle-socket-error!=0/f ;

: sockaddr> ( sockaddr -- port host )
    dup sockaddr-in-port ntohs swap sockaddr-in-addr inet-ntoa ;

: extract-remote-host ( buffer -- port host )
    buffer-ptr 0 32 32 0 <int> 
                       0 <int>
                       0 <int> 
                dup >r 0 <int>
    GetAcceptExSockaddrs r> *void* sockaddr> ;

: client-sockaddr ( host port -- sockaddr )
    init-sockaddr [
        >r gethostbyname dup [
            "Host lookup failed" throw
        ] unless hostent-addr
        r> set-sockaddr-in-addr
    ] keep ;

: handle>duplex-stream ( handle -- stream )
    f <win32-file> dup
    >r <reader> r> <writer> <duplex-stream> ;

C: client-stream ( host port# port -- stream )
    [ >r handle>duplex-stream r> set-delegate ] keep
    [ set-client-stream-host ] keep
    [ set-client-stream-port ] keep ;

: server-socket ( port -- stream )
    new-socket tuck bind-socket
    dup listen-socket dup add-completion f <win32-file> ;

IN: network

TUPLE: server client ;

C: server ( port -- server )
    [ >r server-socket f <port> r> set-delegate ] keep
    server over set-port-type ;


IN: io-internals

: (accept) ( port alien buffer continuation -- )
    >r pick dup make-overlapped tuck r> <io-callback> save-callback
    >r >r >r port-handle win32-file-handle r> r>
    buffer-ptr 0 32 32 f r>
    AcceptEx handle-socket-error!=0/f stop ;

IN: network

: accept ( server -- client )
    dup touch-port
    new-socket 64 <buffer> [
        (accept)
    ] callcc0
    [ extract-remote-host ] keep buffer-free
    rot dup add-completion <client-stream> nip ;

: <client> ( host port -- stream )
    client-sockaddr new-socket [
        swap "sockaddr-in" heap-size connect
        handle-socket-error!=0/f
    ] keep dup add-completion handle>duplex-stream ;

