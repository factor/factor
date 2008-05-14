USING: alien alien.c-types arrays assocs combinators
continuations destructors io io.backend io.ports
io.windows libc kernel math namespaces sequences
threads classes.tuple.lib windows windows.errors
windows.kernel32 strings splitting io.files qualified ascii
combinators.lib system accessors ;
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

M: winnt add-completion ( handle -- )
    master-completion-port get-global <completion-port> drop ;

: eof? ( error -- ? )
    dup ERROR_HANDLE_EOF = swap ERROR_BROKEN_PIPE = or ;

: overlapped-error? ( port n -- ? )
    zero? [
        GetLastError {
            { [ dup expected-io-error? ] [ 2drop t ] }
            { [ dup eof? ] [ drop t >>eof drop f ] }
            [ (win32-error-string) throw ]
        } cond
    ] [
        drop t
    ] if ;

: get-overlapped-result ( overlapped port -- bytes-transferred )
    dup handle>> handle>> rot 0 <uint>
    [ 0 GetOverlappedResult overlapped-error? drop ] keep *uint ;

: save-callback ( overlapped port -- )
    [
        <io-callback> swap
        dup alien? [ "bad overlapped in save-callback" throw ] unless
        io-hash get-global set-at
    ] "I/O" suspend 3drop ;

: wait-for-overlapped ( ms -- overlapped ? )
    >r master-completion-port get-global
    r> INFINITE or ! timeout
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
                dup port>> t >>eof drop
            ] [
                (win32-error-string) swap lookup-callback
                [ port>> set-port-error ] keep
            ] if thread>> resume f
        ] if
    ] [
        lookup-callback
        io-callback-thread resume f
    ] if ;

: drain-overlapped ( timeout -- )
    handle-overlapped [ 0 drain-overlapped ] unless ;

M: winnt cancel-io
    handle>> handle>> CancelIo drop ;

M: winnt io-multiplex ( ms -- )
    drain-overlapped ;

M: winnt init-io ( -- )
    <master-completion-port> master-completion-port set-global
    H{ } clone io-hash set-global
    windows.winsock:init-winsock ;
