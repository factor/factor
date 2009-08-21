! Copyright (C) 2004, 2008 Mackenzie Straight, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays destructors io io.backend
io.buffers io.files io.ports io.binary io.timeouts system
strings kernel math namespaces sequences windows.errors
windows.kernel32 windows.shell32 windows.types windows.winsock
splitting continuations math.bitwise accessors init sets assocs ;
IN: io.backend.windows

: win32-handles ( -- assoc )
    \ win32-handles [ H{ } clone ] initialize-alien ;

TUPLE: win32-handle < identity-tuple handle disposed ;

M: win32-handle hashcode* handle>> hashcode* ;

: set-inherit ( handle ? -- )
    [ handle>> HANDLE_FLAG_INHERIT ] dip
    >BOOLEAN SetHandleInformation win32-error=0/f ;

: new-win32-handle ( handle class -- win32-handle )
    new swap >>handle
    dup f set-inherit
    dup win32-handles conjoin ;

: <win32-handle> ( handle -- win32-handle )
    win32-handle new-win32-handle ;

ERROR: disposing-twice ;

: unregister-handle ( handle -- )
    win32-handles delete-at*
    [ t >>disposed drop ] [ disposing-twice ] if ;

M: win32-handle dispose* ( handle -- )
    [ unregister-handle ] [ handle>> CloseHandle win32-error=0/f ] bi ;

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
