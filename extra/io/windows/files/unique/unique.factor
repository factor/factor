USING: kernel system io.files.unique.backend
windows.kernel32 io.windows io.windows.files io.ports windows
destructors ;
IN: io.windows.files.unique

M: windows (make-unique-file) ( path -- )
    GENERIC_WRITE CREATE_NEW 0 open-file dispose ;

M: windows temporary-path ( -- path )
    "TEMP" os-env ;
