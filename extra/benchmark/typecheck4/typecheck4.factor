USING: math kernel kernel.private slots.private ;
IN: benchmark.typecheck4

TUPLE: hello n ;

: hello-n* 4 slot ;

: foo 0 100000000 [ over hello-n* + ] times ;

: typecheck-main 0 hello construct-boa foo 2drop ;

MAIN: typecheck-main
