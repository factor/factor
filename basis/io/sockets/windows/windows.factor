! Copyright (C) 2007, 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data classes.struct
combinators destructors io.backend io.files.windows io.ports
io.sockets io.sockets.icmp io.sockets.private kernel libc math
sequences system windows.handles windows.kernel32 windows.types
windows.winsock ;
FROM: namespaces => get ;
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
        { AF_INET [ T{ ipv4 } ] }
        { AF_INET6 [ T{ ipv6 } ] }
        [ drop f ]
    } case ;

HOOK: WSASocket-flags io-backend ( -- DWORD )

TUPLE: win32-socket < win32-file ;

: <win32-socket> ( handle -- win32-socket )
    win32-socket new-win32-handle ;

M: win32-socket dispose* ( stream -- )
    handle>> closesocket socket-error* ;

: unspecific-sockaddr/size ( addrspec -- sockaddr len )
    [ empty-sockaddr/size ] [ protocol-family ] bi pick family<< ;

: opened-socket ( handle -- win32-socket )
    <win32-socket> |dispose add-completion ;

: open-socket ( addrspec type -- win32-socket )
    [ drop protocol-family ] [ swap protocol ] 2bi
    f 0 WSASocket-flags WSASocket
    dup socket-error
    opened-socket ;

M: object (get-local-address) ( socket addrspec -- sockaddr )
    [ handle>> ] dip empty-sockaddr/size int <ref>
    [ getsockname socket-error ] 2keep drop ;

M: object (get-remote-address) ( socket addrspec -- sockaddr )
    [ handle>> ] dip empty-sockaddr/size int <ref>
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

M: windows (raw) ( addrspec -- handle )
    [ SOCK_RAW server-socket ] with-destructors ;

: malloc-int ( n -- alien )
    int <ref> malloc-byte-array ; inline

M: windows WSASocket-flags ( -- DWORD )
    WSA_FLAG_OVERLAPPED ;

: get-ConnectEx-ptr ( socket -- void* )
    SIO_GET_EXTENSION_FUNCTION_POINTER
    WSAID_CONNECTEX
    GUID heap-size
    { void* }
    [
        void* heap-size
        0 DWORD <ref>
        f
        f
        WSAIoctl SOCKET_ERROR = [
            maybe-winsock-exception throw
        ] when
    ] with-out-parameters ;

TUPLE: ConnectEx-args port
    s name namelen lpSendBuffer dwSendDataLength
    lpdwBytesSent lpOverlapped ptr ;

: wait-for-socket ( args -- n )
    [ lpOverlapped>> ] [ port>> ] bi twiddle-thumbs ; inline

: <ConnectEx-args> ( sockaddr size -- ConnectEx )
    ConnectEx-args new
        swap >>namelen
        swap >>name
        f >>lpSendBuffer
        0 >>dwSendDataLength
        f >>lpdwBytesSent
        (make-overlapped) >>lpOverlapped ; inline

: call-ConnectEx ( ConnectEx -- )
    {
        [ s>> ]
        [ name>> ]
        [ namelen>> ]
        [ lpSendBuffer>> ]
        [ dwSendDataLength>> ]
        [ lpdwBytesSent>> ]
        [ lpOverlapped>> ]
        [ ptr>> ]
    } cleave
    int
    { SOCKET void* int PVOID DWORD LPDWORD void* }
    stdcall alien-indirect drop
    winsock-error ; inline

M: object establish-connection ( client-out remote -- )
    make-sockaddr/size <ConnectEx-args>
        swap >>port
        dup port>> handle>> handle>> >>s
        dup s>> get-ConnectEx-ptr >>ptr
        dup call-ConnectEx
        wait-for-socket drop ;

TUPLE: AcceptEx-args port
    sListenSocket sAcceptSocket lpOutputBuffer dwReceiveDataLength
    dwLocalAddressLength dwRemoteAddressLength lpdwBytesReceived lpOverlapped ;

: init-accept-buffer ( addr AcceptEx -- )
    swap sockaddr-size 16 +
        [ >>dwLocalAddressLength ] [ >>dwRemoteAddressLength ] bi
        dup dwLocalAddressLength>> 2 * malloc &free >>lpOutputBuffer
        drop ; inline

: <AcceptEx-args> ( server addr -- AcceptEx )
    AcceptEx-args new
        2dup init-accept-buffer
        swap SOCK_STREAM open-socket |dispose handle>> >>sAcceptSocket
        over handle>> handle>> >>sListenSocket
        swap >>port
        0 >>dwReceiveDataLength
        f >>lpdwBytesReceived
        (make-overlapped) >>lpOverlapped ; inline

