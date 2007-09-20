USING: math kernel debugger ;
IN: benchmark.fib4

TUPLE: box i ;

C: <box> box

: tuple-fib ( m -- n )
    dup box-i 1 <= [
        drop 1 <box>
    ] [
        box-i 1- <box>
        dup tuple-fib
        swap
        box-i 1- <box>
        tuple-fib
        swap box-i swap box-i + <box>
    ] if ;

: fib-main T{ box f 34 } tuple-fib T{ box f 9227465 } assert= ;

MAIN: fib-main
