! Copyright (C) 2004, 2007 Mackenzie Straight, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types assocs byte-arrays
bit-arrays combinators continuations init io io.backend
io.buffers io.files io.nonblocking io.sockets io.sockets.impl
io.streams.duplex io.windows libc kernel math namespaces
sequences strings sbufs threads vectors prettyprint splitting
windows windows.nt windows.kernel32 windows.errors qualified ;
QUALIFIED: windows.winsock
IN: io.windows.nt

SYMBOL: io-hash
TUPLE: io-callback port overlapped continuation ;
C: <io-callback> io-callback

: unicode-prefix ( -- seq )
    "\\\\?\\" ; inline
 
M: windows-nt-io normalize-pathname ( string -- string )
    dup string? [ "pathname must be a string" throw ] unless
    "/" split "\\" join
    {
        ! empty
        { [ dup empty? ] [ "empty path" throw ] }
        ! .\\foo
        { [ dup ".\\" head? ] [
            >r unicode-prefix cwd r> 1 tail 3append
        ] }
        ! c:\\
        { [ dup 1 tail ":" head? ] [ >r unicode-prefix r> append ] }
        ! \\\\?\\c:\\foo
        { [ dup unicode-prefix head? ] [ ] }
        ! foo.txt ..\\foo.txt
        { [ t ] [
            [
                unicode-prefix % cwd %
                dup first CHAR: \\ = [ CHAR: \\ , ] unless %
            ] "" make
        ] }
    } cond ;

M: windows-nt-io CreateFile-flags ( -- DWORD )
    FILE_FLAG_OVERLAPPED ;

: (make-overlapped) ( -- overlapped-ext )
    "OVERLAPPED" malloc-object
    0 over set-OVERLAPPED-internal
    0 over set-OVERLAPPED-internal-high
    0 over set-OVERLAPPED-offset-high
    0 over set-OVERLAPPED-offset
    f over set-OVERLAPPED-event ;

: make-overlapped ( port -- overlapped-ext )
    >r (make-overlapped) r>
    port-handle win32-file-ptr [ over set-OVERLAPPED-offset ] when* ;

M: windows-nt-io FileArgs-overlapped ( port -- overlapped )
    make-overlapped ;

: completion-port ( -- alien )
    INVALID_HANDLE_VALUE f f 1 CreateIoCompletionPort
    dup [ win32-error-string throw ] unless ;

M: windows-nt-io add-completion ( handle -- error/f )
    \ completion-port get-global
    f 1 CreateIoCompletionPort
    [ f ] [ win32-error-string ] if ;

: (postpone-overlapped-error) ( port overlapped -- ? )
    GetLastError dup expected-io-error? [
        3drop t
    ] [
        swap free {
            { [ dup ERROR_HANDLE_EOF = ]
                [ drop t swap set-port-eof? f ] }
            { [ t ] [ (win32-error-string) swap set-port-error f ] }
        } cond
    ] if ;
    
: postpone-overlapped-error ( port overlapped ret -- ? )
    #! return f if error
    zero? [ (postpone-overlapped-error) ] [ 2drop t ] if ;

: get-overlapped-result ( port overlapped -- n ret )
    #! n is number of bytes written/read
    #! ret = 0 is an error
    >r port-handle win32-file-handle r> 0 <int> 0
    [ GetOverlappedResult ] 2keep drop *int swap ;

: overlapped-error ( port overlapped -- )
    get-overlapped-result nip zero?  [
        GetLastError dup expected-io-error? [
            (win32-error-string) throw
        ] [
            drop
        ] if
    ] when ;

: maybe-expire ( overlapped io-callbck -- )
    io-callback-port
    dup timeout? [
        ! NOTE: check this, but how?
        port-handle win32-file-handle CancelIo drop
        [ io-hash get-global delete-at ] keep free
    ] [
        2drop
    ] if ;

: cancel-timedout ( -- )
    io-hash get-global [ maybe-expire ] assoc-each ;

: save-callback ( io-callback -- )
    dup io-callback-overlapped \ io-hash get-global set-at ;

: get-io-callback ( overlapped -- callback )
    \ io-hash get-global [ at ] 2keep delete-at ; 

: overlapped>continuation ( overlapped -- continuation )
    [ get-io-callback io-callback-continuation ] [ f ] if* ;

: (wait-for-io) ( timeout -- overlapped int )
    >r \ completion-port get-global 0 <int> 0 <int> 0 <int> r>
    over >r GetQueuedCompletionStatus r> swap ;

