USING: math kernel kernel.private slots.private ;
IN: benchmark.typecheck2

TUPLE: hello n ;

: hello-n* dup tuple? [ 4 slot ] [ 3 throw ] if ;

: foo 0 100000000 [ over hello-n* + ] times ;

: typecheck-main 0 hello construct-boa foo 2drop ;

MAIN: typecheck-main
