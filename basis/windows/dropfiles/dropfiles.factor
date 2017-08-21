! Copyright (C) 2017 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.data alien.strings io.encodings.utf16n kernel math
sequences windows.messages windows.shell32 windows.types ;
IN: windows.dropfiles

: filecount-from-hdrop ( hdrop -- n )
    0xFFFFFFFF f 0 DragQueryFile ;

: filenames-from-hdrop ( hdrop -- filenames )
    dup filecount-from-hdrop <iota>
    [
        2dup f 0 DragQueryFile 1 + ! get size of filename buffer
        dup WCHAR <c-array>
        [ swap DragQueryFile drop ] keep
        utf16n alien>string
    ] with map ;
