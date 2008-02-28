USING: io.files.temporary.backend io.nonblocking io.windows
kernel system windows.kernel32 ;

IN: io.windows.files.temporary

M: windows-io (temporary-file) ( path -- stream )
    GENERIC_WRITE CREATE_NEW 0 open-file 0 <win32-file> <writer> ;

M: windows-io temporary-path ( -- path )
    "TEMP" os-env ;
