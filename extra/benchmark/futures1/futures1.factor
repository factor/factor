USING: concurrency.futures kernel sequences ;
IN: benchmark.futures1

: futures1-benchmark ( -- )
    250,000 <iota>
    [ [ '[ _ ] future ] map [ ?future ] map-sum ]
    [ sum ] bi assert= ;

MAIN: futures1-benchmark
