USING: alien alien.accessors alien.c-types alien.data byte-arrays
continuations destructors io.ports io.timeouts io.sockets
io.sockets.private io namespaces io.streams.duplex
io.backend.windows io.sockets.windows io.backend.windows.nt
windows.winsock kernel libc math sequences threads system
combinators accessors classes.struct windows.kernel32
windows.types ;
IN: io.sockets.windows.nt

: malloc-int ( n -- alien )
    <int> malloc-byte-array ; inline

M: winnt WSASocket-flags ( -- DWORD )
    WSA_FLAG_OVERLAPPED ;

: get-ConnectEx-ptr ( socket -- void* )
    SIO_GET_EXTENSION_FUNCTION_POINTER
    WSAID_CONNECTEX
    GUID heap-size
    void* <c-object>
    [
        void* heap-size
        DWORD <c-object>
        f
        f
        WSAIoctl SOCKET_ERROR = [
            winsock-error-string throw
        ] when
    ] keep *void* ;

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
    "int"
    { "SOCKET" "sockaddr_in*" "int" "PVOID" "DWORD" "LPDWORD" "void*" }
    "stdcall" alien-indirect drop
    winsock-error-string [ throw ] when* ; inline

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
    } cleave AcceptEx drop
    winsock-error-string [ throw ] when* ; inline

: (extract-remote-address) ( lpOutputBuffer dwReceiveDataLength dwLocalAddressLength dwRemoteAddressLength -- sockaddr )
    f <void*> 0 <int> f <void*> [ 0 <int> GetAcceptExSockaddrs ] keep *void* ;

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
        [ lpFromLen>> *int ]
        tri memcpy
    ] bi ; inline

M: winnt (receive) ( datagram -- packet addrspec )
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
        0 <uint> >>lpNumberOfBytesSent
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

M: winnt (send) ( packet addrspec datagram -- )
    [
        <WSASendTo-args>
        [ call-WSASendTo ]
        [ wait-for-socket drop ]
        bi
    ] with-destructors ;
