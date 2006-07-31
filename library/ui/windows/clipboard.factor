! Copyright (C) 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel win32-api math namespaces io prettyprint errors sequences alien
    libc gadgets ;
IN: win32

: crlf>lf CHAR: \r swap remove ;
: lf>crlf [ [ dup CHAR: \n = [ CHAR: \r , ] when , ] each ] "" make ;

: (enum-clipboard) ( n -- )
    EnumClipboardFormats win32-error dup 0 > [ dup , (enum-clipboard) ] when ;

: enum-clipboard ( -- seq )
    [ 0 (enum-clipboard) ] { } make nip ;

: paste ( -- str )
    f OpenClipboard drop
    CF_TEXT IsClipboardFormatAvailable 0 = [
            ! nothing to paste
            ""
        ] [
            CF_TEXT GetClipboardData
            dup GlobalLock swap
            GlobalUnlock drop
            alien>char-string
    ] if
    CloseClipboard drop
    crlf>lf ;

: copy ( str -- )
    lf>crlf
    f OpenClipboard drop
    EmptyClipboard drop
    GMEM_MOVEABLE over length 1+ GlobalAlloc dup 0 = [
        "unable to allocate memory" throw
    ] when

    dup GlobalLock
    rot [ string>char-alien ] keep length memcpy
    dup GlobalUnlock drop
    CF_TEXT swap SetClipboardData 0 = [
        win32-error
        "SetClipboardData failed" throw
    ] when
    CloseClipboard drop ;

TUPLE: pasteboard ;
M: pasteboard clipboard-contents ( pb -- str ) drop paste ;
M: pasteboard set-clipboard-contents ( str pb -- ) drop copy ;

: init-clipboard ( -- )
    <pasteboard> clipboard set-global ;
