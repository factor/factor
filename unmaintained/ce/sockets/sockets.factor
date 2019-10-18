USING: alien alien.c-types combinators io io.backend io.buffers
io.ports io.sockets io.windows kernel libc
math namespaces prettyprint qualified sequences strings threads
threads.private windows windows.kernel32 io.windows.ce.backend
byte-arrays system ;
QUALIFIED: windows.winsock
IN: io.windows.ce

M: wince WSASocket-flags ( -- DWORD ) 0 ;

M: win32-socket wince-read ( port port-handle -- )
    win32-file-handle over buffer-end pick buffer-capacity 0
    windows.winsock:recv
    dup windows.winsock:SOCKET_ERROR = [
        drop port-errored
    ] [
        dup zero?
        [ drop t swap set-port-eof? ] [ swap n>buffer ] if
    ] if ;

M: win32-socket wince-write ( port port-handle -- )
    win32-file-handle over buffer@ pick buffer-length 0
    windows.winsock:send
    dup windows.winsock:SOCKET_ERROR =
    [ drop port-errored ] [ swap buffer-consume ] if ;

: do-connect ( addrspec -- socket )
    [ tcp-socket dup ] keep
    make-sockaddr/size
    f f f f
    windows.winsock:WSAConnect
    windows.winsock:winsock-error!=0/f ;

M: wince (client) ( addrspec -- reader writer )
    do-connect <win32-socket> dup <ports> ;

M: wince (server) ( addrspec -- handle )
    windows.winsock:SOCK_STREAM server-fd
    dup listen-on-socket
    <win32-socket> ;

M: wince (accept) ( server -- client )
    [
        [
            dup port-handle win32-file-handle
            swap server-port-addr sockaddr-type heap-size
            dup <byte-array> [
                swap <int> f 0
                windows.winsock:WSAAccept
                dup windows.winsock:INVALID_SOCKET =
                [ windows.winsock:winsock-error ] when
            ] keep
        ] keep server-port-addr parse-sockaddr swap
        <win32-socket> <ports>
    ] with-timeout ;

M: wince <datagram> ( addrspec -- datagram )
    [
        windows.winsock:SOCK_DGRAM server-fd <win32-socket>
    ] keep <datagram-port> ;

: packet-size 65536 ; inline

: receive-buffer ( -- buf )
    \ receive-buffer get-global expired? [
        packet-size malloc \ receive-buffer set-global
    ] when
    \ receive-buffer get-global ;

: make-WSABUF ( len buf -- ptr )
    "WSABUF" <c-object>
    [ windows.winsock:set-WSABUF-buf ] keep
    [ windows.winsock:set-WSABUF-len ] keep ;

: receive-WSABUF ( -- buf )
    packet-size receive-buffer make-WSABUF ;

: packet-data ( len -- byte-array )
    receive-buffer swap memory>byte-array ;

packet-size <byte-array> receive-buffer set-global

M: wince receive ( datagram -- packet addrspec )
    dup check-datagram-port
    [
        port-handle win32-file-handle
        receive-WSABUF
        1
        0 <uint> [
            0 <uint>
            64 "char" <c-array> [
                64 <int>
                f
                f
                windows.winsock:WSARecvFrom
                windows.winsock:winsock-error!=0/f
            ] keep
        ] keep *uint packet-data swap
    ] keep datagram-port-addr parse-sockaddr ;

: send-WSABUF ( byte-array -- ptr )
    dup length packet-size > [ "UDP packet too long" throw ] when
    dup length receive-buffer rot pick memcpy
    receive-buffer make-WSABUF ;

M: wince send ( packet addrspec datagram -- )
    3dup check-datagram-send
    port-handle win32-file-handle
    rot send-WSABUF
    rot make-sockaddr/size
    >r >r 1 0 <uint> 0 r> r> f f
    windows.winsock:WSASendTo
    windows.winsock:winsock-error!=0/f ;
