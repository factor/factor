! Copyright (C) 2006 Mackenzie Straight, Doug Coleman.

IN: win32-server
USING: alien errors generic kernel kernel-internals math namespaces
       prettyprint sequences io strings threads win32-api
       win32-io-internals io-internals win32-stream ;

TUPLE: win32-client-stream host port ;

: (handle-socket-error) ( -- )
    WSAGetLastError dup ERROR_IO_PENDING = over ERROR_SUCCESS = or
    [ drop ] [ error_message alien>char-string throw ] if ;

: handle-socket-error!=0/f ( int -- )
    [ 0 f ] member? [ (handle-socket-error) ] unless ;

: handle-socket-error=0/f ( int -- )
    [ 0 f ] member? [ (handle-socket-error) ] when ;

: init-winsock ( -- )
    HEX: 0202 <wsadata> WSAStartup handle-socket-error!=0/f ;

: new-socket ( -- socket )
    AF_INET SOCK_STREAM 0 f f WSA_FLAG_OVERLAPPED
    WSASocket dup INVALID_SOCKET = [ (handle-socket-error) ] when ;

: setup-sockaddr ( port -- sockaddr )
    "sockaddr-in" <c-object> swap
    htons over set-sockaddr-in-port
    INADDR_ANY over set-sockaddr-in-addr 
    AF_INET over set-sockaddr-in-family ;

: bind-socket ( port socket -- )
    swap setup-sockaddr "sockaddr-in" c-size wsa-bind handle-socket-error!=0/f ;

: listen-backlog ( -- n ) 20 ; inline

: listen-socket ( socket -- )
    listen-backlog wsa-listen handle-socket-error!=0/f ;

: sockaddr> ( sockaddr -- port host )
    dup sockaddr-in-port ntohs swap sockaddr-in-addr inet-ntoa ;

: extract-remote-host ( buffer -- port host )
    buffer-ptr <alien> 0 32 32 0 <int> 
                               0 <int>
                               0 <int> 
                        dup >r 0 <int>
    GetAcceptExSockaddrs r> *int <alien> sockaddr> ;

C: win32-client-stream ( buf stream -- stream )
    [ set-delegate extract-remote-host ] keep
    [ set-win32-client-stream-host ] keep 
    [ set-win32-client-stream-port ] keep ;

M: win32-client-stream client-stream-host ( win32-client-stream -- host )
    win32-client-stream-host ;
M: win32-client-stream client-stream-port ( win32-client-stream -- port )
    win32-client-stream-port ;

: make-win32-server ( port -- win32-stream )
    new-socket tuck bind-socket dup listen-socket dup add-completion
    <win32-stream> <win32-duplex-stream> ;

: client-sockaddr ( host port -- sockaddr )
    setup-sockaddr [
        >r gethostbyname dup handle-socket-error=0/f hostent-addr
        r> set-sockaddr-in-addr
    ] keep ;

