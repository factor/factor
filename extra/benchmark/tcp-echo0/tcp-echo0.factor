! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays io io.encodings.binary io.servers
io.sockets kernel math memoize namespaces sequences fry literals
locals formatting ;
IN: benchmark.tcp-echo0

! Max size here is 26 2^ 1 - because array-capacity limits on 32bit platforms
CONSTANT: test-size0 $[ 23 2^ 1 - ]

MEMO: test-bytes ( n -- byte-array ) <iota> >byte-array ;

TUPLE: tcp-echo < threaded-server #times #bytes ;

: <tcp-echo> ( #times #bytes -- obj )
    binary \ tcp-echo new-threaded-server
        swap >>#bytes
        swap >>#times
        <any-port-local-inet4> >>insecure ;

ERROR: incorrect-#bytes ;

: check-bytes ( bytes n -- bytes )
    over length = [ incorrect-#bytes ] unless ;

: read-n ( n -- bytes )
    [ read ] [ check-bytes ] bi ;

: read-write ( n -- ) read-n write flush ;

: write-read ( bytes -- )
    [ write flush ] [ length read-n drop ] bi ;

M: tcp-echo handle-client*
    [ #times>> ] [ #bytes>> ] bi
    '[ _ [ _ test-bytes write-read ] times ] call ;

: server>address ( server -- port )
    servers>> first addr>> port>> local-server ;

: tcp-echo-banner ( #times #bytes -- )
    "Network testing: times: %d, length: %d\n" printf ;

:: tcp-echo-benchmark ( #times #bytes -- )
    #times #bytes [ tcp-echo-banner ] 2keep
    <tcp-echo> [
        \ threaded-server get server>address binary [
            #times [ #bytes read-write ] times
            read-contents empty? [ incorrect-#bytes ] unless
        ] with-client
    ] with-threaded-server ;

: tcp-echo0-benchmark ( -- )
    4 test-size0 tcp-echo-benchmark ;

MAIN: tcp-echo0-benchmark
