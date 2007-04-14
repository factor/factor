! Copyright (C) 2004, 2008 Mackenzie Straight, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays destructors io io.backend
io.buffers io.files io.nonblocking io.sockets io.binary
io.sockets.impl windows.errors strings io.streams.duplex
kernel math namespaces sequences windows windows.kernel32
windows.shell32 windows.types windows.winsock splitting
continuations math.bitfields ;
IN: io.windows

TUPLE: windows-nt-io ;
TUPLE: windows-ce-io ;
UNION: windows-io windows-nt-io windows-ce-io ;

M: windows-io destruct-handle CloseHandle drop ;

M: windows-io destruct-socket closesocket drop ;

TUPLE: win32-file handle ptr ;

C: <win32-file> win32-file

HOOK: CreateFile-flags io-backend ( DWORD -- DWORD )
HOOK: FileArgs-overlapped io-backend ( port -- overlapped/f )
HOOK: add-completion io-backend ( port -- )

M: windows-io normalize-directory ( string -- string )
    normalize-pathname "\\" ?tail drop "\\*" append ;

: share-mode ( -- fixnum )
    {
        FILE_SHARE_READ
        FILE_SHARE_WRITE
        FILE_SHARE_DELETE
    } flags ; foldable

: default-security-attributes ( -- obj )
    "SECURITY_ATTRIBUTES" <c-object>
    "SECURITY_ATTRIBUTES" heap-size over set-SECURITY_ATTRIBUTES-nLength ;

: security-attributes-inherit ( -- obj )
    default-security-attributes
    TRUE over set-SECURITY_ATTRIBUTES-bInheritHandle ; foldable

M: win32-file init-handle ( handle -- )
    drop ;

M: win32-file close-handle ( handle -- )
    win32-file-handle CloseHandle drop ;

! Clean up resources (open handle) if add-completion fails
: open-file ( path access-mode create-mode flags -- handle )
    [
        >r >r
        share-mode security-attributes-inherit r> r> CreateFile-flags f CreateFile
        dup invalid-handle? dup close-later
        dup add-completion
    ] with-destructors ;

: open-pipe-r/w ( path -- handle )
    GENERIC_READ GENERIC_WRITE bitor OPEN_EXISTING 0 open-file ;

: open-read ( path -- handle length )
    GENERIC_READ OPEN_EXISTING 0 open-file 0 ;

: open-write ( path -- handle length )
    GENERIC_WRITE CREATE_ALWAYS 0 open-file 0 ;

: (open-append) ( path -- handle )
    GENERIC_WRITE OPEN_ALWAYS 0 open-file ;

: set-file-pointer ( handle length -- )
    dupd d>w/w <uint> FILE_BEGIN SetFilePointer
    INVALID_SET_FILE_POINTER = [
        CloseHandle "SetFilePointer failed" throw
    ] when drop ;

: open-append ( path -- handle length )
    [ dup file-info file-info-size ] [ drop 0 ] recover
    >r (open-append) r> 2dup set-file-pointer ;

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

M: windows-io (file-reader) ( path -- stream )
    open-read <win32-file> <reader> ;

M: windows-io (file-writer) ( path -- stream )
    open-write <win32-file> <writer> ;

M: windows-io (file-appender) ( path -- stream )
    open-append <win32-file> <writer> ;

M: windows-io move-file ( from to -- )
    [ normalize-pathname ] 2apply MoveFile win32-error=0/f ;

M: windows-io delete-file ( path -- )
    normalize-pathname DeleteFile win32-error=0/f ;

M: windows-io copy-file ( from to -- )
    dup parent-directory make-directories
    [ normalize-pathname ] 2apply 0 CopyFile win32-error=0/f ;

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
    dup rot make-sockaddr/size bind socket-error ;

USE: namespaces

! http://support.microsoft.com/kb/127144
! NOTE: Possibly tweak this because of SYN flood attacks
: listen-backlog ( -- n ) HEX: 7fffffff ; inline

: listen-on-socket ( socket -- )
    listen-backlog listen winsock-return-check ;

M: win32-socket dispose ( stream -- )
    win32-file-handle closesocket drop ;

M: windows-io addrinfo-error ( n -- )
    winsock-return-check ;

: tcp-socket ( addrspec -- socket )
    protocol-family SOCK_STREAM open-socket ;

