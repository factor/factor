USING: kernel sequences ;
IN: benchmark.empty-loop-2

: empty-loop-2 ( n -- )
    <iota> [ drop ] each ;

: empty-loop-2-benchmark ( -- )
    50000000 empty-loop-2 ;

MAIN: empty-loop-2-benchmark
