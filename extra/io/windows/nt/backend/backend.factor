USING: alien alien.c-types arrays assocs combinators continuations
destructors io io.backend io.nonblocking io.windows libc
kernel math namespaces sequences threads tuples.lib windows
windows.errors windows.kernel32 prettyprint strings splitting
io.files windows.winsock ;
IN: io.windows.nt.backend

: .. global [ . flush ] bind ;
: .S global [ .s flush ] bind ;

: unicode-prefix ( -- seq )
    "\\\\?\\" ; inline

M: windows-nt-io normalize-pathname ( string -- string )
    dup string? [ "pathname must be a string" throw ] unless
    "/" split "\\" join
    {
        ! empty
        { [ dup empty? ] [ "empty path" throw ] }
        ! .\\foo
        { [ dup ".\\" head? ] [
            >r unicode-prefix cwd r> 1 tail 3append
        ] }
        ! c:\\
        { [ dup 1 tail ":" head? ] [ >r unicode-prefix r> append ] }
        ! \\\\?\\c:\\foo
        { [ dup unicode-prefix head? ] [ ] }
        ! foo.txt ..\\foo.txt
        { [ t ] [
            [
                unicode-prefix % cwd %
                dup first CHAR: \\ = [ CHAR: \\ , ] unless %
            ] "" make
        ] }
    } cond [ "/\\." member? ] right-trim ;

SYMBOL: io-hash

TUPLE: io-callback port continuation ;
C: <io-callback> io-callback

: (make-overlapped) ( -- overlapped-ext )
    "OVERLAPPED" malloc-object dup free-always
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

: lookup-callback ( GetQueuedCompletion-args -- callback )
    GetQueuedCompletionStatusParams-lpOverlapped* *void*
    \ io-hash get-global delete-at* drop ;

: wait-for-io ( timeout -- continuation/f )
    wait-for-overlapped
    zero? [
        GetLastError dup (expected-io-error?) [
            2drop f
        ] [
            dup ERROR_HANDLE_EOF = [
                drop lookup-callback [
                    io-callback-port t swap set-port-eof?
                ] keep io-callback-continuation
            ] [
                (win32-error-string) swap lookup-callback
                [ io-callback-port set-port-error ] keep
                io-callback-continuation
            ] if
        ] if
    ] [
        lookup-callback io-callback-continuation
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

M: windows-nt-io init-io ( -- )
    #! Should only be called on startup. Calling this at any
    #! other time can have unintended consequences.
    global [
        master-completion-port \ master-completion-port set
        H{ } clone \ io-hash set
        init-winsock
    ] bind ;
