USING: alien alien.accessors alien.c-types byte-arrays
continuations destructors io.ports io.timeouts io.sockets
io.sockets io namespaces io.streams.duplex io.windows
io.windows.nt.backend windows.winsock kernel libc math sequences
threads classes.tuple.lib system accessors ;
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

: <ConnectEx-args> ( sockaddr size -- )
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

: (wait-to-connect) ( client-out handle -- )
    overlapped>> swap twiddle-thumbs drop ;

: get-socket-name ( socket addrspec -- sockaddr )
    >r handle>> r> empty-sockaddr/size
    [ getsockname socket-error ] 2keep drop ;

M: win32-socket wait-to-connect ( client-out handle remote -- sockaddr )
    [
        [ drop (wait-to-connect) ]
        [ get-socket-name nip ]
        3bi
    ] keep parse-sockaddr ;

M: object ((client)) ( addrspec -- handle )
    dup make-sockaddr/size <ConnectEx-args>
    over tcp-socket >>s*
    dup s*>> add-completion
    dup s*>> get-ConnectEx-ptr >>ptr*
    dup s*>> INADDR_ANY roll bind-socket
    dup call-ConnectEx
    dup [ s*>> ] [ lpOverlapped*>> ] bi <win32-socket> ;

TUPLE: AcceptEx-args port
    sListenSocket* sAcceptSocket* lpOutputBuffer* dwReceiveDataLength*
    dwLocalAddressLength* dwRemoteAddressLength* lpdwBytesReceived* lpOverlapped* ;

: init-accept-buffer ( server-port AcceptEx -- )
    swap addr>> sockaddr-type heap-size 16 +
        [ >>dwLocalAddressLength* ] [ >>dwRemoteAddressLength* ] bi
        dup dwLocalAddressLength*>> 2 * malloc &free >>lpOutputBuffer*
        drop ;

: <AcceptEx-args> ( server-port -- AcceptEx )
    AcceptEx-args new
        2dup init-accept-buffer
        over >>port
        over handle>> handle>> >>sListenSocket*
        over addr>> tcp-socket >>sAcceptSocket*
        0 >>dwReceiveDataLength*
        f >>lpdwBytesReceived*
        (make-overlapped) >>lpOverlapped*
        nip ;

: call-AcceptEx ( AcceptEx -- )
    AcceptEx-args >tuple*<
    AcceptEx drop
    winsock-error-string [ throw ] when* ;

: extract-remote-host ( AcceptEx -- addrspec )
    {
        [ lpOutputBuffer*>> ]
        [ dwReceiveDataLength*>> ]
        [ dwLocalAddressLength*>> ]
        [ dwRemoteAddressLength*>> ]
    } cleave
    f <void*>
    0 <int>
    f <void*> [
        0 <int> GetAcceptExSockaddrs
    ] keep *void* ;

: finish-accept ( AcceptEx -- client sockaddr )
    [ sAcceptSocket*>> add-completion ]
    [ [ sAcceptSocket*>> ] [ lpOverlapped*>> ] bi <win32-socket> ]
    [ extract-remote-host ]
    tri ;

: wait-to-accept ( AcceptEx -- )
    [ lpOverlapped*>> ] [ port>> ] bi twiddle-thumbs drop ;

M: winnt (accept) ( server -- handle sockaddr )
    [
        [
            <AcceptEx-args>
            {
                [ call-AcceptEx ]
                [ wait-to-accept ]
                [ finish-accept ]
                [ port>> pending-error ]
            } cleave
        ] with-timeout
    ] with-destructors ;

M: winnt (server) ( addrspec -- handle sockaddr )
    [
        [ SOCK_STREAM server-fd ] keep
        [
            drop
            [ listen-on-socket ]
            [ add-completion ]
            [ f <win32-socket> ]
            tri
        ]
        [ get-socket-name ]
        2bi
    ] with-destructors ;

M: winnt (datagram) ( addrspec -- handle )
    [
        SOCK_DGRAM server-fd
        dup add-completion
        f <win32-socket>
    ] with-destructors ;

TUPLE: WSARecvFrom-args port
       s* lpBuffers* dwBufferCount* lpNumberOfBytesRecvd*
       lpFlags* lpFrom* lpFromLen* lpOverlapped* lpCompletionRoutine* ;

: make-receive-buffer ( -- WSABUF )
    "WSABUF" malloc-object &free
    default-buffer-size get over set-WSABUF-len
    default-buffer-size get malloc &free over set-WSABUF-buf ;

: <WSARecvFrom-args> ( datagram -- WSARecvFrom )
    WSARecvFrom new
        over >>port
        over handle>> handle>> >>s*
        swap addr>> sockaddr-type heap-size
            [ malloc &free >>lpFrom* ]
            [ malloc-int &free >>lpFromLen* ] bi
        make-receive-buffer >>lpBuffers*
        1 >>dwBufferCount*
        0 malloc-int &free >>lpFlags*
        0 malloc-int &free >>lpNumberOfBytesRecvd*
        (make-overlapped) >>lpOverlapped* ;

: wait-to-receive ( WSARecvFrom -- n )
    [ lpOverlapped*>> ] [ port>> ] bi twiddle-thumbs ;

: call-WSARecvFrom ( WSARecvFrom -- )
    WSARecvFrom-args >tuple*< WSARecvFrom socket-error* ;

: parse-WSARecvFrom ( n WSARecvFrom -- packet sockaddr )
    [ lpBuffers*>> WSABUF-buf swap memory>byte-array ]
    [ lpFrom*>> ]
    bi ;

M: winnt receive ( datagram -- packet addrspec )
    [
        <WSARecvFrom-args>
        {
            [ call-WSARecvFrom ]
            [ wait-to-receive ]
            [ port>> pending-error ]
            [ parse-WSARecvFrom ]
        } cleave
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
        over >>port
        over handle>> handle>> >>s*
        swap make-sockaddr/size
            >r malloc-byte-array &free
            r> [ >>lpTo* ] [ >>iToLen* ] bi*
        swap make-send-buffer >>lpBuffers*
        1 >>dwBufferCount*
        0 >>dwFlags*
        0 <uint> >>lpNumberOfBytesSent*
        (make-overlapped) >>lpOverlapped* ;

: wait-to-send ( WSASendTo -- )
    [ lpOverlapped*>> ] [ port>> ] bi twiddle-thumbs drop ;

: call-WSASendTo ( WSASendTo -- )
    WSASendTo-args >tuple*< WSASendTo socket-error* ;

USE: io.sockets

M: winnt send ( packet addrspec datagram -- )
    [
        <WSASendTo-args>
        [ call-WSASendTo ]
        [ wait-to-send ]
        [ port>> pending-error ]
        tri
    ] with-destructors ;
