! Copyright (C) 2004, 2010 Mackenzie Straight, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types classes.struct destructors
io.backend kernel literals windows.errors windows.handles
windows.kernel32 ;
IN: io.backend.windows

HOOK: CreateFile-flags io-backend ( DWORD -- DWORD )
HOOK: FileArgs-overlapped io-backend ( port -- overlapped/f )
HOOK: add-completion io-backend ( port -- )

: opened-file ( handle -- win32-file )
    dup invalid-handle?
    <win32-file> |dispose
    dup add-completion ;

CONSTANT: share-mode
    flags{
        FILE_SHARE_READ
        FILE_SHARE_WRITE
        FILE_SHARE_DELETE
    }
    
: default-security-attributes ( -- obj )
    SECURITY_ATTRIBUTES <struct>
    SECURITY_ATTRIBUTES heap-size >>nLength ;
