! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors destructors io.timeouts kernel windows.errors
windows.kernel32 windows.types ;
IN: windows.handles

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
    [ cancel-operation ] [ call-next-method ] bi ;
