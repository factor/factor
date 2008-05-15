! Copyright (C) 2004, 2008 Mackenzie Straight, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays destructors io io.backend
io.buffers io.files io.ports io.sockets io.binary
io.sockets windows.errors strings
kernel math namespaces sequences windows windows.kernel32
windows.shell32 windows.types windows.winsock splitting
continuations math.bitfields system accessors ;
IN: io.windows

TUPLE: win32-file handle ptr ;

C: <win32-file> win32-file

HOOK: CreateFile-flags io-backend ( DWORD -- DWORD )
HOOK: FileArgs-overlapped io-backend ( port -- overlapped/f )
HOOK: add-completion io-backend ( port -- )

M: windows normalize-directory ( string -- string )
    normalize-path "\\" ?tail drop "\\*" append ;

: share-mode ( -- fixnum )
    {
        FILE_SHARE_READ
        FILE_SHARE_WRITE
        FILE_SHARE_DELETE
    } flags ; foldable

: default-security-attributes ( -- obj )
    "SECURITY_ATTRIBUTES" <c-object>
    "SECURITY_ATTRIBUTES" heap-size
    over set-SECURITY_ATTRIBUTES-nLength ;

: security-attributes-inherit ( -- obj )
    default-security-attributes
    TRUE over set-SECURITY_ATTRIBUTES-bInheritHandle ; foldable

M: win32-file init-handle ( handle -- )
    drop ;

M: win32-file close-handle ( handle -- )
    handle>> close-handle ;

M: alien close-handle ( handle -- )
    CloseHandle drop ;

! Clean up resources (open handle) if add-completion fails
: open-file ( path access-mode create-mode flags -- handle )
    [
        >r >r share-mode security-attributes-inherit r> r>
        CreateFile-flags f CreateFile
        dup invalid-handle?
        |close-handle
        dup add-completion
    ] with-destructors ;

: open-pipe-r/w ( path -- handle )
    { GENERIC_READ GENERIC_WRITE } flags
    OPEN_EXISTING 0 open-file ;

: open-read ( path -- handle length )
    GENERIC_READ OPEN_EXISTING 0 open-file 0 ;

: open-write ( path -- handle length )
    GENERIC_WRITE CREATE_ALWAYS 0 open-file 0 ;

: (open-append) ( path -- handle )
    GENERIC_WRITE OPEN_ALWAYS 0 open-file ;

: open-existing ( path -- handle )
    { GENERIC_READ GENERIC_WRITE } flags
    share-mode
    f
    OPEN_EXISTING
    FILE_FLAG_BACKUP_SEMANTICS
    f CreateFileW dup win32-error=0/f ;

: maybe-create-file ( path -- handle ? )
    #! return true if file was just created
    { GENERIC_READ GENERIC_WRITE } flags
    share-mode
    f
    OPEN_ALWAYS
    0 CreateFile-flags
    f CreateFileW dup win32-error=0/f
    GetLastError ERROR_ALREADY_EXISTS = not ;

: set-file-pointer ( handle length method -- )
    >r dupd d>w/w <uint> r> SetFilePointer
    INVALID_SET_FILE_POINTER = [
        CloseHandle "SetFilePointer failed" throw
    ] when drop ;

HOOK: open-append os ( path -- handle length )

TUPLE: FileArgs
    hFile lpBuffer nNumberOfBytesToRead
    lpNumberOfBytesRet lpOverlapped ;

C: <FileArgs> FileArgs

: make-FileArgs ( port -- <FileArgs> )
    {
        [ handle>> handle>> ]
        [ buffer>> ]
        [ buffer>> buffer-length ]
        [ drop "DWORD" <c-object> ]
        [ FileArgs-overlapped ]
    } cleave <FileArgs> ;

: setup-read ( <FileArgs> -- hFile lpBuffer nNumberOfBytesToRead lpNumberOfBytesRead lpOverlapped )
    {
        [ hFile>> ]
        [ lpBuffer>> buffer-end ]
        [ lpBuffer>> buffer-capacity ]
        [ lpNumberOfBytesRet>> ]
        [ lpOverlapped>> ]
    } cleave ;

: setup-write ( <FileArgs> -- hFile lpBuffer nNumberOfBytesToWrite lpNumberOfBytesWritten lpOverlapped )
    {
        [ hFile>> ]
        [ lpBuffer>> buffer@ ]
        [ lpBuffer>> buffer-length ]
        [ lpNumberOfBytesRet>> ]
        [ lpOverlapped>> ]
    } cleave ;

M: windows (file-reader) ( path -- stream )
    open-read <win32-file> <input-port> ;

M: windows (file-writer) ( path -- stream )
    open-write <win32-file> <output-port> ;

M: windows (file-appender) ( path -- stream )
    open-append <win32-file> <output-port> ;

M: windows move-file ( from to -- )
    [ normalize-path ] bi@ MoveFile win32-error=0/f ;

M: windows delete-file ( path -- )
    normalize-path DeleteFile win32-error=0/f ;

M: windows copy-file ( from to -- )
    dup parent-directory make-directories
    [ normalize-path ] bi@ 0 CopyFile win32-error=0/f ;

M: windows make-directory ( path -- )
    normalize-path
    f CreateDirectory win32-error=0/f ;

M: windows delete-directory ( path -- )
    normalize-path
    RemoveDirectory win32-error=0/f ;

HOOK: WSASocket-flags io-backend ( -- DWORD )

TUPLE: win32-socket < win32-file overlapped ;

: <win32-socket> ( handle overlapped -- win32-socket )
    win32-socket new
        swap >>overlapped
        swap >>handle ;

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

TUPLE: socket-destructor alien ;

C: <socket-destructor> socket-destructor

M: socket-destructor dispose ( obj -- )
    alien>> closesocket drop ;

: |close-socket ( handle -- handle )
    dup <socket-destructor> <only-once> |dispose drop ;

: server-fd ( addrspec type -- fd )
    >r dup protocol-family r> open-socket |close-socket
    dup rot make-sockaddr/size bind socket-error ;

USE: namespaces

! http://support.microsoft.com/kb/127144
! NOTE: Possibly tweak this because of SYN flood attacks
: listen-backlog ( -- n ) HEX: 7fffffff ; inline

: listen-on-socket ( socket -- )
    listen-backlog listen winsock-return-check ;

M: win32-socket dispose ( stream -- )
    handle>> closesocket drop ;

M: windows addrinfo-error ( n -- )
    winsock-return-check ;

: tcp-socket ( addrspec -- socket )
    protocol-family SOCK_STREAM open-socket ;
