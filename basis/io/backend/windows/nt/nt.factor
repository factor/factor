USING: alien alien.c-types arrays assocs combinators continuations
destructors io io.backend io.ports io.timeouts io.backend.windows
io.files.windows io.files.windows.nt io.files io.pathnames io.buffers
io.streams.c io.streams.null libc kernel math namespaces sequences
threads windows windows.errors windows.kernel32 strings splitting
ascii system accessors locals classes.struct combinators.short-circuit ;
IN: io.backend.windows.nt

! Global variable with assoc mapping overlapped to threads
SYMBOL: pending-overlapped

TUPLE: io-callback port thread ;

C: <io-callback> io-callback

: (make-overlapped) ( -- overlapped-ext )
    OVERLAPPED malloc-struct &free ;

: make-overlapped ( port -- overlapped-ext )
    [ (make-overlapped) ] dip
    handle>> ptr>> [ >>offset ] when* ;

M: winnt FileArgs-overlapped ( port -- overlapped )
    make-overlapped ;

: <completion-port> ( handle existing -- handle )
     f 1 CreateIoCompletionPort dup win32-error=0/f ;

SYMBOL: master-completion-port

: <master-completion-port> ( -- handle )
    INVALID_HANDLE_VALUE f <completion-port> ;

M: winnt add-completion ( win32-handle -- )
    handle>> master-completion-port get-global <completion-port> drop ;

: eof? ( error -- ? )
    { [ ERROR_HANDLE_EOF = ] [ ERROR_BROKEN_PIPE = ] } 1|| ;

: twiddle-thumbs ( overlapped port -- bytes-transferred )
    [
        drop
        [ >c-ptr pending-overlapped get-global set-at ] curry "I/O" suspend
        {
            { [ dup integer? ] [ ] }
            { [ dup array? ] [
                first dup eof?
                [ drop 0 ] [ n>win32-error-string throw ] if
            ] }
        } cond
    ] with-timeout ;

:: wait-for-overlapped ( nanos -- bytes-transferred overlapped error? )
    master-completion-port get-global
    0 <int> :> bytes
    f <void*> :> key
    f <void*> :> overlapped
    nanos [ 1,000,000 /i ] [ INFINITE ] if* :> timeout
    bytes key overlapped timeout GetQueuedCompletionStatus zero? :> error?

    bytes *int
    overlapped *void* dup [ OVERLAPPED memory>struct ] when
    error? ;

: resume-callback ( result overlapped -- )
    >c-ptr pending-overlapped get-global delete-at* drop resume-with ;

: handle-overlapped ( nanos -- ? )
    wait-for-overlapped [
        [
            [ drop GetLastError 1array ] dip resume-callback t
        ] [ drop f ] if*
    ] [ resume-callback t ] if ;

M: win32-handle cancel-operation
    [ check-disposed ] [ handle>> CancelIo drop ] bi ;

M: winnt io-multiplex ( nanos -- )
    handle-overlapped [ 0 io-multiplex ] when ;

M: winnt init-io ( -- )
    <master-completion-port> master-completion-port set-global
    H{ } clone pending-overlapped set-global ;

ERROR: invalid-file-size n ;

: handle>file-size ( handle -- n )
    0 <ulonglong> [ GetFileSizeEx win32-error=0/f ] keep *ulonglong ;

ERROR: seek-before-start n ;

: set-seek-ptr ( n handle -- )
    [ dup 0 < [ seek-before-start ] when ] dip (>>ptr) ;

M: winnt tell-handle ( handle -- n ) ptr>> ;

M: winnt seek-handle ( n seek-type handle -- )
    swap {
        { seek-absolute [ set-seek-ptr ] }
        { seek-relative [ [ ptr>> + ] keep set-seek-ptr ] }
        { seek-end [ [ handle>> handle>file-size + ] keep set-seek-ptr ] }
        [ bad-seek-type ]
    } case ;

: file-error? ( n -- eof? )
    zero? [
        GetLastError {
            { [ dup expected-io-error? ] [ drop f ] }
            { [ dup eof? ] [ drop t ] }
            [ n>win32-error-string throw ]
        } cond
    ] [ f ] if ;

: wait-for-file ( FileArgs n port -- n )
    swap file-error?
    [ 2drop 0 ] [ [ lpOverlapped>> ] dip twiddle-thumbs ] if ;

: update-file-ptr ( n port -- )
    handle>> dup ptr>> [ rot + >>ptr drop ] [ 2drop ] if* ;

: finish-write ( n port -- )
    [ update-file-ptr ] [ buffer>> buffer-consume ] 2bi ;

M: winnt (wait-to-write)
    [
        [ make-FileArgs dup setup-write WriteFile ]
        [ wait-for-file ]
        [ finish-write ]
        tri
    ] with-destructors ;

: finish-read ( n port -- )
    [ update-file-ptr ] [ buffer>> n>buffer ] 2bi ;

M: winnt (wait-to-read) ( port -- )
    [
        [ make-FileArgs dup setup-read ReadFile ]
        [ wait-for-file ]
        [ finish-read ]
        tri
    ] with-destructors ;

: console-app? ( -- ? ) GetConsoleWindow >boolean ;

M: winnt init-stdio
    console-app?
    [ init-c-stdio ]
    [ null-reader null-writer null-writer set-stdio ] if ;

winnt set-io-backend