: wait-for-io ( timeout -- continuation/f )
    (wait-for-io)
    >r *int <alien> r> over \ io-hash get-global at* [
        io-callback-port -rot
        [ postpone-overlapped-error drop ] 2keep drop
        overlapped>continuation
    ] [
        3drop f
    ] if ;

M: windows-nt-io io-multiplex ( ms -- )
    cancel-timedout
    dup -1 = [ drop INFINITE ] when wait-for-io
    [ schedule-thread ] when* ;

: update-file-ptr ( n port -- )
    port-handle
    dup win32-file-ptr [
        [ win32-file-ptr + ] keep set-win32-file-ptr
    ] [
        2drop
    ] if ;

: finish-flush ( port overlapped -- )
    2dup get-overlapped-result zero? [
        drop dupd 0 postpone-overlapped-error [ flush-output ] [ drop ] if
    ] [
        >r free r>
        [ over update-file-ptr ] keep
        over delegate [ buffer-consume ] keep
        buffer-length 0 > [
            flush-output
        ] [
            drop
        ] if
    ] if ;

M: windows-nt-io flush-output ( port -- )
    dup touch-port
    dup make-FileArgs setup-write [ WriteFile ] keep
    swap >r 2dup r> postpone-overlapped-error [
        [
            <io-callback> save-callback stop
        ] callcc0 finish-flush
    ] [
        2drop
    ] if ;


: finish-read ( port overlapped -- )
    2dup get-overlapped-result zero? [
        drop dupd 0 postpone-overlapped-error [ (wait-to-read) ] [ drop ] if
    ] [
        >r free r> dup zero? [
                drop t swap set-port-eof?
        ] [
            [ over n>buffer ] keep
            swap update-file-ptr
        ] if
    ] if ;

: ((wait-to-read)) ( port -- )
    dup pending-error
    dup touch-port
    dup make-FileArgs setup-read [ ReadFile ] keep
    swap >r 2dup r>
    postpone-overlapped-error [
        [
            <io-callback> save-callback stop
        ] callcc0 finish-read
    ] [
        2drop
    ] if ;

M: input-port (wait-to-read) ( port -- )
    dup ((wait-to-read)) pending-error ;

M: windows-nt-io WSASocket-flags ( -- DWORD )
    windows.winsock:WSA_FLAG_OVERLAPPED ;

: get-ConnectEx-ptr ( socket -- void* )
    windows.winsock:SIO_GET_EXTENSION_FUNCTION_POINTER
    windows.winsock:WSAID_CONNECTEX
    "GUID" heap-size
    "void*" <c-object>
    [
        "void*" heap-size
        "DWORD" <c-object>
        f
        f
        windows.winsock:WSAIoctl windows.winsock:SOCKET_ERROR = [
            winsock-error-string throw
        ] when
    ] keep *void* ;

TUPLE: ConnectEx port
    ptr s name namelen lpSendBuffer dwSendDataLength
    lpdwBytesSent lpOverlapped ;

: close-connect ( ConnectEx -- )
    dup ConnectEx-port [
        stream-close
    ] [
        ConnectEx-s [
            windows.winsock:closesocket drop
        ] when*
    ] if* ;

: <ConnectEx> ( -- ConnectEx )
    ConnectEx construct-empty ;

: init-connect ( sockaddr sockaddr-name ConnectEx -- )
    >r heap-size r>
    [ set-ConnectEx-namelen ] keep
    [ set-ConnectEx-name ] keep
    f over set-ConnectEx-lpSendBuffer
    0 over set-ConnectEx-dwSendDataLength
    f over set-ConnectEx-lpdwBytesSent
    (make-overlapped) swap set-ConnectEx-lpOverlapped ;

: (ConnectEx) ( ConnectEx -- )
    [ ConnectEx-s ] keep
    [ ConnectEx-name ] keep
    [ ConnectEx-namelen ] keep
    [ ConnectEx-lpSendBuffer ] keep
    [ ConnectEx-dwSendDataLength ] keep
    [ ConnectEx-lpdwBytesSent ] keep
    [ ConnectEx-lpOverlapped ] keep
    ConnectEx-ptr
    "int"
    { "SOCKET" "sockaddr_in*" "int" "PVOID" "DWORD" "LPDWORD" "void*" }
    "stdcall" alien-indirect drop
    winsock-error-string [ throw ] when* ;

: make-connect-continuation ( ConnectEx -- )
    [
        ! ConnectEx continuation
        >r dup ConnectEx-port duplex-stream-out
        swap ConnectEx-lpOverlapped r>
        <io-callback> save-callback stop
    ] callcc0 drop ;

