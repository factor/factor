! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factor.sf.net/license.txt for BSD license.
USING: alien errors io kernel math namespaces parser prettyprint words ;
IN: win32-api

: (win32-error) ( id -- string )
    #! In f.exe
    "char*" f "error_message" [ "int" ] alien-invoke ;

: win32-error ( -- ) GetLastError dup 0 = [ (win32-error) throw ] unless drop ;

: win32-error=0 zero? [ win32-error ] when ;
: win32-error>0 0 > [ win32-error ] when ;
: win32-error<0 0 < [ win32-error ] when ;
: win32-error<>0 zero? [ win32-error ] unless ;

: lo-word ( wparam -- lo ) HEX: ffff bitand ;
: hi-word ( wparam -- hi ) -16 shift ;

: msgbox ( str -- )
    f swap "DebugMsg" MB_OK MessageBox drop ;

