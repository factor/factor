USING: destructors environment io.files.unique io.files.windows
system windows.kernel32 ;
IN: io.files.unique.windows

M: windows (touch-unique-file) ( path -- )
    GENERIC_WRITE CREATE_NEW 0 open-file dispose ;

M: windows default-temporary-directory ( -- path )
    "TEMP" os-env ;
