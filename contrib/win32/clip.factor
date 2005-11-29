USING: kernel win32 math namespaces io prettyprint ;

: (enum-clipboard) ( n -- )
    EnumClipboardFormats win32-error dup 0 > [ dup , (enum-clipboard) ] when ;

: enum-clipboard ( -- seq )
    [ 0 (enum-clipboard) ] { } make nip ;

0 OpenClipboard win32-error
! GetClipboardOwner drop win32-error
! GetClipboardSequenceNumber drop win32-error
! enum-clipboard

CF_TEXT IsClipboardFormatAvailable win32-error 0 > [
    CF_TEXT GetClipboardData win32-error
    ! dup GlobalLock win32-error
    ! GlobalUnlock win32-error
] when


! EmptyClipboard
CloseClipboard drop win32-error
