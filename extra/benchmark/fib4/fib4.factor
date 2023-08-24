USING: accessors math kernel ;
IN: benchmark.fib4

TUPLE: box { i read-only } ;

C: <box> box

: tuple-fib ( m -- n )
    dup i>> 1 <= [
        drop 1 <box>
    ] [
        i>> 1 - <box>
        dup tuple-fib
        swap
        i>> 1 - <box>
        tuple-fib
        swap i>> swap i>> + <box>
    ] if ; inline recursive

: fib4-benchmark ( -- ) T{ box f 34 } tuple-fib i>> 9227465 assert= ;

MAIN: fib4-benchmark
