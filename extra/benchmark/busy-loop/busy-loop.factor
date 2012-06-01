
USING: kernel math ;

IN: benchmark.busy-loop

: busy-loop-benchmark ( -- )
    1,000,000,000 [ 1 - dup 0 > ] loop drop ;

MAIN: busy-loop-benchmark
