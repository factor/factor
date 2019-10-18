USING: kernel math math.parser sequences ;
IN: benchmark.parse-bignum

: parse-bignum-benchmark ( -- )
    3000 <iota> [
        2^ [ number>string string>number ] [ assert= ] bi
    ] each ;

MAIN: parse-bignum-benchmark
