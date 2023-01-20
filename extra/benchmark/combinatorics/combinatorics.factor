! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: combinators kernel math math.combinatorics ranges
sequences ;

IN: benchmark.combinatorics

: bench-combinations ( n -- )
    [1..b] dup clone [
        {
            [ all-combinations drop ]
            [ [ drop ] each-combination ]
            [ [ first 2 = ] find-combination drop ]
            [ 0 [ sum + ] reduce-combinations drop ]
        } 2cleave
    ] with each ;

: bench-permutations ( n -- )
    <iota> {
        [ all-permutations drop ]
        [ [ drop ] each-permutation ]
        [ [ first 2 = ] find-permutation drop ]
        [ 0 [ sum + ] reduce-permutations drop ]
    } cleave ;

: combinatorics-benchmark ( -- )
    15 bench-combinations 8 bench-permutations ;

MAIN: combinatorics-benchmark
