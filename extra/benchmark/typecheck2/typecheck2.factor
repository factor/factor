USING: math kernel kernel.private slots.private ;
IN: benchmark.typecheck2

TUPLE: hello n ;

: hello-n* ( obj -- value ) dup tuple? [ 2 slot ] [ 3 throw ] if ;

: foo ( obj -- obj n ) 0 100000000 [ over hello-n* + ] times ;

: typecheck-main ( -- ) 0 hello boa foo 2drop ;

MAIN: typecheck-main
