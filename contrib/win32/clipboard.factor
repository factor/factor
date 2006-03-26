USING: kernel win32-api math namespaces io prettyprint errors sequences alien ;
IN: win32

: (enum-clipboard) ( n -- )
    EnumClipboardFormats win32-error dup 0 > [ dup , (enum-clipboard) ] when ;

: enum-clipboard ( -- seq )
    [ 0 (enum-clipboard) ] { } make nip ;

: paste ( -- str )
    f OpenClipboard drop
    CF_TEXT IsClipboardFormatAvailable 0 = [
            "no text in clipboard" print
        ] [
            ! "text found" print
            CF_TEXT GetClipboardData
            dup GlobalLock swap
            GlobalUnlock drop
    ] if
    CloseClipboard drop alien>string ;

LIBRARY: libc
FUNCTION: void memcpy ( char* dst, char* src, ulong size ) ;

: copy ( str -- )
    f OpenClipboard drop
    EmptyClipboard drop
    GMEM_MOVEABLE over length 1+ GlobalAlloc dup 0 = [
        "unable to allocate memory" throw
    ] when

    dup GlobalLock
    rot dup length memcpy
    dup GlobalUnlock drop
    CF_TEXT swap SetClipboardData 0 = [
        win32-error
        "SetClipboardData failed" throw
    ] when

    CloseClipboard drop ;
       

        ! hglbCopy = GlobalAlloc(GMEM_MOVEABLE, 
            ! (cch + 1) * sizeof(TCHAR)); 


        ! // Lock the handle and copy the text to the buffer. 
 
        ! lptstrCopy = GlobalLock(hglbCopy); 
        ! memcpy(lptstrCopy, &pbox->atchLabel[ich1], 
            ! cch * sizeof(TCHAR)); 
        ! lptstrCopy[cch] = (TCHAR) 0;    // null character 
        ! GlobalUnlock(hglbCopy); 

        ! // Place the handle on the clipboard. 
        ! SetClipboardData(CF_TEXT, hglbCopy); 



