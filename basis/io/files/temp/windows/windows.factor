! (c)2012 Joe Groff bsd license
USING: ;
SPECIALIZED-ARRAY: WCHAR
IN: io.files.temp.windows

<PRIVATE

: (get-temp-directory) ( -- path )
    MAX_PATH dup <WCHAR-array> [ GetTempPath ] keep
    swap win32-error
    utf16n alien>string ;

: (get-appdata-directory) ( -- path )
    f
    CSIDL_LOCAL_APPDATA CSIDL_FLAG_CREATE bitor
    f
    0
    MAX_PATH <WCHAR-array>
    [ SHGetFolderPath ] keep
    swap win32-error
    utf16n alien>string ;

PRIVATE>

MEMO: (temp-directory) ( -- path )
    (get-temp-directory) "factorcode.org\\Factor" append-path dup make-directories ;

M: windows temp-directory (temp-directory) ;

MEMO: (cache-directory) ( -- path )
    (get-appdata-directory) "factorcode.org\\Factor" append-path dup make-directories ;

M: windows cache-directory (cache-directory) ;
