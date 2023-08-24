USING: kernel math math.parser sequences ;
IN: benchmark.fib7

:: matrix-fib ( m -- n )
    m 0 >= [ m throw ] unless
    m 2 >base [ CHAR: 1 = ] { } map-as :> bits
    1 :> a! 0 :> b! 1 :> c!
    bits [
        [
            a c + b *
            b sq c sq +
        ] [
            a sq b sq +
            a c + b *
        ] if b! a! a b + c!
    ] each b ;

: fib7-benchmark ( -- )
    100 [
        100,000 matrix-fib log2 69423 assert=
    ] times ;

MAIN: fib7-benchmark
