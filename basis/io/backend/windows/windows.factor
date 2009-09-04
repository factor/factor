! Copyright (C) 2004, 2008 Mackenzie Straight, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays destructors io io.backend
io.buffers io.files io.ports io.binary io.timeouts system
strings kernel math namespaces sequences windows.errors
windows.kernel32 windows.shell32 windows.types splitting
continuations math.bitwise accessors init sets assocs
classes.struct classes ;
IN: io.backend.windows

TUPLE: win32-handle < disposable handle ;

: set-inherit ( handle ? -- )
    [ handle>> HANDLE_FLAG_INHERIT ] dip
    >BOOLEAN SetHandleInformation win32-error=0/f ;

: new-win32-handle ( handle class -- win32-handle )
    new-disposable swap >>handle
    dup f set-inherit ;

: <win32-handle> ( handle -- win32-handle )
    win32-handle new-win32-handle ;

M: win32-handle dispose* ( handle -- )
    handle>> CloseHandle win32-error=0/f ;

TUPLE: win32-file < win32-handle ptr ;

: <win32-file> ( handle -- win32-file )
    win32-file new-win32-handle ;

M: win32-file dispose
    dup disposed>> [ drop ] [
        [ cancel-operation ] [ call-next-method ] bi
    ] if ;

HOOK: CreateFile-flags io-backend ( DWORD -- DWORD )
HOOK: FileArgs-overlapped io-backend ( port -- overlapped/f )
HOOK: add-completion io-backend ( port -- )

: opened-file ( handle -- win32-file )
    dup invalid-handle?
    <win32-file> |dispose
    dup add-completion ;

: share-mode ( -- n )
    {
        FILE_SHARE_READ
        FILE_SHARE_WRITE
        FILE_SHARE_DELETE
    } flags ; foldable

: default-security-attributes ( -- obj )
    SECURITY_ATTRIBUTES <struct>
    SECURITY_ATTRIBUTES heap-size >>nLength ;
