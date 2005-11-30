USING: kernel win32 math namespaces io prettyprint ;

: (enum-clipboard) ( n -- )
    EnumClipboardFormats win32-error dup 0 > [ dup , (enum-clipboard) ] when ;

: enum-clipboard ( -- seq )
    [ 0 (enum-clipboard) ] { } make nip ;

: paste ( -- str )
    0 OpenClipboard drop
    CF_TEXT IsClipboardFormatAvailable 0 = [
            "no text in clipboard" print
        ] [
            "text found" print
            CF_TEXT GetClipboardData
            dup GlobalLock swap
            GlobalUnlock drop
    ] if
    CloseClipboard drop ;

: copy ( str -- )
    0 OpenClipboard drop
    CF_TEXT 0 SetClipboardData win32-error
    CloseClipboard drop ;

