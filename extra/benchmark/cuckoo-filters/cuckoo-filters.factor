USING: cuckoo-filters endian kernel math sequences ;
IN: benchmark.cuckoo-filters

: insert-data ( cuckoo-filter -- cuckoo-filter )
    2,000 <iota> [ 4 >le ] map
    10 swap '[ _ [ over cuckoo-insert drop ] each ] times ;

: test-hit ( cuckoo-filter -- cuckoo-filter )
    10,000 100 4 >le '[ _ over cuckoo-lookup drop ] times ;

: test-miss ( cuckoo-filter -- cuckoo-filter )
    100,000 12345 4 >le '[ _ over cuckoo-lookup drop ] times ;

: cuckoo-filters-benchmark ( -- )
    2000 <cuckoo-filter> insert-data test-hit test-miss drop ;

MAIN: cuckoo-filters-benchmark
