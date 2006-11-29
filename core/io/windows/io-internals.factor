! Copyright (C) 2006 Mackenzie Straight, Doug Coleman.

IN: win32-io-internals
USING: alien arrays errors kernel kernel-internals math namespaces threads 
       vectors win32-api io generic io-internals sequences ;

SYMBOL: completion-port
SYMBOL: io-queue

TUPLE: io-queue free-list callbacks ;
TUPLE: io-callback overlapped quotation stream ;

: expected-error? ( obj -- bool )
    [ 
        ERROR_IO_PENDING ERROR_HANDLE_EOF ERROR_SUCCESS WAIT_TIMEOUT 
        997
    ] member? ;

: handle-io-error ( -- )
    GetLastError expected-error? [ win32-error ] unless ;

: queue-error ( len/status -- len/status )
    GetLastError expected-error? [ drop f ] unless ;

: add-completion ( handle -- )
    completion-port get f 1 CreateIoCompletionPort drop ;

: get-access ( -- file-mode )
    "file-mode" get first2 
    GENERIC_WRITE 0 ? >r
    GENERIC_READ 0 ? r> bitor ;

: get-sharemode ( -- share-mode )
     FILE_SHARE_READ FILE_SHARE_WRITE bitor ;

: get-create ( -- creation-disposition )
    "file-mode" get first2 [
      [ OPEN_ALWAYS ] [ CREATE_ALWAYS ] if  
    ] [
      [ OPEN_EXISTING ] [ 0 ] if
    ] if ;

: win32-open-file ( file r w -- handle )
    [ 
        2array "file-mode" set
        get-access get-sharemode f get-create FILE_FLAG_OVERLAPPED f 
        CreateFile dup INVALID_HANDLE_VALUE =
        [ win32-error ] when
        dup add-completion
    ] with-scope ;

: <overlapped> ( -- overlapped )
    "overlapped-ext" <malloc-object> ;

C: io-queue ( -- queue )
    V{ } clone over set-io-queue-callbacks ;

C: io-callback ( -- callback )
    io-queue get io-queue-callbacks [ push ] 2keep
    length 1 - <overlapped> [ set-overlapped-ext-user-data ] keep
    swap [ set-io-callback-overlapped ] keep ;

: alloc-io-callback ( quot stream -- overlapped )
    io-queue get io-queue-free-list [ 
        first2 io-queue get [ set-io-queue-free-list ] keep
        io-queue-callbacks nth
    ] [ <io-callback> ] if*
    [ set-io-callback-stream ] keep
    [ set-io-callback-quotation ] keep
    io-callback-overlapped ;

: get-io-callback ( index -- callback )
    dup io-queue get io-queue-callbacks nth swap
    io-queue get [ io-queue-free-list 2array ] keep set-io-queue-free-list 
    [ f swap set-io-callback-stream ] keep
    io-callback-quotation ;

: (wait-for-io) ( timeout -- error overlapped len )
    >r completion-port get  0 <int>  0 <int> 0 <int>
    pick over r> -rot >r >r GetQueuedCompletionStatus r> r> ;

: overlapped>callback ( overlapped -- callback )
    *int dup zero? [
        drop f
    ] [
        <alien> overlapped-ext-user-data get-io-callback
    ] if ;

IN: win32-stream
DEFER: expire
IN: win32-io-internals
: cancel-timedout ( -- )
    io-queue get 
    io-queue-callbacks [ io-callback-stream [ expire ] when* ] each ;

: wait-for-io ( timeout -- callback len )
    (wait-for-io) overlapped>callback swap *int 
    rot [ queue-error ] unless ;

: win32-init-stdio ( -- )
    INVALID_HANDLE_VALUE f f 1 CreateIoCompletionPort
    completion-port set-global
    <io-queue> io-queue set-global ;

