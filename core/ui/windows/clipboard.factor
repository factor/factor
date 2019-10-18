! Copyright (C) 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel win32-api math namespaces io prettyprint errors sequences alien
    libc gadgets ;
IN: win32

: crlf>lf CHAR: \r swap remove ;
: lf>crlf [ [ dup CHAR: \n = [ CHAR: \r , ] when , ] each ] "" make ;

: (enum-clipboard) ( n -- n )
    EnumClipboardFormats win32-error dup 0 > [ dup , (enum-clipboard) ] when ;

: enum-clipboard ( -- seq )
    [ 0 (enum-clipboard) ] { } make nip ;

: with-clipboard ( quot -- )
    f OpenClipboard win32-error=0/f
    call
    CloseClipboard win32-error=0/f ; inline
    

: paste ( -- str )
    [
        CF_UNICODETEXT IsClipboardFormatAvailable 0 = [
            ! nothing to paste
            ""
        ] [
            CF_UNICODETEXT GetClipboardData dup win32-error=0/f
            dup GlobalLock dup win32-error=0/f
            GlobalUnlock win32-error=0/f
            alien>u16-string
        ] if
    ] with-clipboard
    crlf>lf ;

: copy ( str -- )
    lf>crlf [
        string>u16-alien
        f OpenClipboard win32-error=0/f
        EmptyClipboard win32-error=0/f
        GMEM_MOVEABLE over length 1+ GlobalAlloc
            dup win32-error=0/f
    
        dup GlobalLock dup win32-error=0/f
        rot dup length memcpy
        dup GlobalUnlock win32-error=0/f
        CF_UNICODETEXT swap SetClipboardData win32-error=0/f
    ] with-clipboard ;

TUPLE: pasteboard ;
M: pasteboard clipboard-contents drop paste ;
M: pasteboard set-clipboard-contents drop copy ;

: init-clipboard ( -- )
    <pasteboard> clipboard set-global ;
