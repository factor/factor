USING: alien alien.c-types byte-arrays continuations destructors
io.nonblocking io io.sockets io.sockets.impl
io.streams.duplex io.windows io.windows.nt io.windows.nt.backend
windows.winsock kernel libc math sequences threads tuples.lib ;
IN: io.windows.nt.sockets

: malloc-int ( object -- object )
    "int" heap-size malloc tuck 0 set-alien-signed-4 ; inline

M: windows-nt-io WSASocket-flags ( -- DWORD )
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

: init-connect ( sockaddr size ConnectEx -- )
    [ set-ConnectEx-args-namelen* ] keep
    [ set-ConnectEx-args-name* ] keep
    f over set-ConnectEx-args-lpSendBuffer*
    0 over set-ConnectEx-args-dwSendDataLength*
    f over set-ConnectEx-args-lpdwBytesSent*
    (make-overlapped) swap set-ConnectEx-args-lpOverlapped* ;

: (ConnectEx) ( ConnectEx -- )
    \ ConnectEx-args >tuple*<
    "int"
    { "SOCKET" "sockaddr_in*" "int" "PVOID" "DWORD" "LPDWORD" "void*" }
    "stdcall" alien-indirect drop
    winsock-error-string [ throw ] when* ;

: check-connect-error ( ConnectEx -- )
    ConnectEx-args-port duplex-stream-in get-overlapped-result drop ;

: connect-continuation ( ConnectEx -- )
    [ ConnectEx-args-port duplex-stream-in save-callback ] keep
    check-connect-error ;

M: windows-nt-io (client) ( addrspec -- duplex-stream )
    [
        \ ConnectEx-args construct-empty
        over make-sockaddr/size pick init-connect
        over tcp-socket over set-ConnectEx-args-s*
        dup ConnectEx-args-s* add-completion
        dup ConnectEx-args-s* get-ConnectEx-ptr over set-ConnectEx-args-ptr*
        dup ConnectEx-args-s* INADDR_ANY roll bind-socket
        dup (ConnectEx)

        dup ConnectEx-args-s* <win32-socket> dup handle>duplex-stream
        over set-ConnectEx-args-port

        [
            dup ConnectEx-args-lpOverlapped*
            swap ConnectEx-args-port duplex-stream-in set-port-overlapped
        ] keep
        dup connect-continuation
        ConnectEx-args-port
        [ duplex-stream-in pending-error ] keep
        [ duplex-stream-out pending-error ] keep
    ] with-destructors ;

TUPLE: AcceptEx-args port
    sListenSocket* sAcceptSocket* lpOutputBuffer* dwReceiveDataLength*
    dwLocalAddressLength* dwRemoteAddressLength* lpdwBytesReceived* lpOverlapped* ;

: init-accept-buffer ( server-port AcceptEx -- )
    >r server-port-addr sockaddr-type heap-size 16 +
    dup dup 2 * malloc dup free-always r>
    [ set-AcceptEx-args-lpOutputBuffer* ] keep
    [ set-AcceptEx-args-dwLocalAddressLength* ] keep
    set-AcceptEx-args-dwRemoteAddressLength* ;

: init-accept ( server-port AcceptEx -- )
    [ init-accept-buffer ] 2keep
    [ set-AcceptEx-args-port ] 2keep
    >r port-handle win32-file-handle r> [ set-AcceptEx-args-sListenSocket* ] keep
    dup AcceptEx-args-port server-port-addr tcp-socket
    over set-AcceptEx-args-sAcceptSocket*
    0 over set-AcceptEx-args-dwReceiveDataLength*
    f over set-AcceptEx-args-lpdwBytesReceived*
    (make-overlapped) over set-AcceptEx-args-lpOverlapped*
    dup AcceptEx-args-lpOverlapped* swap AcceptEx-args-port set-port-overlapped ;

: (accept) ( AcceptEx -- )
    \ AcceptEx-args >tuple*<
    AcceptEx drop
    winsock-error-string [ throw ] when* ;

: make-accept-continuation ( AcceptEx -- )
    AcceptEx-args-port save-callback ;

: check-accept-error ( AcceptEx -- )
    AcceptEx-args-port get-overlapped-result drop ;

: extract-remote-host ( AcceptEx -- addrspec )
    [
        [ AcceptEx-args-lpOutputBuffer* ] keep
        [ AcceptEx-args-dwReceiveDataLength* ] keep
        [ AcceptEx-args-dwLocalAddressLength* ] keep
        AcceptEx-args-dwRemoteAddressLength*
        f <void*>
        0 <int>
        f <void*> [
            0 <int> GetAcceptExSockaddrs
        ] keep *void*
    ] keep AcceptEx-args-port server-port-addr parse-sockaddr ;

: accept-continuation ( AcceptEx -- client )
    [ make-accept-continuation ] keep
    [ check-accept-error ] keep
    [ extract-remote-host ] keep
    ! addrspec AcceptEx
    [
        AcceptEx-args-sAcceptSocket* add-completion
    ] keep
    AcceptEx-args-sAcceptSocket* <win32-socket> dup handle>duplex-stream
    <client-stream> ;

