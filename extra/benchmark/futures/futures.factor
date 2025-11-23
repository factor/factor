USING: concurrency.futures kernel sequences ;
IN: benchmark.futures

: futures-benchmark ( -- )
    250,000 <iota>
    [ [ '[ _ ] future ] map [ ?future ] map-sum ]
    [ sum ] bi assert= ;

MAIN: futures-benchmark
