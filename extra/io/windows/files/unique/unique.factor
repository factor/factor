USING: kernel system io.files.unique.backend
windows.kernel32 io.windows io.nonblocking windows ;
IN: io.windows.files.unique

M: windows-io (make-unique-file) ( path -- )
    GENERIC_WRITE CREATE_NEW 0 open-file
    CloseHandle win32-error=0/f ;

M: windows-io temporary-path ( -- path )
    "TEMP" os-env ;
