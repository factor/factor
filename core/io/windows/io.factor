! Copyright (C) 2004, 2007 Mackenzie Straight, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien bit-arrays c-streams errors generic
hashtables io libc kernel math namespaces
nonblocking-io sequences strings sbufs threads
vectors buffers win32-api ;
IN: io-internals

: ERROR_SUCCESS 0 ; inline
: ERROR_HANDLE_EOF 38 ; inline
: ERROR_IO_PENDING 997 ; inline
: WAIT_TIMEOUT 258 ; inline

SYMBOL: io-hash
TUPLE: io-callback port overlapped continuation ;
TUPLE: win32-file handle ptr ;

: access-mode ( r w -- fixnum )
    GENERIC_WRITE 0 ?
    >r GENERIC_READ 0 ? r> bitor ;

: share-mode ( -- fixnum )
    FILE_SHARE_READ FILE_SHARE_WRITE bitor ;

: create-mode ( r w -- fixnum )
    [ OPEN_ALWAYS CREATE_ALWAYS ? ] [ OPEN_EXISTING 0 ? ] if ;

: make-overlapped ( port -- overlapped-ext )
    "OVERLAPPED" malloc-object
    0 over set-OVERLAPPED-internal
    0 over set-OVERLAPPED-internal-high
    >r port-handle win32-file-ptr dup 0 ? r>
    [ set-OVERLAPPED-offset ] keep
    0 over set-OVERLAPPED-offset-high
    f over set-OVERLAPPED-event ;

: completion-port ( -- alien )
    INVALID_HANDLE_VALUE f f 1 CreateIoCompletionPort
    dup win32-error=0/f ;

: add-completion ( handle -- )
    \ completion-port get
    f 1 CreateIoCompletionPort win32-error=0/f ;

: open-file ( file r w -- handle )
    [ access-mode share-mode f ] 2keep create-mode
    FILE_FLAG_OVERLAPPED f CreateFile
    dup INVALID_HANDLE_VALUE = [ win32-error ] when
    dup add-completion ;

: expected-error? ( n -- ? )
    ! ERROR_IO_PENDING ERROR_SUCCESS WAIT_TIMEOUT 258
    { 997 0 258 } member? ;

: handle-io-error ( port overlapped ret -- ? )
    #! Returns true if we should callcc0.
    zero? [
        GetLastError dup expected-error? [
            3drop t
        ] [
            swap free
            dup ERROR_HANDLE_EOF = [
                drop
                t swap set-port-eof? f
            ] [
                nip (win32-error) f
            ] if
        ] if
    ] [
        2drop t
    ] if ;

M: win32-file init-handle ( handle -- ) drop ;

: expire? ( overlapped io-callbck -- )
    io-callback-port
    dup timeout? [
        port-handle win32-file-handle CancelIo win32-error=0/f
        [ io-hash get remove-hash ] keep free
    ] [
        2drop
    ] if ;

: cancel-timedout ( -- )
    io-hash get [ expire? ] hash-each ;

: save-callback ( io-callback -- )
    dup io-callback-overlapped \ io-hash get set-hash ;

: get-io-callback ( overlapped -- callback )
    \ io-hash get [ hash ] 2keep remove-hash ; 

: overlapped>callback ( overlapped -- callback )
    *int dup zero? [
        drop f
    ] [
        <alien> get-io-callback io-callback-continuation
    ] if ;

: queue-error ( callback -- ? )
    GetLastError dup expected-error? [
        2drop
    ] [
        nip (win32-error) 
    ] if f ;

: (wait-for-io) ( timeout -- error overlapped )
    >r \ completion-port get 0 <int> 0 <int> 0 <int>
    pick over r> -rot >r >r GetQueuedCompletionStatus r> r> nip ;

: wait-for-io ( timeout -- overlapped )
    (wait-for-io) overlapped>callback
    swap zero? [ queue-error ] when ;

: io-multiplex ( ms -- )
    cancel-timedout
    dup -1 = [ drop INFINITE ] when wait-for-io
    [ schedule-thread ] when* ;

: setup-write ( port -- handle pbuffer lbuffer f lpoverlapped )
    [ port-handle win32-file-handle ] keep
    [
        delegate
        [ buffer@ alien-address ] keep buffer-length
        f
    ] keep make-overlapped ;

: setup-read ( port -- handle pbuffer lbuffer f lpoverlapped )
    [ port-handle win32-file-handle ] keep
    [
        delegate
        [ buffer-end alien-address ] keep buffer-capacity
        f
    ] keep make-overlapped ;


: get-overlapped-result ( port overlapped -- n ret )
    #! n is number of bytes written/read
    #! ret = 0 is an error
    >r port-handle win32-file-handle r> 0 <int> 0
    [ GetOverlappedResult ] 2keep drop *int swap ;

: update-file-ptr ( n port -- )
    port-handle
    dup win32-file-ptr [
        [ win32-file-ptr + ] keep set-win32-file-ptr
    ] [
        2drop
    ] if ;

: finish-read ( port overlapped -- )
    2dup get-overlapped-result zero? [
        drop dupd handle-io-error (wait-to-read)
    ] [
        >r free r>
        dup zero? [
            drop t swap set-port-eof?
        ] [
            [ over n>buffer ] keep
            swap update-file-ptr
        ] if
    ] if ;

M: input-port (wait-to-read) ( port -- )
    dup touch-port dup setup-read [ ReadFile ] keep
    swap >r 2dup r>
    handle-io-error [
        [
            <io-callback> save-callback stop
        ] callcc0 finish-read
    ] [
        2drop
    ] if ;

DEFER: flush-output
: finish-flush ( port overlapped -- )
    2dup get-overlapped-result zero? [
        drop dupd handle-io-error flush-output
    ] [
        >r free r>
        [ over update-file-ptr ] keep
        over delegate [ buffer-consume ] keep
        buffer-length 0 > [
            flush-output
        ] [
            drop
        ] if
    ] if ;

! callcc1
: flush-output ( port -- )
    dup touch-port dup setup-write
    [ WriteFile ] keep
    swap >r 2dup r> handle-io-error [
        [
            <io-callback> save-callback stop
        ] callcc0 finish-flush
    ] [
        2drop
    ] if ;
    
: port-flush ( port -- )
    dup buffer-empty? [ drop ] [ flush-output ] if ;

M: output-port stream-flush ( port -- ) port-flush ;

M: port stream-close ( port -- )
    dup port-type closed eq? [
        dup port-type >r closed over set-port-type r>
        output eq? [ dup port-flush ] when
        dup port-handle win32-file-handle CloseHandle drop
        dup delegate [ buffer-free ] when*
        f over set-delegate
    ] unless drop ;

DEFER: init-winsock
USE: io

: init-io ( -- )
    #! Should only be called on startup. Calling this at any
    #! other time can have unintended consequences.
    global [
        completion-port \ completion-port set
        H{ } clone \ io-hash set
        init-winsock
        init-c-io
    ] bind ;

