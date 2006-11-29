! Copyright (C) 2006 Mackenzie Straight, Doug Coleman.

IN: io
USING: win32-api win32-io-internals win32-server win32-stream ;
USING: alien kernel io-internals namespaces threads ;

: <file-reader> ( path -- stream ) <win32-file-reader> ;
: <file-writer> ( path -- stream ) <win32-file-writer> ;

SYMBOL: serv
: accept ( server -- client )
    [
        duplex-stream-in
        serv set
        serv get update-timeout new-socket 64 <buffer>
        [
            serv get alloc-io-callback f swap init-overlapped
            >r >r >r serv get win32-stream-handle r> r>
            buffer-ptr <alien> 0 32 32 f r> AcceptEx
            handle-socket-error!=0/f stop
        ] callcc1 drop
        swap dup add-completion <win32-stream> <win32-duplex-stream>
        dupd <win32-client-stream> swap buffer-free
    ] with-scope ;

: <client> ( host port -- stream )
    client-sockaddr new-socket
    [ swap "sockaddr-in" c-size connect handle-socket-error!=0/f ] keep
    dup add-completion <win32-stream> <win32-duplex-stream> ;
: <server> ( port -- stream ) make-win32-server ;

IN: io-internals

: io-multiplex ( ms -- )
    dup -1 = [ drop INFINITE ] when cancel-timedout wait-for-io
    swap [ schedule-thread-with ] [ drop ] if* ;

: init-io ( -- )
    win32-init-stdio
    init-winsock
    init-c-io ;

