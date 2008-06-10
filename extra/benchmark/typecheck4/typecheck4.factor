USING: math kernel kernel.private slots.private ;
IN: benchmark.typecheck4

TUPLE: hello n ;

: hello-n* ( obj -- val ) 3 slot ;

: foo ( obj -- obj n ) 0 100000000 [ over hello-n* + ] times ;

: typecheck-main ( -- ) 0 hello boa foo 2drop ;

MAIN: typecheck-main
