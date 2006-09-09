! Copyright (C) 2006 Mackenzie Straight, Doug Coleman.

IN: io
USING: compiler namespaces kernel win32-io-internals win32-stream win32-api
    threads ;

: <file-reader> <win32-file-reader> ;
: <file-writer> <win32-file-writer> ;
: <server> make-win32-server ;

IN: io-internals

: io-multiplex ( ms -- )
    dup -1 = [ drop INFINITE ] when cancel-timedout wait-for-io 
    swap [ schedule-thread-with ] [ drop ] if* ;

: init-io ( -- )
    win32-init-stdio 
    init-winsock ;

