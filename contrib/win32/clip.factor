USING: kernel win32 math namespaces io prettyprint ;

: (enum-clipboard) ( n -- )
    EnumClipboardFormats win32-error dup 0 > [ dup , (enum-clipboard) ] when ;

: enum-clipboard ( -- seq )
    [ 0 (enum-clipboard) ] { } make nip ;

0 OpenClipboard win32-error
GetClipboardOwner drop win32-error
GetClipboardSequenceNumber drop win32-error
enum-clipboard


! EmptyClipboard
CloseClipboard drop win32-error
