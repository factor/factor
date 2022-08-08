USING: kernel sequences math vectors ;
IN: benchmark.stack

: stack-loop ( vec -- )
    1000 [
        10000 [
            dup pop dup ! dup 10 > [ sqrt dup 1 + ] [ dup 2 * ] if
            pick push
            over push
        ] times
        10000 [ dup pop* ] times
    ] times
    drop ;

: stack-benchmark ( -- )
    V{ 123456 } clone stack-loop
    20000 <vector> 123456 over set-first stack-loop ;

MAIN: stack-benchmark
