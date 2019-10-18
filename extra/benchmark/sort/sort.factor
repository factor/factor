USING: kernel sequences sorting random ;
IN: benchmark.sort

: sort-benchmark
    100000 [ drop 100000 random ] map natural-sort drop ;

MAIN: sort-benchmark
