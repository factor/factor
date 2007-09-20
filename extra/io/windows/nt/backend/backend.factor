USING: alien alien.c-types arrays assocs combinators continuations
destructors io io.backend io.nonblocking io.windows io.windows.nt libc
kernel math namespaces sequences threads tuples.lib windows
windows.errors windows.kernel32 prettyprint ;
IN: io.windows.nt.backend

SYMBOL: io-hash

TUPLE: io-callback port continuation ;
C: <io-callback> io-callback

: (make-overlapped) ( -- overlapped-ext )
    "OVERLAPPED" malloc-object dup [ free ] t add-destructor
    0 over set-OVERLAPPED-internal
    0 over set-OVERLAPPED-internal-high
    0 over set-OVERLAPPED-offset-high
    0 over set-OVERLAPPED-offset
    f over set-OVERLAPPED-event ;

: make-overlapped ( port -- overlapped-ext )
    >r (make-overlapped) r> port-handle win32-file-ptr
    [ over set-OVERLAPPED-offset ] when* ;

: completion-port ( handle existing -- handle )
     f 1 CreateIoCompletionPort dup win32-error=0/f ;

: master-completion-port ( -- handle )
    INVALID_HANDLE_VALUE f completion-port ;

M: windows-nt-io add-completion ( handle -- )
    \ master-completion-port get-global completion-port drop ;

TUPLE: GetOverlappedResult-args hFile* lpOverlapped* lpNumberOfBytesTransferred* bWait* port ;

C: <GetOverlappedResult-args> GetOverlappedResult-args

: get-overlapped-result ( port -- n )
    [
        port-handle dup win32-file-handle
        swap win32-file-overlapped 0 <int> 0
    ] keep <GetOverlappedResult-args> [
        \ GetOverlappedResult-args >tuple<
        >r GetOverlappedResult r> swap overlapped-error? drop
    ] keep GetOverlappedResult-args-lpNumberOfBytesTransferred* *int ;

: (save-callback) ( io-callback -- )
    dup io-callback-port port-handle win32-file-overlapped
    \ io-hash get-global set-at ;

: save-callback ( port -- )
    [
        <io-callback> (save-callback) stop
    ] callcc0 drop ;

TUPLE: GetQueuedCompletionStatusParams hCompletionPort* lpNumberOfBytes* lpCompletionKey* lpOverlapped* dwMilliseconds* ;

C: <GetQueuedCompletionStatusParams> GetQueuedCompletionStatusParams

: wait-for-overlapped ( ms -- GetQueuedCompletionStatus-Params ret )
    >r \ master-completion-port get-global 0 <int>
    0 <int> 0 <int> r> <GetQueuedCompletionStatusParams> [
        GetQueuedCompletionStatusParams >tuple*<
        GetQueuedCompletionStatus
    ] keep swap ;

: lookup-callback ( GetQueuedCompletion-args -- callback ? )
    GetQueuedCompletionStatusParams-lpOverlapped* *void*
    \ io-hash get-global delete-at* ;

: wait-for-io ( timeout -- continuation/f )
    wait-for-overlapped
    zero? [
        GetLastError dup (expected-io-error?) [
            2drop f
        ] [
            (win32-error-string) swap lookup-callback [
                [ io-callback-port set-port-error ] keep
                io-callback-continuation
            ] [
                drop "No callback found" 2array throw
            ] if
        ] if
    ] [
        lookup-callback [ io-callback-continuation ] when
    ] if ;

: maybe-expire ( io-callbck -- )
    io-callback-port
    dup timeout? [
        port-handle win32-file-handle CancelIo drop
    ] [
        drop
    ] if ;

: cancel-timedout ( -- )
    io-hash get-global values [ maybe-expire ] each ;

M: windows-nt-io io-multiplex ( ms -- )
    cancel-timedout
    [ wait-for-io ] [ global [ "error: " write . flush ] bind drop f ] recover
    [ schedule-thread ] when* ;
