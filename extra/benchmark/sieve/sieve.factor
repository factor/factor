USING: bit-arrays kernel locals math math.functions ranges
sequences ;
IN: benchmark.sieve

:: sieve ( n -- #primes )
    n dup odd? [ 1 + ] when 2/ <bit-array> :> sieve
    t 0 sieve set-nth

    3 n sqrt 2 <range> [| i |
        i 2/ sieve nth [
            i sq n i 2 * <range> [| j |
                t j 2/ sieve set-nth
            ] each
        ] unless
    ] each

    sieve [ not ] count 1 + ;

: sieve-benchmark ( -- )
    100,000,000 sieve 5,761,455 assert= ;

MAIN: sieve-benchmark
