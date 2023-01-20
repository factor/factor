! Copyright (C) 2007, 2009 Slava Pestov, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors alien alien.c-types alien.data alien.strings
byte-arrays classes.struct combinators destructors io.backend
io.encodings.ascii io.files.windows io.ports io.sockets
io.sockets.icmp io.sockets.private kernel libc locals math
sequences system windows.errors windows.handles windows.kernel32
windows.types windows.winsock ;

FROM: namespaces => get ;
IN: io.sockets.windows

: set-socket-option ( handle level opt -- )
    [ handle>> ] 2dip 1 int <ref> dup byte-length setsockopt socket-error ;

: set-ioctl-socket ( handle cmd arg -- )
    [ handle>> ] 2dip ulong <ref> ioctlsocket socket-error ;

M: windows addrinfo-error-string
    n>win32-error-string ;

M: windows sockaddr-of-family
    {
        { AF_INET [ sockaddr-in memory>struct ] }
        { AF_INET6 [ sockaddr-in6 memory>struct ] }
        [ 2drop f ]
    } case ;

M: windows addrspec-of-family
    {
        { AF_INET [ T{ ipv4 } ] }
        { AF_INET6 [ T{ ipv6 } ] }
        [ drop f ]
    } case ;

TUPLE: win32-socket < win32-file ;

: <win32-socket> ( handle -- win32-socket )
    win32-socket new-win32-handle ;

M: win32-socket dispose*
    handle>> closesocket socket-error* ;

: unspecific-sockaddr/size ( addrspec -- sockaddr len )
    [ empty-sockaddr/size ] [ protocol-family ] bi pick family<< ;

: opened-socket ( handle -- win32-socket )
    <win32-socket> |dispose add-completion ;

: open-socket ( addrspec type -- win32-socket )
    [ drop protocol-family ] [ swap protocol ] 2bi
    f 0 WSA_FLAG_OVERLAPPED WSASocket
    dup socket-error
    opened-socket ;

M: object (get-local-address)
    [ handle>> ] dip empty-sockaddr/size int <ref>
    [ getsockname socket-error ] keepd ;

M: object (get-remote-address)
    [ handle>> ] dip empty-sockaddr/size int <ref>
    [ getpeername socket-error ] keepd ;

: bind-socket ( win32-socket sockaddr len -- )
    [ handle>> ] 2dip bind socket-error ;

M: object remote>handle
    [ SOCK_STREAM open-socket ] keep
    [
        bind-local-address get
        [ nip make-sockaddr/size ]
        [ unspecific-sockaddr/size ] if* bind-socket
    ] [ drop ] 2bi ;

: server-socket ( addrspec type -- fd )
    [ open-socket ] [ drop ] 2bi
    [ make-sockaddr/size bind-socket ] [ drop ] 2bi ;

! https://support.microsoft.com/kb/127144
! NOTE: Possibly tweak this because of SYN flood attacks
: listen-backlog ( -- n ) 0x7fffffff ; inline

M: object (server)
    [
        SOCK_STREAM server-socket
        dup handle>> listen-backlog listen winsock-return-check
    ] with-destructors ;

M: windows (datagram)
    [ SOCK_DGRAM server-socket ] with-destructors ;

M: windows (raw)
    [ SOCK_RAW server-socket ] with-destructors ;

M: windows (broadcast)
    dup handle>> SOL_SOCKET SO_BROADCAST set-socket-option ;

: malloc-int ( n -- alien )
    int <ref> malloc-byte-array ; inline

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

: wait-for-socket ( args -- count )
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

M: object establish-connection
    make-sockaddr/size-outgoing <ConnectEx-args>
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

M: object (accept)
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

:: make-receive-buffer ( n buf -- buf' WSABUF )
    buf >c-ptr pinned-alien?
    [ buf ] [ n malloc &free [ buf n memcpy ] keep ] if :> buf'
    buf'
    WSABUF malloc-struct &free
        n >>len
        buf' >>buf ; inline

:: <WSARecvFrom-args> ( n buf datagram -- buf buf' WSARecvFrom )
    n buf make-receive-buffer :> ( buf' wsaBuf )
    buf buf'
    WSARecvFrom-args new
        datagram >>port
        datagram handle>> handle>> >>s
        datagram addr>> sockaddr-size
            [ malloc &free >>lpFrom ]
            [ malloc-int &free >>lpFromLen ] bi
        wsaBuf >>lpBuffers
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

:: finalize-buf ( buf buf' count -- )
    buf buf' eq? [ buf buf' count memcpy ] unless ; inline

:: parse-WSARecvFrom ( buf buf' count wsaRecvFrom -- count sockaddr )
    buf buf' count finalize-buf
    count wsaRecvFrom
    [ port>> addr>> empty-sockaddr dup ]
    [ lpFrom>> ]
    [ lpFromLen>> int deref ]
    tri memcpy ; inline

M: windows (receive-unsafe)
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
        swap make-sockaddr/size-outgoing
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

M: windows (send)
    [
        <WSASendTo-args>
        [ call-WSASendTo ]
        [ wait-for-socket drop ]
        bi
    ] with-destructors ;

M: windows host-name
    256 [ <byte-array> dup ] keep gethostname socket-error
    ascii alien>string ;
