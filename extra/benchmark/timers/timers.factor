USING: concurrency.flags kernel math namespaces timers ;
IN: benchmark.timers

SYMBOL: loop-flag
SYMBOL: loop-count
SYMBOL: loop-max

: inner-loop ( -- )
    loop-count counter loop-max get-global > [
        loop-flag get-global raise-flag
    ] when ;

: outer-loop ( n -- )
    loop-max set-global
    0 loop-count set-global
    <flag> loop-flag set-global
    [ inner-loop ] 1 every
    loop-flag get-global wait-for-flag
    stop-timer ;

: timers-benchmark ( -- )
    20,000 [ outer-loop ] [ loop-max get-global assert= ] bi ;

MAIN: timers-benchmark
