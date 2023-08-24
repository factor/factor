USING: math kernel alien alien.c-types ;
IN: benchmark.fib6

: fib ( x -- y )
    int { int } cdecl [
        dup 1 <= [ drop 1 ] [
            1 - dup fib swap 1 - fib +
        ] if
    ] alien-callback
    int { int } cdecl alien-indirect ;

: fib6-benchmark ( -- ) 32 fib 3524578 assert= ;

MAIN: fib6-benchmark
