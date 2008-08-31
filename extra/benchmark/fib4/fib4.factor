USING: accessors math kernel debugger ;
IN: benchmark.fib4

TUPLE: box i ;

C: <box> box

: tuple-fib ( m -- n )
    dup i>> 1 <= [
        drop 1 <box>
    ] [
        i>> 1- <box>
        dup tuple-fib
        swap
        i>> 1- <box>
        tuple-fib
        swap i>> swap i>> + <box>
    ] if ;

: fib-main ( -- ) T{ box f 34 } tuple-fib T{ box f 9227465 } assert= ;

MAIN: fib-main
