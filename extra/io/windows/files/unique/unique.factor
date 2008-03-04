USING: kernel system io.files.unique.backend
windows.kernel32 io.windows io.nonblocking ;
IN: io.windows.files.unique

M: windows-io (make-unique-file) ( path -- stream )
    GENERIC_WRITE CREATE_NEW 0 open-file 0 <win32-file> <writer> ;

M: windows-io temporary-path ( -- path )
    "TEMP" os-env ;
