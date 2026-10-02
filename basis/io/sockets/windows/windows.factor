! Copyright (C) 2007, 2009 Slava Pestov, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors alien alien.c-types alien.data alien.strings
arrays assocs byte-arrays classes.struct combinators continuations
destructors io.backend
io.encodings.ascii io.files io.files.windows io.ports io.sockets
io.sockets.icmp io.sockets.private io.timeouts kernel libc literals
locals math math.bitwise sequences system threads windows.errors
windows.handles windows.kernel32 windows.types windows.wait windows.winsock ;

FROM: namespaces => get get-global ;
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

TUPLE: win32-socket < win32-file readiness ;

TUPLE: socket-readiness < disposable socket event wait key waiters closed ;

:: stop-socket-wait ( state -- )
    state wait>> [ unregister-handle-wait win32-error=0/f ] when*
    state f >>wait drop ;

:: wake-socket-waiters ( error state -- )
    state waiters>> keys [ error swap resume-with ] each
    state waiters>> clear-assoc ;

M:: socket-readiness dispose* ( state -- )
    state stop-socket-wait
    state key>> [ remove-completion-action ] when*
    state socket>> handle>> f 0 WSAEventSelect socket-error
    state event>> [ WSACloseEvent win32-error=0/f ] when*
    ERROR_OPERATION_ABORTED state wake-socket-waiters ;

DEFER: arm-socket-wait

:: socket-event-error ( events bit -- error/f )
    bit events iErrorCode>> nth dup zero? [ drop f ] when ;

:: dispatch-socket-events ( state -- )
    state stop-socket-wait
    WSANETWORKEVENTS new :> events
    state socket>> handle>> state event>> events WSAEnumNetworkEvents
    SOCKET_ERROR = [ WSAGetLastError state wake-socket-waiters ] [
        events lNetworkEvents>> :> mask
        mask FD_CLOSE mask? [ state t >>closed drop ] when
        state waiters>> >alist [| pair |
            pair first2 :> ( thread event )
            event +input+ = FD_READ FD_WRITE ? :> flag
            state closed>> mask flag mask? or [
                events FD_CLOSE_BIT socket-event-error
                [
                    events event +input+ = FD_READ_BIT FD_WRITE_BIT ?
                    socket-event-error
                ] unless*
                thread resume-with
                thread state waiters>> delete-at
            ] when
        ] each
        state arm-socket-wait
    ] if ;

:: arm-socket-wait ( state -- )
    state wait>> not state waiters>> assoc-empty? not and [
        state event>> master-completion-port get-global state key>>
        register-handle-wait dup win32-error=0/f state wait<<
    ] when ;

:: <socket-readiness> ( socket -- state )
    [
        socket-readiness new-disposable socket >>socket
        H{ } clone >>waiters |dispose :> state
        WSACreateEvent dup win32-error=0/f state event<<
        socket handle>> state event>> flags{ FD_READ FD_WRITE FD_CLOSE }
        WSAEventSelect socket-error
        [ state dispatch-socket-events ] add-completion-action state key<<
        state
    ] with-destructors ;

:: socket-readiness-for ( socket -- state )
    socket check-disposed drop
    socket readiness>> [
        socket <socket-readiness> dup socket readiness<<
    ] unless* ;

M:: win32-socket wait-for-socket-event ( socket event -- )
    socket socket-readiness-for :> state
    ! SSL can request another write after partial progress while still writable.
    ! A zero-time check also covers readiness recorded before wait registration.
    1 socket handle>> event select-sets timeval new select
    dup socket-error 0 > state closed>> or [ yield ] [
        event self state waiters>> set-at
        [
            state arm-socket-wait
            "socket readiness" suspend [ throw-windows-error ] when*
        ] [
            self state waiters>> delete-at
            state waiters>> assoc-empty? [ state stop-socket-wait ] when
        ] finally
    ] if ;

M: win32-socket cancel-operation
    [ dup readiness>> [ dispose f >>readiness ] when* drop ]
    [ call-next-method ] bi ;

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
        dup handle>> listen-backlog listen socket-error
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
    stdcall alien-indirect winsock-error=0/f ; inline

: update-connect-context ( ConnectEx -- )
    s>> SOL_SOCKET SO_UPDATE_CONNECT_CONTEXT f 0 setsockopt socket-error ;

M: object establish-connection
    make-sockaddr/size-outgoing <ConnectEx-args>
        swap >>port
        dup port>> handle>> handle>> >>s
        dup s>> get-ConnectEx-ptr >>ptr
        dup call-ConnectEx
        [ wait-for-socket drop ] [ update-connect-context ] bi ;

TUPLE: AcceptEx-args port family
    sListenSocket sAcceptSocket lpOutputBuffer dwReceiveDataLength
    dwLocalAddressLength dwRemoteAddressLength lpdwBytesReceived lpOverlapped ;

: init-accept-buffer ( addr AcceptEx -- )
    over protocol-family >>family
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
    } cleave AcceptEx winsock-error=0/f ; inline

:: update-accept-context ( args -- )
    args sAcceptSocket>> SOL_SOCKET SO_UPDATE_ACCEPT_CONTEXT
    args sListenSocket>> SOCKET <ref> SOCKET heap-size
    setsockopt socket-error ;

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
    ] [ family>> ] bi
    ! The AcceptEx output buffer is freed when (accept) returns.
    sockaddr-of-family clone ; inline

M: object (accept)
    [
        <AcceptEx-args>
        {
            [ call-AcceptEx ]
            [ wait-for-socket drop ]
            [ update-accept-context ]
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
        f >>lpNumberOfBytesSent
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