! AcceptEx return value is useless
: call-AcceptEx ( AcceptEx -- )
    {
        [ sListenSocket>> ]
        [ sAcceptSocket>> ]
        [ lpOutputBuffer>> ]
        [ dwReceiveDataLength>> ]
        [ dwLocalAddressLength>> ]
        [ dwRemoteAddressLength>> ]
        [ lpdwBytesReceived>> ]
        [ lpOverlapped>> ]
    } cleave AcceptEx drop winsock-error ; inline

: (extract-remote-address) ( lpOutputBuffer dwReceiveDataLength dwLocalAddressLength dwRemoteAddressLength -- sockaddr )
    f void* <ref> 0 int <ref> f void* <ref>
    [ 0 int <ref> GetAcceptExSockaddrs ] keep void* deref ;

: extract-remote-address ( AcceptEx -- sockaddr )
    [
        {
            [ lpOutputBuffer>> ]
            [ dwReceiveDataLength>> ]
            [ dwLocalAddressLength>> ]
            [ dwRemoteAddressLength>> ]
        } cleave
        (extract-remote-address)
    ] [ port>> addr>> protocol-family ] bi
    sockaddr-of-family ; inline

M: object (accept) ( server addr -- handle sockaddr )
    [
        <AcceptEx-args>
        {
            [ call-AcceptEx ]
            [ wait-for-socket drop ]
            [ sAcceptSocket>> <win32-socket> ]
            [ extract-remote-address ]
        } cleave
    ] with-destructors ;

TUPLE: WSARecvFrom-args port
       s lpBuffers dwBufferCount lpNumberOfBytesRecvd
       lpFlags lpFrom lpFromLen lpOverlapped lpCompletionRoutine ;

: make-receive-buffer ( -- WSABUF )
    WSABUF malloc-struct &free
        default-buffer-size get
        [ >>len ] [ malloc &free >>buf ] bi ; inline

: <WSARecvFrom-args> ( datagram -- WSARecvFrom )
    WSARecvFrom-args new
        swap >>port
        dup port>> handle>> handle>> >>s
        dup port>> addr>> sockaddr-size
            [ malloc &free >>lpFrom ]
            [ malloc-int &free >>lpFromLen ] bi
        make-receive-buffer >>lpBuffers
        1 >>dwBufferCount
        0 malloc-int &free >>lpFlags
        0 malloc-int &free >>lpNumberOfBytesRecvd
        (make-overlapped) >>lpOverlapped ; inline

: call-WSARecvFrom ( WSARecvFrom -- )
    {
        [ s>> ]
        [ lpBuffers>> ]
        [ dwBufferCount>> ]
        [ lpNumberOfBytesRecvd>> ]
        [ lpFlags>> ]
        [ lpFrom>> ]
        [ lpFromLen>> ]
        [ lpOverlapped>> ]
        [ lpCompletionRoutine>> ]
    } cleave WSARecvFrom socket-error* ; inline

: parse-WSARecvFrom ( n WSARecvFrom -- packet sockaddr )
    [ lpBuffers>> buf>> swap memory>byte-array ]
    [
        [ port>> addr>> empty-sockaddr dup ]
        [ lpFrom>> ]
        [ lpFromLen>> int deref ]
        tri memcpy
    ] bi ; inline

M: windows (receive) ( datagram -- packet addrspec )
    [
        <WSARecvFrom-args>
        [ call-WSARecvFrom ]
        [ wait-for-socket ]
        [ parse-WSARecvFrom ]
        tri
    ] with-destructors ;

TUPLE: WSASendTo-args port
       s lpBuffers dwBufferCount lpNumberOfBytesSent
       dwFlags lpTo iToLen lpOverlapped lpCompletionRoutine ;

: make-send-buffer ( packet -- WSABUF )
    [ WSABUF malloc-struct &free ] dip
        [ malloc-byte-array &free >>buf ]
        [ length >>len ] bi ; inline

: <WSASendTo-args> ( packet addrspec datagram -- WSASendTo )
    WSASendTo-args new
        swap >>port
        dup port>> handle>> handle>> >>s
        swap make-sockaddr/size
            [ malloc-byte-array &free ] dip
            [ >>lpTo ] [ >>iToLen ] bi*
        swap make-send-buffer >>lpBuffers
        1 >>dwBufferCount
        0 >>dwFlags
        0 uint <ref> >>lpNumberOfBytesSent
        (make-overlapped) >>lpOverlapped ; inline

: call-WSASendTo ( WSASendTo -- )
    {
        [ s>> ]
        [ lpBuffers>> ]
        [ dwBufferCount>> ]
        [ lpNumberOfBytesSent>> ]
        [ dwFlags>> ]
        [ lpTo>> ]
        [ iToLen>> ]
        [ lpOverlapped>> ]
        [ lpCompletionRoutine>> ]
    } cleave WSASendTo socket-error* ; inline

M: windows (send) ( packet addrspec datagram -- )
    [
        <WSASendTo-args>
        [ call-WSASendTo ]
        [ wait-for-socket drop ]
        bi
    ] with-destructors ;