M: windows-nt-io accept ( server -- client )
    [
        dup check-server-port
        dup touch-port
        \ AcceptEx-args construct-empty
        [ init-accept ] keep
        [ (accept) ] keep
        [ accept-continuation ] keep
        AcceptEx-args-port pending-error
        dup duplex-stream-in pending-error
        dup duplex-stream-out pending-error
    ] with-destructors ;

M: windows-nt-io <server> ( addrspec -- server )
    [
        [
            SOCK_STREAM server-fd dup listen-on-socket
            dup add-completion
            <win32-socket> f <port>
        ] keep <server-port>
    ] with-destructors ;

M: windows-nt-io <datagram> ( addrspec -- datagram )
    [
        [
            SOCK_DGRAM server-fd
            dup add-completion
            <win32-socket> f <port>
        ] keep <datagram-port>
    ] with-destructors ;

TUPLE: WSARecvFrom-args port
       s* lpBuffers* dwBufferCount* lpNumberOfBytesRecvd*
       lpFlags* lpFrom* lpFromLen* lpOverlapped* lpCompletionRoutine* ;

: init-WSARecvFrom ( datagram WSARecvFrom -- )
    [ set-WSARecvFrom-args-port ] 2keep
    [
        >r delegate port-handle delegate win32-file-handle r>
        set-WSARecvFrom-args-s*
    ] 2keep [
        >r datagram-port-addr sockaddr-type heap-size r>
        2dup >r malloc dup free-always r> set-WSARecvFrom-args-lpFrom*
        >r malloc-int dup free-always r> set-WSARecvFrom-args-lpFromLen*
    ] keep
    "WSABUF" malloc-object dup free-always
    2dup swap set-WSARecvFrom-args-lpBuffers*
    default-buffer-size get [ malloc dup free-always ] keep
    pick set-WSABUF-len
    swap set-WSABUF-buf
    1 over set-WSARecvFrom-args-dwBufferCount*
    0 malloc-int dup free-always over set-WSARecvFrom-args-lpFlags*
    0 malloc-int dup free-always over set-WSARecvFrom-args-lpNumberOfBytesRecvd*
    (make-overlapped) [ over set-WSARecvFrom-args-lpOverlapped* ] keep
    swap WSARecvFrom-args-port set-port-overlapped ;

: make-WSARecvFrom-continuation ( WSARecvFrom -- )
    WSARecvFrom-args-port save-callback ;

: call-WSARecvFrom ( WSARecvFrom -- )
    \ WSARecvFrom-args >tuple*<
    WSARecvFrom
    socket-error* ;

: WSARecvFrom-continuation ( WSARecvFrom -- n )
    [ make-WSARecvFrom-continuation ] keep
    WSARecvFrom-args-port get-overlapped-result ;

: parse-WSARecvFrom ( n WSARecvFrom -- packet addrspec )
    [
        WSARecvFrom-args-lpBuffers* WSABUF-buf
        swap memory>string >byte-array
    ] keep
    [ WSARecvFrom-args-lpFrom* ] keep
    WSARecvFrom-args-port datagram-port-addr parse-sockaddr ;

M: windows-nt-io receive ( datagram -- packet addrspec )
    [
        dup check-datagram-port
        \ WSARecvFrom-args construct-empty
        [ init-WSARecvFrom ] keep
        [ call-WSARecvFrom ] keep
        [ WSARecvFrom-continuation ] keep
        [ WSARecvFrom-args-port pending-error ] keep
        parse-WSARecvFrom
    ] with-destructors ;

TUPLE: WSASendTo-args port
       s* lpBuffers* dwBufferCount* lpNumberOfBytesSent*
       dwFlags* lpTo* iToLen* lpOverlapped* lpCompletionRoutine* ;

: init-WSASendTo ( packet addrspec datagram WSASendTo -- )
    [ set-WSASendTo-args-port ] 2keep
    [
        >r delegate port-handle delegate win32-file-handle r>
        set-WSASendTo-args-s*
    ] keep [
        >r make-sockaddr/size >r
        malloc-byte-array dup free-always
        r> r>
        [ set-WSASendTo-args-iToLen* ] keep
        set-WSASendTo-args-lpTo*
    ] keep [
        "WSABUF" malloc-object dup free-always
        dup rot set-WSASendTo-args-lpBuffers*
        swap [ malloc-byte-array dup free-always ] keep length
        rot [ set-WSABUF-len ] keep
        set-WSABUF-buf
    ] keep
    1 over set-WSASendTo-args-dwBufferCount*
    0 over set-WSASendTo-args-dwFlags*
    (make-overlapped) [ over set-WSASendTo-args-lpOverlapped* ] keep
    swap WSASendTo-args-port set-port-overlapped ;

: make-WSASendTo-continuation ( WSASendTo -- )
    WSASendTo-args-port save-callback ;

: WSASendTo-continuation ( WSASendTo -- )
    [ make-WSASendTo-continuation ] keep
    WSASendTo-args-port get-overlapped-result drop ;

: call-WSASendTo ( WSASendTo -- )
    \ WSASendTo-args >tuple*<
    WSASendTo socket-error* ;

USE: io.sockets

M: windows-nt-io send ( packet addrspec datagram -- )
    [
        3dup check-datagram-send
        \ WSASendTo-args construct-empty
        [ init-WSASendTo ] keep
        [ call-WSASendTo ] keep
        [ WSASendTo-continuation ] keep
        WSASendTo-args-port pending-error
    ] with-destructors ;

