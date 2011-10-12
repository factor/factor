! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays io io.encodings.binary io.servers
io.sockets kernel math memoize namespaces sequences fry literals ;
IN: benchmark.file-server

! Tweak these parameters to test different loads
CONSTANT: #times 4

! Max size here is 26 2^ 1 - because array-capacity limits on 32bit platforms
CONSTANT: test-file-size $[ 26 2^ 1 - ]

MEMO: test-file-bytes ( -- byte-array )
    test-file-size iota >byte-array ;

TUPLE: file-server < threaded-server ;

: <file-server> ( -- obj )
    binary \ file-server new-threaded-server
        f 0 <inet4> >>insecure ;

M: file-server handle-client*
    drop
    #times [ test-file-bytes output-stream get stream-write ] times ;
    
ERROR: incorrect-#bytes ;

: server>address ( server -- port )
    servers>> first addr>> port>> local-server ;

: file-server-benchmark ( -- )
    <file-server> start-server [
        [ #times ] dip
        server>address binary <client> drop [
            '[
                test-file-size _ stream-read length test-file-size =
                [ incorrect-#bytes ] unless
            ] times
        ] [
            stream-contents length 0 = [ incorrect-#bytes ] unless
        ] bi
    ] [ stop-server ] bi ;
    
MAIN: file-server-benchmark
