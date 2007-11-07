USING: io.nonblocking io.windows threads.private kernel
io.backend windows.winsock windows ;
IN: io.windows.ce.backend

: port-errored ( port -- )
    win32-error-string swap set-port-error ;

M: windows-ce-io io-multiplex ( ms -- ) (sleep) ;
M: windows-ce-io add-completion ( port -- ) drop ;

GENERIC: wince-read ( port port-handle -- )

M: input-port (wait-to-read) ( port -- )
    dup port-handle wince-read ;

GENERIC: wince-write ( port port-handle -- )

M: windows-ce-io flush-output ( port -- )
    dup port-handle wince-write ;

M: windows-ce-io init-io ( -- )
    init-winsock ;
