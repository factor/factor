USING: bloom-filters kernel math ;

IN: benchmark.bloom-filters

: bloom-filters-benchmark ( -- )
    0.01 2000 <bloom-filter> 100,000 [
        100 over bloom-filter-insert
        100 over bloom-filter-member? drop
    ] times drop ;

MAIN: bloom-filters-benchmark
