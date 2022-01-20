USING: assocs combinators kernel linked-assocs math sequences ;

IN: benchmark.linked-assocs

: (linked-assocs-benchmark) ( -- )
    10,000 <iota> <linked-hash> {
        [ '[ 0 swap _ set-at ] each ]
        [ '[ _ at ] map-sum 0 assert= ]
        [ '[ dup _ set-at ] each ]
        [ '[ _ at ] map-sum 49995000 assert= ]
        [ '[ _ delete-at ] each ]
        [ nip assoc-size 0 assert= ]
    } 2cleave ;

: linked-assocs-benchmark ( -- )
    100 [ (linked-assocs-benchmark) ] times ;

MAIN: linked-assocs-benchmark