: check-connect-error ( ConnectEx -- )
    dup ConnectEx-port duplex-stream-in swap ConnectEx-lpOverlapped
    overlapped-error ;

: connect-continuation ( duplex-stream ConnectEx -- )
    [ make-connect-continuation ] keep
    check-connect-error ;

M: windows-nt-io (client) ( addrspec -- duplex-stream )
    <ConnectEx> f [
        drop
        ! addrspec ConnectEx
        over make-sockaddr pick init-connect
        over tcp-socket over set-ConnectEx-s
        dup ConnectEx-s add-completion [ throw ] when*
        dup ConnectEx-s get-ConnectEx-ptr over set-ConnectEx-ptr
        2dup ConnectEx-s windows.winsock:INADDR_ANY rot bind-socket [ throw ] when*
        dup (ConnectEx)
        dup ConnectEx-s <win32-socket> dup handle>duplex-stream
        over set-ConnectEx-port
        dup connect-continuation
        dup ConnectEx-port duplex-stream-in pending-error
        dup ConnectEx-port duplex-stream-out pending-error
        t
    ] [
        ! addrspec ConnectEx ?
        ! Multiplexer frees overlapped on error (will change in .91)
        [ dup ConnectEx-lpOverlapped free ] [ dup close-connect ] if
        nip ConnectEx-port
    ] cleanup ;


TUPLE: AcceptEx port
    sListenSocket sAcceptSocket lpOutputBuffer dwReceiveDataLength
    dwLocalAddressLength dwRemoteAddressLength lpdwBytesReceived lpOverlapped ;

: close-accept ( AcceptEx -- )
    AcceptEx-sAcceptSocket [
        windows.winsock:closesocket drop
    ] when* ;

: cleanup-accept ( AcceptEx -- )
    AcceptEx-lpOutputBuffer [
        free
    ] when* ;

: <AcceptEx> ( -- AcceptEx )
    AcceptEx construct-empty ;

: init-accept-buffer ( server-port AcceptEx -- )
    >r server-port-addr sockaddr-type heap-size 16 +
    dup dup 2 * malloc r>
    [ set-AcceptEx-lpOutputBuffer ] keep
    [ set-AcceptEx-dwLocalAddressLength ] keep
    set-AcceptEx-dwRemoteAddressLength ;
    
: init-accept ( server-port AcceptEx -- )
    [ init-accept-buffer ] 2keep
    [ set-AcceptEx-port ] 2keep
    >r port-handle win32-file-handle r> [ set-AcceptEx-sListenSocket ] keep
    dup AcceptEx-port server-port-addr tcp-socket
    over set-AcceptEx-sAcceptSocket
    
    0 over set-AcceptEx-dwReceiveDataLength
    f over set-AcceptEx-lpdwBytesReceived
    (make-overlapped) swap set-AcceptEx-lpOverlapped ;

: (accept) ( AcceptEx -- )
    [ AcceptEx-sListenSocket ] keep
    [ AcceptEx-sAcceptSocket ] keep
    [ AcceptEx-lpOutputBuffer ] keep
    [ AcceptEx-dwReceiveDataLength ] keep
    [ AcceptEx-dwLocalAddressLength ] keep
    [ AcceptEx-dwRemoteAddressLength ] keep
    [ AcceptEx-lpdwBytesReceived ] keep
    AcceptEx-lpOverlapped
    windows.winsock:AcceptEx drop
    winsock-error-string [ throw ] when* ;

: make-accept-continuation ( AcceptEx -- )
    dup AcceptEx-port swap AcceptEx-lpOverlapped
    [
        ! port overlapped continuation
        <io-callback> save-callback stop
    ] callcc0 2drop ;

: check-accept-error ( AcceptEx -- )
    dup AcceptEx-port swap AcceptEx-lpOverlapped
    overlapped-error ;

: extract-remote-host ( AcceptEx -- addrspec )
    [
        [ AcceptEx-lpOutputBuffer ] keep
        [ AcceptEx-dwReceiveDataLength ] keep
        [ AcceptEx-dwLocalAddressLength ] keep
        AcceptEx-dwRemoteAddressLength
        f <void*>
        0 <int>
        f <void*> [
            0 <int> windows.winsock:GetAcceptExSockaddrs
        ] keep *void*
    ] keep AcceptEx-port server-port-addr parse-sockaddr ;

: accept-continuation ( AcceptEx -- client )
    [ make-accept-continuation ] keep
    [ check-accept-error ] keep
    [ extract-remote-host ] keep
    ! addrspec AcceptEx
    [
        AcceptEx-sAcceptSocket
        add-completion [ throw ] when*
    ] keep
    AcceptEx-sAcceptSocket <win32-socket> dup handle>duplex-stream
    <client-stream> ;

