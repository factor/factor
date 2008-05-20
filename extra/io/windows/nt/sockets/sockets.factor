USING: alien alien.accessors alien.c-types byte-arrays
continuations destructors io.ports io.timeouts io.sockets
io.sockets io namespaces io.streams.duplex io.windows
io.windows.sockets
io.windows.nt.backend windows.winsock kernel libc math sequences
threads classes.tuple.lib system combinators accessors ;
IN: io.windows.nt.sockets

: malloc-int ( object -- object )
    "int" heap-size malloc tuck 0 set-alien-signed-4 ; inline

M: winnt WSASocket-flags ( -- DWORD )
    WSA_FLAG_OVERLAPPED ;

: get-ConnectEx-ptr ( socket -- void* )
    SIO_GET_EXTENSION_FUNCTION_POINTER
    WSAID_CONNECTEX
    "GUID" heap-size
    "void*" <c-object>
    [
        "void*" heap-size
        "DWORD" <c-object>
        f
        f
        WSAIoctl SOCKET_ERROR = [
            winsock-error-string throw
        ] when
    ] keep *void* ;

TUPLE: ConnectEx-args port
    s* name* namelen* lpSendBuffer* dwSendDataLength*
    lpdwBytesSent* lpOverlapped* ptr* ;

: wait-for-socket ( args -- n )
    [ lpOverlapped*>> ] [ port>> ] bi twiddle-thumbs ;

: <ConnectEx-args> ( sockaddr size -- ConnectEx )
    ConnectEx-args new
        swap >>namelen*
        swap >>name*
        f >>lpSendBuffer*
        0 >>dwSendDataLength*
        f >>lpdwBytesSent*
        (make-overlapped) >>lpOverlapped* ;

: call-ConnectEx ( ConnectEx -- )
    ConnectEx-args >tuple*<
    "int"
    { "SOCKET" "sockaddr_in*" "int" "PVOID" "DWORD" "LPDWORD" "void*" }
    "stdcall" alien-indirect drop
    winsock-error-string [ throw ] when* ;

M: object establish-connection ( client-out remote -- )
    make-sockaddr/size <ConnectEx-args>
        swap >>port
        dup port>> handle>> handle>> >>s*
        dup s*>> get-ConnectEx-ptr >>ptr*
        dup call-ConnectEx
        wait-for-socket drop ;

TUPLE: AcceptEx-args port
    sListenSocket* sAcceptSocket* lpOutputBuffer* dwReceiveDataLength*
    dwLocalAddressLength* dwRemoteAddressLength* lpdwBytesReceived* lpOverlapped* ;

: init-accept-buffer ( addr AcceptEx -- )
    swap sockaddr-type heap-size 16 +
        [ >>dwLocalAddressLength* ] [ >>dwRemoteAddressLength* ] bi
        dup dwLocalAddressLength*>> 2 * malloc &free >>lpOutputBuffer*
        drop ;

: <AcceptEx-args> ( server addr -- AcceptEx )
    AcceptEx-args new
        2dup init-accept-buffer
        swap SOCK_STREAM open-socket |dispose handle>> >>sAcceptSocket*
        over handle>> handle>> >>sListenSocket*
        swap >>port
        0 >>dwReceiveDataLength*
        f >>lpdwBytesReceived*
        (make-overlapped) >>lpOverlapped* ;

: call-AcceptEx ( AcceptEx -- )
    AcceptEx-args >tuple*< AcceptEx drop
    winsock-error-string [ throw ] when* ;

: extract-remote-address ( AcceptEx -- sockaddr )
    {
        [ lpOutputBuffer*>> ]
        [ dwReceiveDataLength*>> ]
        [ dwLocalAddressLength*>> ]
        [ dwRemoteAddressLength*>> ]
    } cleave
    f <void*>
    0 <int>
    f <void*>
    [ 0 <int> GetAcceptExSockaddrs ] keep *void* ;

M: object (accept) ( server addr -- handle sockaddr )
    [
        <AcceptEx-args>
        {
            [ call-AcceptEx ]
            [ wait-for-socket drop ]
            [ sAcceptSocket*>> <win32-socket> ]
            [ extract-remote-address ]
        } cleave
    ] with-destructors ;

TUPLE: WSARecvFrom-args port
       s* lpBuffers* dwBufferCount* lpNumberOfBytesRecvd*
       lpFlags* lpFrom* lpFromLen* lpOverlapped* lpCompletionRoutine* ;

: make-receive-buffer ( -- WSABUF )
    "WSABUF" malloc-object &free
    default-buffer-size get over set-WSABUF-len
    default-buffer-size get malloc &free over set-WSABUF-buf ;

: <WSARecvFrom-args> ( datagram -- WSARecvFrom )
    WSARecvFrom-args new
        swap >>port
        dup port>> handle>> handle>> >>s*
        dup port>> addr>> sockaddr-type heap-size
            [ malloc &free >>lpFrom* ]
            [ malloc-int &free >>lpFromLen* ] bi
        make-receive-buffer >>lpBuffers*
        1 >>dwBufferCount*
        0 malloc-int &free >>lpFlags*
        0 malloc-int &free >>lpNumberOfBytesRecvd*
        (make-overlapped) >>lpOverlapped* ;

: call-WSARecvFrom ( WSARecvFrom -- )
    WSARecvFrom-args >tuple*< WSARecvFrom socket-error* ;

: parse-WSARecvFrom ( n WSARecvFrom -- packet sockaddr )
    [ lpBuffers*>> WSABUF-buf swap memory>byte-array ]
    [ [ lpFrom*>> ] [ lpFromLen*>> *int ] bi memory>byte-array ] bi ;

M: winnt (receive) ( datagram -- packet addrspec )
    [
        <WSARecvFrom-args>
        [ call-WSARecvFrom ]
        [ wait-for-socket ]
        [ parse-WSARecvFrom ]
        tri
    ] with-destructors ;

TUPLE: WSASendTo-args port
       s* lpBuffers* dwBufferCount* lpNumberOfBytesSent*
       dwFlags* lpTo* iToLen* lpOverlapped* lpCompletionRoutine* ;

: make-send-buffer ( packet -- WSABUF )
    "WSABUF" malloc-object &free
    [ >r malloc-byte-array &free r> set-WSABUF-buf ]
    [ >r length r> set-WSABUF-len ]
    [ nip ]
    2tri ;

: <WSASendTo-args> ( packet addrspec datagram -- WSASendTo )
    WSASendTo-args new
        swap >>port
        dup port>> handle>> handle>> >>s*
        swap make-sockaddr/size
            >r malloc-byte-array &free
            r> [ >>lpTo* ] [ >>iToLen* ] bi*
        swap make-send-buffer >>lpBuffers*
        1 >>dwBufferCount*
        0 >>dwFlags*
        0 <uint> >>lpNumberOfBytesSent*
        (make-overlapped) >>lpOverlapped* ;

: call-WSASendTo ( WSASendTo -- )
    WSASendTo-args >tuple*< WSASendTo socket-error* ;

M: winnt (send) ( packet addrspec datagram -- )
    [
        <WSASendTo-args>
        [ call-WSASendTo ]
        [ wait-for-socket drop ]
        bi
    ] with-destructors ;
