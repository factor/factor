
USING: combinators hash-sets kernel literals
math math.combinatorics sequences sets ;

IN: benchmark.hash-sets

CONSTANT: test-sets $[
    { 10 100 1,000 10,000 50,000 100,000 }
    [ <iota> >hash-set ] map dup append
]

: do-times ( n quot: ( set1 set2 -- set' ) -- )
    '[ 2dup @ drop ] times 2drop ; inline

: bench-sets ( seq -- )
    2 [
        first2 {
            [ 3 [ union ] do-times ]
            [ 5 [ intersect ] do-times ]
            [ 100,000 [ intersects? ] do-times ]
            [ 3 [ diff ] do-times ]
            [ 50 [ set= ] do-times ]
            [ 25 [ subset? ] do-times ]
        } 2cleave
    ] each-combination ;

: hash-sets-benchmark ( -- )
    test-sets bench-sets ;

MAIN: hash-sets-benchmark
