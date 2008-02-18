USING: alien alien.c-types arrays assocs combinators
continuations destructors io io.backend io.nonblocking
io.windows libc kernel math namespaces sequences
concurrency.threads tuples.lib windows windows.errors
windows.kernel32 strings splitting io.files qualified ascii
combinators.lib ;
QUALIFIED: windows.winsock
IN: io.windows.nt.backend

SYMBOL: io-hash

TUPLE: io-callback port thread ;

C: <io-callback> io-callback

: (make-overlapped) ( -- overlapped-ext )
    "OVERLAPPED" malloc-object dup free-always ;

: make-overlapped ( port -- overlapped-ext )
    >r (make-overlapped) r> port-handle win32-file-ptr
    [ over set-OVERLAPPED-offset ] when* ;

: <completion-port> ( handle existing -- handle )
     f 1 CreateIoCompletionPort dup win32-error=0/f ;

SYMBOL: master-completion-port

: <master-completion-port> ( -- handle )
    INVALID_HANDLE_VALUE f <completion-port> ;

M: windows-nt-io add-completion ( handle -- )
    master-completion-port get-global <completion-port> drop ;

: eof? ( error -- ? )
    dup ERROR_HANDLE_EOF = swap ERROR_BROKEN_PIPE = or ;

: overlapped-error? ( port n -- ? )
    zero? [
        GetLastError {
            { [ dup expected-io-error? ] [ 2drop t ] }
            { [ dup eof? ] [ drop t swap set-port-eof? f ] }
            { [ t ] [ (win32-error-string) throw ] }
        } cond
    ] [
        drop t
    ] if ;

: get-overlapped-result ( overlapped port -- bytes-transferred )
    dup port-handle win32-file-handle rot 0 <uint>
    [ 0 GetOverlappedResult overlapped-error? drop ] keep *uint ;

: save-callback ( overlapped port -- )
    [
        <io-callback> swap
        dup alien? [ "bad overlapped in save-callback" throw ] unless
        io-hash get-global set-at
    ] suspend 3drop ;

: wait-for-overlapped ( ms -- overlapped ? )
    >r master-completion-port get-global r> ! port ms
    0 <int> ! bytes
    f <void*> ! key
    f <void*> ! overlapped
    [ roll GetQueuedCompletionStatus ] keep *void* swap zero? ;

: lookup-callback ( overlapped -- callback )
    io-hash get-global delete-at* drop
    dup io-callback? [ "no callback in io-hash" throw ] unless ;

: handle-overlapped ( timeout -- ? )
    wait-for-overlapped [
        GetLastError dup expected-io-error? [
            2drop t
        ] [
            dup eof? [
                drop lookup-callback
                dup io-callback-port t swap set-port-eof?
            ] [
                (win32-error-string) swap lookup-callback
                [ io-callback-port set-port-error ] keep
            ] if io-callback-thread resume f
        ] if
    ] [
        lookup-callback
        io-callback-thread resume f
    ] if ;

: drain-overlapped ( timeout -- )
    handle-overlapped [ 0 drain-overlapped ] unless ;

M: windows-nt-io cancel-io
    port-handle win32-file-handle CancelIo drop ;

M: windows-nt-io io-multiplex ( ms -- )
    drain-overlapped ;

M: windows-nt-io init-io ( -- )
    <master-completion-port> master-completion-port set-global
    H{ } clone io-hash set-global
    windows.winsock:init-winsock ;
