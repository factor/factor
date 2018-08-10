! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors byte-arrays io io.encodings.binary io.servers
io.sockets kernel math memoize namespaces sequences fry literals
locals formatting ;
IN: benchmark.tcp-echo0

! Max size here is 26 2^ 1 - because array-capacity limits on 32bit platforms
CONSTANT: test-size0 $[ 23 2^ 1 - ]

MEMO: test-bytes ( n -- byte-array ) <iota> >byte-array ;

TUPLE: tcp-echo < threaded-server n-times n-bytes ;

: <tcp-echo> ( n-times n-bytes -- obj )
    binary \ tcp-echo new-threaded-server
        swap >>n-bytes
        swap >>n-times
        <any-port-local-inet4> >>insecure ;

ERROR: incorrect-n-bytes ;

: check-bytes ( bytes n -- bytes )
    over length = [ incorrect-n-bytes ] unless ;

: read-n ( n -- bytes )
    [ read ] [ check-bytes ] bi ;

: read-write ( n -- ) read-n write flush ;

: write-read ( bytes -- )
    [ write flush ] [ length read-n drop ] bi ;

M: tcp-echo handle-client*
    [ n-times>> ] [ n-bytes>> ] bi
    '[ _ [ _ test-bytes write-read ] times ] call ;

: server>address ( server -- port )
    servers>> first addr>> port>> local-server ;

: tcp-echo-banner ( n-times n-bytes -- )
    "Network testing: times: %d, length: %d\n" printf ;

:: tcp-echo-benchmark ( n-times n-bytes -- )
    n-times n-bytes [ tcp-echo-banner ] 2keep
    <tcp-echo> [
        \ threaded-server get server>address binary [
            n-times [ n-bytes read-write ] times
            contents empty? [ incorrect-n-bytes ] unless
        ] with-client
    ] with-threaded-server ;

: tcp-echo0-benchmark ( -- )
    4 test-size0 tcp-echo-benchmark ;

MAIN: tcp-echo0-benchmark
