USING: kernel accessors io.sockets io.sockets.private
io.backend.windows io.backend windows.winsock system destructors
alien.c-types classes.struct combinators ;
IN: io.sockets.windows

M: windows addrinfo-error ( n -- )
    winsock-return-check ;

M: windows sockaddr-of-family ( alien af -- addrspec )
    {
        { AF_INET [ sockaddr-in memory>struct ] }
        { AF_INET6 [ sockaddr-in6 memory>struct ] }
        [ 2drop f ]
    } case ;

M: windows addrspec-of-family ( af -- addrspec )
    {
        { AF_INET [ T{ inet4 } ] }
        { AF_INET6 [ T{ inet6 } ] }
        [ drop f ]
    } case ;

HOOK: WSASocket-flags io-backend ( -- DWORD )

TUPLE: win32-socket < win32-file ;

: <win32-socket> ( handle -- win32-socket )
    win32-socket new-win32-handle ;

M: win32-socket dispose ( stream -- )
    handle>> closesocket drop ;

: unspecific-sockaddr/size ( addrspec -- sockaddr len )
    [ empty-sockaddr/size ] [ protocol-family ] bi pick (>>family) ;

: opened-socket ( handle -- win32-socket )
    <win32-socket> |dispose dup add-completion ;

: open-socket ( addrspec type -- win32-socket )
    [ protocol-family ] dip
    0 f 0 WSASocket-flags WSASocket
    dup socket-error
    opened-socket ;

M: object (get-local-address) ( socket addrspec -- sockaddr )
    [ handle>> ] dip empty-sockaddr/size <int>
    [ getsockname socket-error ] 2keep drop ;

M: object (get-remote-address) ( socket addrspec -- sockaddr )
    [ handle>> ] dip empty-sockaddr/size <int>
    [ getpeername socket-error ] 2keep drop ;

: bind-socket ( win32-socket sockaddr len -- )
    [ handle>> ] 2dip bind socket-error ;

M: object ((client)) ( addrspec -- handle )
    [ SOCK_STREAM open-socket ] keep
    [
        bind-local-address get
        [ nip make-sockaddr/size ]
        [ unspecific-sockaddr/size ] if* bind-socket
    ] [ drop ] 2bi ;

: server-socket ( addrspec type -- fd )
    [ open-socket ] [ drop ] 2bi
    [ make-sockaddr/size bind-socket ] [ drop ] 2bi ;

! http://support.microsoft.com/kb/127144
! NOTE: Possibly tweak this because of SYN flood attacks
: listen-backlog ( -- n ) HEX: 7fffffff ; inline

M: object (server) ( addrspec -- handle )
    [
        SOCK_STREAM server-socket
        dup handle>> listen-backlog listen winsock-return-check
    ] with-destructors ;

M: windows (datagram) ( addrspec -- handle )
    [ SOCK_DGRAM server-socket ] with-destructors ;
