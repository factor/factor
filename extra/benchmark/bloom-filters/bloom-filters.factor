USING: bloom-filters kernel math sequences ;

IN: benchmark.bloom-filters

: insert-data ( bloom-filter -- bloom-filter )
    100 [ 2,000 <iota> [ over bloom-filter-insert ] each ] times ;

: test-hit ( bloom-filter -- bloom-filter )
    100,000 [ 100 over bloom-filter-member? drop ] times ;

: test-miss ( bloom-filter -- bloom-filter )
    1,000,000 [ 12345 over bloom-filter-member? drop ] times ;

: bloom-filters-benchmark ( -- )
    0.01 2000 <bloom-filter> insert-data test-hit test-miss drop ;

MAIN: bloom-filters-benchmark
