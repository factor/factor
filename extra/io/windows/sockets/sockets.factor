USING: kernel accessors io.sockets io.windows
windows.winsock system ;
IN: io.windows.sockets

HOOK: WSASocket-flags io-backend ( -- DWORD )

TUPLE: win32-socket < win32-file ;

: <win32-socket> ( handle -- win32-socket )
    win32-socket new
        swap >>handle ;

M: win32-socket dispose ( stream -- )
    handle>> closesocket drop ;

: unspecific-sockaddr/size ( addrspec -- sockaddr len )
    [ empty-sockaddr/size ] [ protocol-family ] bi
    pick set-sockaddr-in-family ;

: open-socket ( addrspec type -- win3-socket )
    >r protocol-family r>
    0 f 0 WSASocket-flags WSASocket
    dup socket-error
    <win32-socket> |dispose
    dup add-completion ;

M: object get-local-address ( socket addrspec -- sockaddr )
    >r handle>> r> empty-sockaddr/size
    [ getsockname socket-error ] 2keep drop ;

M: object ((client)) ( addrspec -- handle )
    [ open-socket ] [ drop ] 2bi
    [ unspecific-sockaddr/size bind socket-error ] [ drop ] 2bi ;

: server-socket ( addrspec type -- fd )
    [ open-socket ] [ drop ] 2bi
    [ make-sockaddr/size bind socket-error ] [ drop ] 2bi ;

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

M: windows addrinfo-error ( n -- )
    winsock-return-check ;
