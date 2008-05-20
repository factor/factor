USING: alien alien.c-types arrays assocs combinators
continuations destructors io io.backend io.ports io.timeouts
io.windows io.windows.files libc kernel math namespaces
sequences threads classes.tuple.lib windows windows.errors
windows.kernel32 strings splitting io.files
io.buffers qualified ascii combinators.lib system
accessors locals ;
QUALIFIED: windows.winsock
IN: io.windows.nt.backend

! Global variable with assoc mapping overlapped to threads
SYMBOL: pending-overlapped

TUPLE: io-callback port thread ;

C: <io-callback> io-callback

: (make-overlapped) ( -- overlapped-ext )
    "OVERLAPPED" malloc-object &free ;

: make-overlapped ( port -- overlapped-ext )
    >r (make-overlapped)
    r> handle>> ptr>> [ over set-OVERLAPPED-offset ] when* ;

: <completion-port> ( handle existing -- handle )
     f 1 CreateIoCompletionPort dup win32-error=0/f ;

SYMBOL: master-completion-port

: <master-completion-port> ( -- handle )
    INVALID_HANDLE_VALUE f <completion-port> ;

M: winnt add-completion ( win32-handle -- )
    handle>> master-completion-port get-global <completion-port> drop ;

: eof? ( error -- ? )
    [ ERROR_HANDLE_EOF = ] [ ERROR_BROKEN_PIPE = ] bi or ;

: twiddle-thumbs ( overlapped port -- bytes-transferred )
    [
        drop
        [ pending-overlapped get-global set-at ] curry "I/O" suspend
        {
            { [ dup integer? ] [ ] }
            { [ dup array? ] [
                first dup eof?
                [ drop 0 ] [ (win32-error-string) throw ] if
            ] }
        } cond
    ] with-timeout ;

:: wait-for-overlapped ( ms -- bytes-transferred overlapped error? )
    master-completion-port get-global
    0 <int> [ ! bytes
        f <void*> ! key
        f <void*> [ ! overlapped
            ms INFINITE or ! timeout
            GetQueuedCompletionStatus zero?
        ] keep *void*
    ] keep *int spin ;

: resume-callback ( result overlapped -- )
    pending-overlapped get-global delete-at* drop resume-with ;

: handle-overlapped ( timeout -- ? )
    wait-for-overlapped [
        >r drop GetLastError
        [ 1array ] [ expected-io-error? ] bi
        [ r> 2drop f ] [ r> resume-callback t ] if
    ] [
        resume-callback t
    ] if ;

M: win32-handle cancel-io
    handle>> CancelIo drop ;

M: winnt io-multiplex ( ms -- )
    handle-overlapped [ 0 io-multiplex ] when ;

M: winnt init-io ( -- )
    <master-completion-port> master-completion-port set-global
    H{ } clone pending-overlapped set-global
    windows.winsock:init-winsock ;

: file-error? ( n -- eof? )
    zero? [
        GetLastError {
            { [ dup expected-io-error? ] [ drop f ] }
            { [ dup eof? ] [ drop t ] }
            [ (win32-error-string) throw ]
        } cond
    ] [ f ] if ;

: wait-for-file ( FileArgs n port -- n )
    swap file-error?
    [ 2drop 0 ] [ >r lpOverlapped>> r> twiddle-thumbs ] if ;

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
