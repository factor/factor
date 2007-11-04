USING: alien alien.c-types combinators
io io.backend io.buffers io.files io.nonblocking io.sockets
io.sockets.impl io.windows kernel libc math namespaces
prettyprint qualified sequences strings threads threads.private
windows windows.kernel32 ;
QUALIFIED: windows.winsock
IN: io.windows.ce

! M: windows-ce-io normalize-pathname ( string -- string )
    ! dup 1 tail* CHAR: \\ = [ "*" append ] [ "\\*" append ] if ;

M: windows-ce-io CreateFile-flags ( -- DWORD ) FILE_ATTRIBUTE_NORMAL ;
M: windows-ce-io FileArgs-overlapped ( port -- f ) drop f ;
M: windows-ce-io io-multiplex ( ms -- ) (sleep) ;
M: windows-ce-io add-completion ( port -- ? ) drop f ;

: port-errored ( port -- )
    win32-error-string swap set-port-error ;

GENERIC: wince-read ( port port-handle -- )

M: win32-file wince-read
    drop dup make-FileArgs dup setup-read ReadFile zero? [
        drop port-errored
    ] [
        FileArgs-lpNumberOfBytesRet *uint dup zero? [
            drop
            t swap set-port-eof?
        ] [
            swap n>buffer
        ] if
    ] if ;

TUPLE: WSAArgs
    s
    lpBuffers
    dwBufferCount
    lpNumberOfBytesRet
    lpFlags
    lpOverlapped
    lpCompletionRoutine ;
C: <WSAArgs> WSAArgs

: make-WSAArgs ( port -- <WSARecv> )
    [ port-handle win32-file-handle ] keep
    delegate 1 "DWORD" <c-object> f f f <WSAArgs> ;

: setup-WSARecv ( <WSAArgs> -- s lpBuffers dwBufferCount lpNumberOfBytesRet lpFlags lpOverlapped lpCompletionRoutine )
    [ WSAArgs-s ] keep
    [
        WSAArgs-lpBuffers [ buffer-capacity ] keep
        buffer-end
        "WSABUF" <c-object>
        [ windows.winsock:set-WSABUF-buf ] keep
        [ windows.winsock:set-WSABUF-len ] keep
    ] keep
    [ WSAArgs-dwBufferCount ] keep
    [ WSAArgs-lpNumberOfBytesRet ] keep
    [ WSAArgs-lpFlags ] keep
    [ WSAArgs-lpOverlapped ] keep
    WSAArgs-lpCompletionRoutine ;

! M: win32-socket wince-read ( port port-handle -- )
    ! drop dup make-WSAArgs dup setup-WSARecv WSARecv zero? [
        ! drop port-errored
    ! ] [
        ! WSAArgs-lpNumberOfBytesRet *uint dup zero? [
            ! drop
            ! t swap set-port-eof?
        ! ] [
            ! swap n>buffer
        ! ] if
    ! ] if ;

M: win32-socket wince-read ( port port-handle -- )
    win32-file-handle over
    delegate [ buffer-end ] keep buffer-capacity 0
    windows.winsock:recv dup windows.winsock:SOCKET_ERROR = [
        drop port-errored
    ] [
        dup zero? [
            drop
            t swap set-port-eof?
        ] [
            swap n>buffer
        ] if
    ] if ;

M: input-port (wait-to-read) ( port -- )
    dup port-handle wince-read ;

GENERIC: wince-write ( port port-handle -- )

M: win32-file wince-write ( port port-handle -- )
    drop dup make-FileArgs dup setup-write WriteFile zero? [
        drop port-errored
    ] [
        FileArgs-lpNumberOfBytesRet *uint ! *DWORD
        over delegate [ buffer-consume ] keep
        buffer-length 0 > [
            flush-output
        ] [
            drop
        ] if
    ] if ;

