USING: math kernel slots.private ;
IN: benchmark.typecheck3

TUPLE: hello n ;

: hello-n* ( obj -- val ) 2 slot ;

: foo ( obj -- obj n ) 0 100000000 [ over hello-n* + ] times ;

: typecheck3-benchmark ( -- ) 0 hello boa foo 2drop ;

MAIN: typecheck3-benchmark
