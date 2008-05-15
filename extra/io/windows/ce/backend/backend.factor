USING: io.ports io.windows threads.private kernel
io.backend windows.winsock windows.kernel32 windows
io.streams.duplex io namespaces alien.syntax system combinators
io.buffers io.encodings io.encodings.utf8 combinators.lib ;
IN: io.windows.ce.backend

: port-errored ( port -- )
    win32-error-string swap set-port-error ;

M: wince io-multiplex ( ms -- )
    60 60 * 1000 * or (sleep) ;

M: wince add-completion ( handle -- ) drop ;

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

M: wince init-io ( -- )
    init-winsock ;

LIBRARY: libc
FUNCTION: void* _getstdfilex int fd ;
FUNCTION: void* _fileno void* file ;

M: wince (init-stdio) ( -- )
    #! We support Windows NT too, to make this I/O backend
    #! easier to debug.
    512 default-buffer-size [
        os winnt? [
            STD_INPUT_HANDLE GetStdHandle
            STD_OUTPUT_HANDLE GetStdHandle
            STD_ERROR_HANDLE GetStdHandle
        ] [
            0 _getstdfilex _fileno
            1 _getstdfilex _fileno
            2 _getstdfilex _fileno
        ] if [ f <win32-file> ] 3apply
        [ <input-port> ] [ <output-port> ] [ <output-port> ] tri*
    ] with-variable ;
