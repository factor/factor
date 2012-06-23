USING: kernel math ;

IN: benchmark.busy-loop

: busy-loop ( x -- n )
    1,000 [
        1,000 [
            1,000 [ bitxor ] each-integer
        ] times
    ] times ; inline

: busy-loop-benchmark ( -- )
    1337 [ busy-loop ] [ assert= ] bi ;

MAIN: busy-loop-benchmark
