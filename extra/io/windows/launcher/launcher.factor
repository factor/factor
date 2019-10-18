USING: alien alien.c-types io.windows windows.kernel32
windows namespaces io.launcher kernel ;
IN: io.windows.launcher

: (run-process) ( string flag -- )
    >r string>u16-alien f swap f f 0 r>
    f f "STARTUPINFO" <c-object>
    "STARTUPINFO" heap-size over set-STARTUPINFO-cb
    "PROCESS_INFORMATION" <c-object> CreateProcess
    win32-error=0/f ;

M: windows-io run-process ( string -- )
    0 (run-process) ;

M: windows-io run-detached ( string -- )
    DETACHED_PROCESS (run-process) ;

