USING: kernel literals math.parser math.vectors random
sequences ;
IN: benchmark.parse-ratio

CONSTANT: test-ratios $[
    200,000 100,000 random-integers
    200,000 1,000 random-integers 1 v+n v/
]

: parse-ratio-benchmark ( -- )
    test-ratios [
        [ number>string string>number ] [ assert= ] bi
    ] each ;

MAIN: parse-ratio-benchmark
