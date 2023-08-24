! Copyright (C) 2012 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.data alien.strings io.directories io.files.temp
io.pathnames kernel literals math memoize specialized-arrays
system windows.errors windows.kernel32 windows.ole32
windows.shell32 windows.types ;
SPECIALIZED-ARRAY: WCHAR
IN: io.files.temp.windows

<PRIVATE

: get-temp-directory ( -- path )
    MAX_PATH 1 + dup WCHAR <c-array> [ GetTempPath ] keep
    swap win32-error=0/f
    alien>native-string ;

PRIVATE>

: get-appdata-directory ( -- path )
    f
    flags{ CSIDL_LOCAL_APPDATA CSIDL_FLAG_CREATE }
    f
    0
    MAX_PATH 1 + WCHAR <c-array>
    [ SHGetFolderPath ] keep
    swap check-ole32-error alien>native-string ;

M: windows default-temp-directory
    get-temp-directory "factorcode.org\\Factor" append-path ;

M: windows default-cache-directory
    get-appdata-directory "factorcode.org\\Factor" append-path ;