M: windows-nt-io accept ( server -- client )
    dup check-server-port
    dup touch-port
    <AcceptEx> f [
        drop
        [ init-accept ] keep
        [ (accept) ] keep
        [ accept-continuation ] keep
        dup AcceptEx-port pending-error
        over duplex-stream-in pending-error
        over duplex-stream-out pending-error
        t
    ] [
        ! Multiplexer frees overlapped on error (will change in .91)
        [ dup AcceptEx-lpOverlapped free ] [ dup close-accept ] if
        cleanup-accept
    ] cleanup ;

M: windows-nt-io <server> ( addrspec -- server )
    [
        windows.winsock:SOCK_STREAM server-fd dup listen-on-socket
        dup add-completion [ throw ] when*
        <win32-socket> f <port>
    ] keep <server-port> ;

M: windows-nt-io <datagram> ( addrspec -- datagram )
    [
        windows.winsock:SOCK_DGRAM server-fd
        dup add-completion [ throw ] when*
        <win32-socket> f <port>
    ] keep <datagram-port> ;

: datagram-io-error ( n -- )
    windows.winsock:SOCKET_ERROR = [
        windows.winsock:WSAGetLastError
        dup windows.winsock:WSA_IO_PENDING = [
            drop
        ] [
            (winsock-error-string) throw
        ] if
    ] when ;

TUPLE: WSARecvFrom port
       s lpBuffers dwBufferCount lpNumberOfBytesRecvd
       lpFlags lpFrom lpFromLen lpOverlapped lpCompletionRoutine ;

: <WSARecvFrom> ( -- WSARecvFrom )
    WSARecvFrom construct-empty ;

: close-WSARecvFrom ( WSARecvFrom -- )
    WSARecvFrom-s [
        windows.winsock:closesocket drop
    ] when* ;

: cleanup-WSARecvFrom ( WSARecvFrom -- )
    dup WSARecvFrom-lpFrom [ free ] when*
    dup WSARecvFrom-lpFromLen [ free ] when*
    dup WSARecvFrom-lpBuffers [
        dup windows.winsock:WSABUF-buf [ free ] when*
        free
    ] when*
    dup WSARecvFrom-lpFlags [ free ] when*
    WSARecvFrom-lpNumberOfBytesRecvd [ free ] when* ;

: malloc-int ( object -- object )
    "int" heap-size malloc tuck 0 set-alien-signed-4 ; inline

: init-WSARecvFrom ( datagram WSARecvFrom -- )
    [ set-WSARecvFrom-port ] 2keep
    [
        >r delegate port-handle delegate win32-file-handle r>
        set-WSARecvFrom-s
    ] 2keep [
        >r datagram-port-addr sockaddr-type heap-size r>
        2dup >r malloc r> set-WSARecvFrom-lpFrom
        >r malloc-int r> set-WSARecvFrom-lpFromLen
    ] keep
    "WSABUF" malloc-object 2dup swap set-WSARecvFrom-lpBuffers
    default-buffer-size [ malloc ] keep
    pick windows.winsock:set-WSABUF-len
    swap windows.winsock:set-WSABUF-buf
    1 over set-WSARecvFrom-dwBufferCount
    0 malloc-int over set-WSARecvFrom-lpFlags
    0 malloc-int over set-WSARecvFrom-lpNumberOfBytesRecvd
    (make-overlapped) swap set-WSARecvFrom-lpOverlapped ;

: make-WSARecvFrom-continuation ( WSARecvFrom -- )
    [
        >r dup WSARecvFrom-port swap WSARecvFrom-lpOverlapped r>
        <io-callback> save-callback stop
    ] callcc0 drop ;

: call-WSARecvFrom ( WSARecvFrom -- )
    [ WSARecvFrom-s ] keep
    [ WSARecvFrom-lpBuffers ] keep
    [ WSARecvFrom-dwBufferCount ] keep
    [ WSARecvFrom-lpNumberOfBytesRecvd ] keep
    [ WSARecvFrom-lpFlags ] keep
    [ WSARecvFrom-lpFrom ] keep
    [ WSARecvFrom-lpFromLen ] keep
    [ WSARecvFrom-lpOverlapped ] keep
    WSARecvFrom-lpCompletionRoutine
    windows.winsock:WSARecvFrom
    datagram-io-error ;

: WSARecvFrom-continuation ( WSARecvFrom -- )
    [ make-WSARecvFrom-continuation ] keep
    dup WSARecvFrom-port swap WSARecvFrom-lpOverlapped
    overlapped-error ;

