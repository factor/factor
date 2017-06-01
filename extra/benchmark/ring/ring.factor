USING: threads concurrency.messaging kernel
tools.time math sequences ;
IN: benchmark.ring

SYMBOL: done

: tunnel ( process -- process )
    receive 2dup swap send done eq? [ tunnel ] unless ;

: create-ring ( processes -- target )
    self swap [
        dup [ tunnel ] curry "Tunnel" spawn nip
    ] times ;

: send-messages ( messages target -- )
    [ dup <iota> ] dip [ send ] curry each [ receive drop ] times ;

: destroy-ring ( target -- )
    done swap send [ done eq? ] receive-if drop ;

: ring-bench ( messages processes -- )
    create-ring [ send-messages ] keep destroy-ring ;

: ring-benchmark ( -- )
    1000 1000 ring-bench ;

MAIN: ring-benchmark
