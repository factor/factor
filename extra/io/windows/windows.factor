USING: alien alien.c-types arrays io
io.backend io.buffers io.files io.nonblocking io.sockets
io.sockets.impl windows.errors
io.streams.duplex kernel math namespaces sequences windows
windows.kernel32 windows.winsock windows.winsock.private ;
USE: prettyprint
IN: io.windows

TUPLE: windows-nt-io ;
TUPLE: windows-ce-io ;
UNION: windows-io windows-nt-io windows-ce-io ;
USE: io.windows.launcher

TUPLE: win32-file handle ptr ;
C: <win32-file> win32-file
HOOK: CreateFile-flags io-backend ( -- DWORD )
HOOK: flush-output io-backend ( port -- )
HOOK: FileArgs-overlapped io-backend ( port -- overlapped/f )
HOOK: add-completion io-backend ( port -- error/f )

M: windows-io normalize-directory ( string -- string )
    dup peek CHAR: \\ = "*" "\\*" ? append ;

: share-mode ( -- fixnum )
    FILE_SHARE_READ FILE_SHARE_WRITE bitor ; inline

M: win32-file init-handle ( handle -- ) drop ;

! Clean up resources (open handle) if add-completion fails
: open-file ( path access-mode create-mode -- handle )
    >r share-mode f r> CreateFile-flags f CreateFile
    dup INVALID_HANDLE_VALUE = [ win32-error-string throw ] when
    dup add-completion [ >r CloseHandle drop r> throw ] when* ;

: open-read ( path -- handle length )
    normalize-pathname GENERIC_READ OPEN_EXISTING open-file 0 ;

: open-write ( path -- handle length )
    normalize-pathname GENERIC_WRITE CREATE_ALWAYS open-file 0 ;

: (open-append) ( path -- handle )
    normalize-pathname GENERIC_WRITE OPEN_ALWAYS open-file ;

: open-append ( path -- handle length )
    dup file-length dup
    [ >r (open-append) r> ] [ drop open-write ] if ;

: expected-io-error? ( n -- ? )
    ERROR_SUCCESS ERROR_IO_PENDING WAIT_TIMEOUT 3array member? ;


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
    [ FileArgs-lpBuffer buffer-end alien-address ] keep
    [ FileArgs-lpBuffer buffer-capacity ] keep
    [ FileArgs-lpNumberOfBytesRet ] keep
    FileArgs-lpOverlapped ;

: setup-write ( <FileArgs> -- hFile lpBuffer nNumberOfBytesToWrite lpNumberOfBytesWritten lpOverlapped )
    [ FileArgs-hFile ] keep
    [ FileArgs-lpBuffer buffer@ alien-address ] keep
    [ FileArgs-lpBuffer buffer-length ] keep
    [ FileArgs-lpNumberOfBytesRet ] keep
    FileArgs-lpOverlapped ;

M: output-port stream-flush ( port -- )
    dup buffer-empty? [
        dup flush-output
    ] unless pending-error ;

M: port stream-close ( port -- )
    dup port-type closed eq? [
        dup port-type output eq? [ dup stream-flush ] when
        dup port-handle win32-file-handle CloseHandle drop
        dup delegate [ buffer-free ] when*
        closed over set-port-type
        f over set-delegate
    ] unless drop ;

M: windows-io <file-reader> ( path -- stream )
    open-read <win32-file> <reader> ;

M: windows-io <file-writer> ( path -- stream )
    open-write <win32-file> <writer> ;

M: windows-io <file-appender> ( path -- stream )
    open-append <win32-file> <writer> ;


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
    win32-socket construct-empty [ set-delegate ] keep ;
 
: (winsock-error-string) ( n -- str )
    ! #! WSAStartup returns the error code 'n' directly
    dup ERROR_IO_PENDING = over ERROR_SUCCESS = or
    [ drop f ] [ error_message alien>u16-string ] if ;

: winsock-error-string ( -- string/f )
    WSAGetLastError (winsock-error-string) ;
 
: init-winsock ( -- )
    HEX: 0202 <wsadata> WSAStartup
    dup zero? [ drop ] [ (winsock-error-string) throw ] if ;

: open-socket ( family type -- socket )
    0 f 0 WSASocket-flags WSASocket dup INVALID_SOCKET = [
        drop winsock-error-string throw
    ] when ;

USE: windows.winsock
: init-sockaddr ( port# addrspec -- sockaddr )
    dup sockaddr-type <c-object>
    [ swap protocol-family swap set-sockaddr-in-family ] keep
    [ >r htons r> set-sockaddr-in-port ] keep ;

: server-sockaddr ( port# addrspec -- sockaddr )
    init-sockaddr
    [ INADDR_ANY swap set-sockaddr-in-addr ] keep ;

: bind-socket ( socket sockaddr addrspec -- error/f )
    [ server-sockaddr ] keep
    sockaddr-type heap-size bind SOCKET_ERROR =
    [ winsock-error-string ] [ f ] if ;

: server-fd ( addrspec type -- fd )
    >r dup protocol-family r> open-socket
    dup rot make-sockaddr heap-size bind
    SOCKET_ERROR = [ closesocket winsock-error-string throw ] when ;

USE: namespaces

! http://support.microsoft.com/kb/127144
! NOTE: Possibly tweak this because of SYN flood attacks
: listen-backlog ( -- n ) HEX: 7fffffff ; inline

: listen-on-socket ( socket -- )
    dup listen-backlog listen
    zero? [ drop ] [ closesocket winsock-error-string throw ] if ;

M: win32-socket stream-close ( stream -- )
    win32-file-handle closesocket drop ;

M: windows-io addrinfo-error ( n -- )
    dup zero? [ drop ] [ (winsock-error-string) throw ] if ;

: tcp-socket ( addrspec -- socket )
    protocol-family SOCK_STREAM open-socket ;