: setup-WSASend ( <WSAArgs> -- s lpBuffers dwBufferCount lpNumberOfBytesRet lpFlags lpOverlapped lpCompletionRoutine )
    [ WSAArgs-s ] keep
    [
        WSAArgs-lpBuffers [ buffer-length ] keep
        buffer@
        "WSABUF" <c-object>
        [ windows.winsock:set-WSABUF-buf ] keep
        [ windows.winsock:set-WSABUF-len ] keep
    ] keep
    [ WSAArgs-dwBufferCount ] keep
    [ WSAArgs-lpNumberOfBytesRet ] keep
    [ WSAArgs-lpFlags ] keep
    [ WSAArgs-lpOverlapped ] keep
    WSAArgs-lpCompletionRoutine ;

! M: win32-socket wince-write ( port port-handle -- )
    ! drop dup make-WSAArgs dup setup-WSASend WSASend zero? [
        ! drop port-errored
    ! ] [
        ! FileArgs-lpNumberOfBytesRet *uint ! *DWORD
        ! over delegate [ buffer-consume ] keep
        ! buffer-length 0 > [
            ! flush-output
        ! ] [
            ! drop
        ! ] if
    ! ] if ;

M: win32-socket wince-write ( port port-handle -- )
    win32-file-handle over
    delegate [ buffer@ ] keep
    buffer-length 0 windows.winsock:send dup windows.winsock:SOCKET_ERROR = [
        drop port-errored
    ] [
        over delegate [ buffer-consume ] keep
        buffer-length 0 > [
            flush-output
        ] [
            drop
        ] if
    ] if ;

M: windows-ce-io flush-output ( port -- )
    dup port-handle wince-write ;

M: windows-ce-io WSASocket-flags ( -- DWORD ) 0 ;

: do-connect ( addrspec -- socket )
    [ tcp-socket dup ] keep
    make-sockaddr/size
    f f f f windows.winsock:WSAConnect zero? [
        winsock-error-string throw
    ] unless ;

M: windows-ce-io (client) ( addrspec -- duplex-stream )
    do-connect <win32-socket> dup handle>duplex-stream ;

M: windows-ce-io <server> ( addrspec -- duplex-stream )
    [
        windows.winsock:SOCK_STREAM server-fd
        dup listen-on-socket
        <win32-socket> f <port>
    ] keep <server-port> ;

M: windows-ce-io accept ( server -- client )
    dup check-server-port
    [
        [ touch-port ] keep
        [ port-handle win32-file-handle ] keep
        server-port-addr sockaddr-type heap-size
        [ "char" <c-array> ] keep [
            <int>
            f 0
            windows.winsock:WSAAccept dup windows.winsock:INVALID_SOCKET = [
                winsock-error-string throw
            ] when
        ] keep
    ] keep server-port-addr parse-sockaddr swap
    <win32-socket> dup handle>duplex-stream <client-stream> ;

T{ windows-ce-io } io-backend set-global

M: windows-ce-io init-io ( -- )
    init-winsock ;

M: windows-ce-io <datagram> ( addrspec -- datagram )
    [
        windows.winsock:SOCK_DGRAM server-fd <win32-socket> f <port>
    ] keep <datagram-port> ;

M: windows-ce-io receive ( datagram -- packet addrspec )
    dup check-datagram-port
    [
        port-handle delegate win32-file-handle
        "WSABUF" <c-object>
        default-buffer-size over windows.winsock:set-WSABUF-len
        default-buffer-size "char" <c-array> over windows.winsock:set-WSABUF-buf
        [
            1
            0 <uint> [
                0 <uint>
                64 "char" <c-array> [
                    64 <int>
                    f
                    f
                    windows.winsock:WSARecvFrom zero? [
                        winsock-error-string throw
                    ] unless
                ] keep
            ] keep *uint
        ] keep
    ] keep
    ! sockaddr count buf datagram
    >r windows.winsock:WSABUF-buf swap memory>string swap r>
    datagram-port-addr parse-sockaddr ;

M: windows-ce-io send ( packet addrspec datagram -- )
    3dup check-datagram-send
    delegate port-handle delegate win32-file-handle
    rot dup length "WSABUF" <c-object>
    [ windows.winsock:set-WSABUF-len ] keep
    [ windows.winsock:set-WSABUF-buf ] keep
    
    rot make-sockaddr/size
    >r >r 1 0 <uint> 0 r> r> f f 
    windows.winsock:WSASendTo zero? [
        winsock-error-string throw
    ] unless ;

