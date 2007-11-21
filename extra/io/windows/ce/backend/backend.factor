USING: io.nonblocking io.windows threads.private kernel
io.backend windows.winsock windows.kernel32 windows
io.streams.duplex io namespaces alien.syntax system combinators
io.buffers ;
IN: io.windows.ce.backend

: port-errored ( port -- )
    win32-error-string swap set-port-error ;

M: windows-ce-io io-multiplex ( ms -- ) (sleep) ;
M: windows-ce-io add-completion ( port -- ) drop ;

GENERIC: wince-read ( port port-handle -- )

M: input-port (wait-to-read) ( port -- )
    dup dup port-handle wince-read pending-error ;

GENERIC: wince-write ( port port-handle -- )

M: port port-flush
    dup buffer-empty? over port-error or [
        drop
    ] [
        dup dup port-handle wince-write port-flush
    ] if ;

M: windows-ce-io init-io ( -- )
    init-winsock ;

LIBRARY: libc
FUNCTION: void* _getstdfilex int fd ;
FUNCTION: void* _fileno void* file ;

M: windows-ce-io init-stdio ( -- )
    #! We support Windows NT too, to make this I/O backend
    #! easier to debug.
    512 default-buffer-size [
        winnt? [
            STD_INPUT_HANDLE GetStdHandle
            STD_OUTPUT_HANDLE GetStdHandle
        ] [
            0 _getstdfilex _fileno
            1 _getstdfilex _fileno
        ] if <win32-duplex-stream>
    ] with-variable stdio set ;
