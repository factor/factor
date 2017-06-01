USING: kernel math math.constants msgpack sequences ;
IN: benchmark.msgpack

: pack-sum ( seq -- n )
    [ >msgpack msgpack> ] map-sum ;

: pack-sum-lengths ( seq -- n )
    [ >msgpack msgpack> length ] map-sum ;

: msgpack-benchmark ( -- )
    500,000 <iota> pack-sum 124,999,750,000 assert=
    500,000 "hello" <repetition> pack-sum-lengths 2,500,000 assert=
    500,000 pi <repetition> pack-sum 0x1.7f7ec53a9f04ap20 assert= ;

MAIN: msgpack-benchmark
