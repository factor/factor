IN: process
USING: alien compiler io io-internals kernel math parser generic win32-api ;

: (run-process) ( string flag -- )
    >r f swap
    f f 0 r> f f
    "STARTUPINFO" <c-object> "STARTUPINFO" c-size over set-STARTUPINFO-cb
    "PROCESS_INFORMATION" <c-object> CreateProcess zero? [ win32-error ] when ;

: run-process
    0 (run-process) ;

: run-detached ( string -- )
    DETACH_PROCESS (run-process) ;

