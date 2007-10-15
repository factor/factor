USING: alien alien.c-types arrays destructors io
io.backend io.buffers io.files io.nonblocking io.sockets
io.sockets.impl windows.errors strings io.streams.duplex
kernel math namespaces sequences windows
windows.kernel32 windows.winsock windows.winsock.private ;
USE: prettyprint
IN: io.windows

TUPLE: windows-nt-io ;
TUPLE: windows-ce-io ;
UNION: windows-io windows-nt-io windows-ce-io ;

M: windows-io (handle-destructor) ( obj -- )
    destructor-obj CloseHandle drop ;

M: windows-io (socket-destructor) ( obj -- )
    destructor-obj closesocket drop ;

M: windows-io root-directory? ( path -- ? )
    [ path-separator? ] rtrim
    dup length 2 = [
        dup first Letter?
        swap second CHAR: : = and
    ] [
        drop f
    ] if ;

TUPLE: win32-file handle ptr overlapped ;

: <win32-file>  ( handle ptr -- obj )
    { set-win32-file-handle set-win32-file-ptr }
    \ win32-file construct ;

: set-port-overlapped ( overlapped port -- )
    port-handle set-win32-file-overlapped ;

: port-overlapped ( port -- overlapped )
    port-handle win32-file-overlapped ;

HOOK: CreateFile-flags io-backend ( -- DWORD )
HOOK: flush-output io-backend ( port -- )
HOOK: FileArgs-overlapped io-backend ( port -- overlapped/f )
HOOK: add-completion io-backend ( port -- )

M: windows-io normalize-directory ( string -- string )
    dup peek CHAR: \\ = "*" "\\*" ? append ;

: share-mode ( -- fixnum )
    FILE_SHARE_READ FILE_SHARE_WRITE bitor ; inline

M: win32-file init-handle ( handle -- ) drop ;

! Clean up resources (open handle) if add-completion fails
: open-file ( path access-mode create-mode -- handle )
    [
        >r share-mode f r> CreateFile-flags f CreateFile
        dup invalid-handle? dup close-later
        dup add-completion
    ] with-destructors ;

: open-pipe-r/w ( path -- handle )
    GENERIC_READ GENERIC_WRITE bitor OPEN_EXISTING open-file ;

: open-read ( path -- handle length )
    normalize-pathname GENERIC_READ OPEN_EXISTING open-file 0 ;

: open-write ( path -- handle length )
    normalize-pathname GENERIC_WRITE CREATE_ALWAYS open-file 0 ;

: (open-append) ( path -- handle )
    normalize-pathname GENERIC_WRITE OPEN_ALWAYS open-file ;

: open-append ( path -- handle length )
    dup file-length dup
    [ >r (open-append) r> ] [ drop open-write ] if ;

TUPLE: FileArgs
    hFile lpBuffer nNumberOfBytesToRead lpNumberOfBytesRet lpOverlapped ;

C: <FileArgs> FileArgs

: make-FileArgs ( port -- <FileArgs> )
    [ port-handle win32-file-handle ] keep
    [ delegate ] keep
    [
        buffer-length
        "DWORD" <c-object>
    ] keep FileArgs-overlapped <FileArgs> ;

: setup-read ( <FileArgs> -- hFile lpBuffer nNumberOfBytesToRead lpNumberOfBytesRead lpOverlapped )
    [ FileArgs-hFile ] keep
    [ FileArgs-lpBuffer buffer-end ] keep
    [ FileArgs-lpBuffer buffer-capacity ] keep
    [ FileArgs-lpNumberOfBytesRet ] keep
    FileArgs-lpOverlapped ;

: setup-write ( <FileArgs> -- hFile lpBuffer nNumberOfBytesToWrite lpNumberOfBytesWritten lpOverlapped )
    [ FileArgs-hFile ] keep
    [ FileArgs-lpBuffer buffer@ ] keep
    [ FileArgs-lpBuffer buffer-length ] keep
    [ FileArgs-lpNumberOfBytesRet ] keep
    FileArgs-lpOverlapped ;

M: output-port stream-flush ( port -- )
    dup buffer-empty? [
        dup flush-output
    ] unless pending-error ;

M: port stream-close ( port -- )
    dup port-type closed = [
        drop
    ] [
        ! For duplex-streams, we call CloseHandle twice on the same handle
        [ dup port-type output = [ stream-flush ] [ drop ] if ] keep
        [ closed swap set-port-type ] keep
        [ port-handle win32-file-handle CloseHandle drop ] keep
        USE: namespaces
        [ delegate [ buffer-free ] [
            global [ "delegate was empty!!" print flush ] bind
            USE: windows.winsock.private
        ] if* ] keep
        f swap set-delegate
    ] if ;

M: windows-io <file-reader> ( path -- stream )
    open-read <win32-file> <reader> ;

M: windows-io <file-writer> ( path -- stream )
    open-write <win32-file> <writer> ;

M: windows-io <file-appender> ( path -- stream )
    open-append <win32-file> <writer> ;

M: windows-io rename-file ( from to -- )
    [ normalize-pathname ] 2apply
    MoveFile win32-error=0/f ;

M: windows-io delete-file ( path -- )
    normalize-pathname
    DeleteFile win32-error=0/f ;

M: windows-io make-directory ( path -- )
    normalize-pathname
    f CreateDirectory win32-error=0/f ;

M: windows-io delete-directory ( path -- )
    normalize-pathname
    RemoveDirectory win32-error=0/f ;

HOOK: WSASocket-flags io-backend ( -- DWORD )

TUPLE: win32-socket ;

: <win32-socket> ( handle -- win32-socket )
    f <win32-file>
    \ win32-socket construct-delegate ;

: open-socket ( family type -- socket )
    0 f 0 WSASocket-flags WSASocket dup socket-error ;

USE: windows.winsock
: init-sockaddr ( port# addrspec -- sockaddr )
    dup sockaddr-type <c-object>
    [ swap protocol-family swap set-sockaddr-in-family ] keep
    [ >r htons r> set-sockaddr-in-port ] keep ;

: server-sockaddr ( port# addrspec -- sockaddr )
    init-sockaddr
    [ INADDR_ANY swap set-sockaddr-in-addr ] keep ;

: bind-socket ( socket sockaddr addrspec -- )
    [ server-sockaddr ] keep
    sockaddr-type heap-size bind socket-error ;

: server-fd ( addrspec type -- fd )
    >r dup protocol-family r> open-socket
        dup close-socket-later
    dup rot make-sockaddr heap-size bind socket-error ;

USE: namespaces

! http://support.microsoft.com/kb/127144
! NOTE: Possibly tweak this because of SYN flood attacks
: listen-backlog ( -- n ) HEX: 7fffffff ; inline

: listen-on-socket ( socket -- )
    listen-backlog listen winsock-error!=0/f ;

M: win32-socket stream-close ( stream -- )
    win32-file-handle closesocket drop ;

M: windows-io addrinfo-error ( n -- )
    winsock-error!=0/f ;

: tcp-socket ( addrspec -- socket )
    protocol-family SOCK_STREAM open-socket ;

