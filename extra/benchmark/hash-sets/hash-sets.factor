
USING: combinators hash-sets kernel math.combinatorics sequences sets ;

IN: benchmark.hash-sets

: make-sets ( -- seq )
    { 10 100 1,000 10,000 100,000 1,000000 } [ iota >hash-set ] map ;

: bench-sets ( seq -- )
    2 [
        first2 {
            [ union drop ]
            [ intersect drop ]
            [ intersects? drop ]
            [ diff drop ]
            [ set= drop ]
            [ subset? drop ]
        } 2cleave
    ] each-combination ;

: hash-sets-benchmark ( -- )
    make-sets bench-sets ;

MAIN: hash-sets-benchmark
