USING: combinators kernel math memoize ;
IN: benchmark.fib8

MEMO: (faster-fib) ( m -- n )
    dup 1 > [
        [ 2/ dup 1 - [ (faster-fib) ] bi@ ] [ 4 mod ] bi {
            { 1 [ [ 2 * ] dip [ + ] [ - ] 2bi * 2 + ] }
            { 3 [ [ 2 * ] dip [ + ] [ - ] 2bi * 2 - ] }
            [ drop dupd 2 * + * ]
        } case
    ] when ;

: faster-fib ( m -- n )
    dup 0 >= [ throw ] unless (faster-fib) ;

: fib8-benchmark ( -- )
    100 [
        \ (faster-fib) reset-memoized
        100,000 faster-fib log2 69423 assert=
    ] times ;

MAIN: fib8-benchmark
