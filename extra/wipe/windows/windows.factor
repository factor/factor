! Copyright (C) 2023 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: io.files.windows kernel math windows.kernel32 ;
IN: wipe.windows

: extract-bit ( n mask -- n' ? )
    [ bitnot bitand ] [ bitand 0 = not ] bi-curry bi ; inline

: remove-read-only ( file-name -- )
    dup GetFileAttributesW FILE_ATTRIBUTE_READONLY extract-bit
    [ set-file-attributes ] [ 2drop ] if ;
