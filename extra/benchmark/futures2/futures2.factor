USING: concurrency.combinators kernel sequences ;
IN: benchmark.futures2

: futures2-benchmark ( -- )
    250,000 <iota> [ [ ] parallel-map sum ] [ sum ] bi assert= ;

MAIN: futures2-benchmark
