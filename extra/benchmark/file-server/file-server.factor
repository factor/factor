! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays io io.encodings.binary io.servers
io.sockets kernel math memoize namespaces sequences ;
IN: benchmark.file-server

: test-file-size ( -- n ) 26 2^ ;

MEMO: test-file-bytes ( -- byte-array )
    test-file-size iota >byte-array ;

TUPLE: file-server < threaded-server ;

: <file-server> ( -- obj )
    binary \ file-server new-threaded-server
        f 0 <inet4> >>insecure ;

M: file-server handle-client*
    drop test-file-bytes output-stream get stream-write ;
    
ERROR: incorrect-#bytes ;

: server>address ( server -- port )
    servers>> first addr>> port>> local-server ;

: file-server-benchmark ( -- )
    <file-server> start-server [
        server>address binary <client> drop
        stream-contents length test-file-size = [ incorrect-#bytes ] unless
    ] [ stop-server ] bi ;
    
MAIN: file-server-benchmark