: WSARecvFrom-num-transferred ( WSARecvFrom -- n )
    [ WSARecvFrom-s ] keep
    WSARecvFrom-lpOverlapped
    0 <uint>
    0
    0 <uint>
    [ windows.winsock:WSAGetOverlappedResult drop ] 3keep
    2drop *uint ;

: parse-WSARecvFrom ( WSARecvFrom -- packet addrspec )
    [ WSARecvFrom-lpBuffers windows.winsock:WSABUF-buf ] keep
    [
        WSARecvFrom-num-transferred memory>string >byte-array
    ] keep
    [ WSARecvFrom-lpFrom ] keep
    WSARecvFrom-port datagram-port-addr parse-sockaddr ;

M: windows-nt-io receive ( datagram -- packet addrspec )
    dup check-datagram-port
    <WSARecvFrom> f [
        drop
        [ init-WSARecvFrom ] keep
        [ call-WSARecvFrom ] keep
        [ WSARecvFrom-continuation ] keep
        [ parse-WSARecvFrom ] keep
        t
    ] [
        [ dup close-WSARecvFrom dup WSARecvFrom-lpOverlapped free ] unless
        cleanup-WSARecvFrom
    ] cleanup ;

TUPLE: WSASendTo port
       s lpBuffers dwBufferCount lpNumberOfBytesSent
       dwFlags lpTo iToLen lpOverlapped lpCompletionRoutine ;

: <WSASendTo> ( -- WSASendTo )
    WSASendTo construct-empty ;

: close-WSASendTo ( WSASendTo -- )
    WSASendTo-s [
        windows.winsock:closesocket drop
    ] when* ;

: cleanup-WSASendTo ( WSASendTo -- )
    dup WSASendTo-lpBuffers [
        dup windows.winsock:WSABUF-buf [ free ] when*
        free
    ] when*
    WSASendTo-lpTo [ free ] when* ;

: init-WSASendTo ( packet addrspec datagram WSASendTo -- )
    [ set-WSASendTo-port ] 2keep
    [
        >r delegate port-handle delegate win32-file-handle r>
        set-WSASendTo-s
    ] keep [
        >r make-sockaddr >r malloc-byte-array r> heap-size r>
        [ set-WSASendTo-iToLen ] keep
        set-WSASendTo-lpTo
    ] keep [
        "WSABUF" malloc-object dup rot set-WSASendTo-lpBuffers
        swap [ malloc-byte-array ] keep length
        rot [ windows.winsock:set-WSABUF-len ] keep
        windows.winsock:set-WSABUF-buf
    ] keep
    1 over set-WSASendTo-dwBufferCount
    0 over set-WSASendTo-dwFlags
    (make-overlapped) swap set-WSASendTo-lpOverlapped ;

: make-WSASendTo-continuation ( WSASendTo -- )
    [
        >r dup WSASendTo-port swap WSASendTo-lpOverlapped r>
        <io-callback> save-callback stop
    ] callcc0 drop ;

: WSASendTo-continuation ( WSASendTo -- )
    [ make-WSASendTo-continuation ] keep
    dup WSASendTo-port swap WSASendTo-lpOverlapped
    overlapped-error ;

: call-WSASendTo ( WSASendTo -- )
    [ WSASendTo-s ] keep
    [ WSASendTo-lpBuffers ] keep
    [ WSASendTo-dwBufferCount ] keep
    [ WSASendTo-lpNumberOfBytesSent ] keep
    [ WSASendTo-dwFlags ] keep
    [ WSASendTo-lpTo ] keep
    [ WSASendTo-iToLen ] keep
    [ WSASendTo-lpOverlapped ] keep
    WSASendTo-lpCompletionRoutine
    windows.winsock:WSASendTo
    datagram-io-error ;
 
M: windows-nt-io send ( packet addrspec datagram -- )
    3dup check-datagram-send
    <WSASendTo> f [
        drop
        [ init-WSASendTo ] keep
        [ call-WSASendTo ] keep
        [ WSASendTo-continuation ] keep
        t
    ] [
        [ dup close-WSASendTo dup WSASendTo-lpOverlapped free ] unless
        cleanup-WSASendTo
    ] cleanup ;

T{ windows-nt-io } io-backend set-global

M: windows-nt-io init-io ( -- )
    #! Should only be called on startup. Calling this at any
    #! other time can have unintended consequences.
    global [
        completion-port \ completion-port set
        H{ } clone \ io-hash set
        init-winsock
    ] bind ;

